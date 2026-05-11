//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import AdyenNetworking
import Foundation

/// ``Session`` acts as the delegate for the checkout payment flow.
/// It can handle the required steps internally such as `/payments` and `/payment/details`
/// calls and partial payment calls, then provide feedback
/// via ``SessionDelegate`` methods.
public final class Session: SessionProtocol {
    
    /// The session context information.
    public internal(set) var state: Session.State
    
    /// The presentation delegate.
    public package(set) weak var presentationDelegate: PresentationDelegate?
    
    /// The delegate object.
    public package(set) weak var delegate: SessionDelegate?
    
    internal let context: AdyenContext
    
    package var currentResult: CheckoutResult? {
        guard let resultCode = state.resultCode else { return nil }
        return CheckoutResult(resultCode: resultCode, sessionResult: state.sessionResult)
    }
    
    /// Session's API client should be only of SessionAPIClient type
    /// in order to update session data/result after each internal API call.
    internal private(set) lazy var apiClient: SessionAPIClient = {
        SessionAPIClient(
            apiClient: baseAPIClient,
            onSessionDataUpdate: { [weak self] data in
                self?.updateSession(with: data)
            },
            onSessionResultUpdate: { [weak self] result in
                self?.updateSession(with: result)
            }
        )
    }()
    
    @MainActor
    internal lazy var actionHandlingComponent: ActionHandlingComponent = {
        let handler = CheckoutActionComponent(
            context: context,
            configuration: CheckoutActionComponent.Configuration()
        )
        // TODO: create a way for CheckoutConfig to have CheckoutActionComponent.Configuration
        // and it should provided if they want to have action handling
        // move CheckoutActionComponent.Configuration to its own entity and make it public
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()
    
    /// The injected API client to be used by the session's API client.
    private let baseAPIClient: AsyncAPIClientProtocol
    
    internal init(
        state: Session.State,
        baseAPIClient: AsyncAPIClientProtocol,
        context: AdyenContext,
        delegate: SessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.state = state
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
        self.baseAPIClient = baseAPIClient
        self.context = context
    }
}

// MARK: - Setup

extension Session {
    
    /// Initializes an instance of ``Session`` asynchronously.
    /// - Parameter sessionResponse: The session setup initial data.
    /// - Parameter apiClient: The api client object for network calls.
    /// - Parameter context: The context object for the session.
    /// - Returns: A configured Session instance.
    /// - Throws: An error if the session setup fails.
    package static func setup(
        with sessionResponse: SessionResponse,
        apiClient: AsyncAPIClientProtocol,
        context: AdyenContext
    ) async throws -> Session {
        let sessionState = try await makeSetupCall(
            with: sessionResponse,
            baseAPIClient: apiClient
        )
        
        let session = Session(
            state: sessionState,
            baseAPIClient: apiClient,
            context: context
        )
        AnalyticsForSession.sessionId = sessionState.identifier
        return session
    }
    
    internal static func makeSetupCall(
        with sessionResponse: SessionResponse,
        baseAPIClient: AsyncAPIClientProtocol,
        order: PartialPaymentOrder? = nil
    ) async throws -> State {
        let sessionId = sessionResponse.id
        let sessionData = sessionResponse.sessionData
        
        let request = SessionSetupRequest(
            sessionId: sessionId,
            sessionData: sessionData,
            order: order
        )
        
        let response: SessionSetupResponse = try await baseAPIClient.performAsync(request)
        
        return State(
            data: response.sessionData,
            identifier: sessionId,
            countryCode: response.countryCode,
            shopperLocale: response.shopperLocale,
            amount: response.amount,
            paymentMethods: response.paymentMethods,
            responseConfiguration: response.configuration
        )
    }
}

// MARK: - Session API

extension Session {
    
    package func performSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        let request = PaymentsRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            data: data
        )
        let response: PaymentsResponse = try await apiClient.performAsync(request)
        guard let order = response.order,
              let remainingAmount = order.remainingAmount,
              remainingAmount.value > 0 else {
            return response.asSubmitResult(paymentMethods: state.paymentMethods)
        }
        let newState = try await updatedState(with: order, result: response)
        state = newState
        return response.asSubmitResult(paymentMethods: newState.paymentMethods)
    }
    
    package func performAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        let request = PaymentDetailsRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            paymentData: data.paymentData,
            details: data.details
        )
        let response: PaymentsResponse = try await apiClient.performAsync(request)
        return try response.asAdditionalDetailsResult()
    }
    
    package func performBalanceCheck(with data: PaymentComponentData) async throws -> Balance {
        let request = BalanceCheckRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            data: data
        )
        let response: BalanceCheckResponse = try await apiClient.performAsync(request)
        guard let availableAmount = response.balance else {
            throw BalanceChecker.Error.zeroBalance
        }
        return Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
    }
    
    package func requestOrder() async throws -> PartialPaymentOrder {
        let request = CreateOrderRequest(
            sessionId: state.identifier,
            sessionData: state.data
        )
        let response: CreateOrderResponse = try await apiClient.performAsync(request)
        return response.order
    }
    
    package func cancelOrder(_ order: PartialPaymentOrder) async {
        let request = CancelOrderRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            order: order
        )
        _ = try? await apiClient.performAsync(request) as CancelOrderResponse
    }
    
    package func disable(storedPaymentMethod: StoredPaymentMethod) async throws {
        let request = DisableStoredPaymentMethodRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            storedPaymentMethodId: storedPaymentMethod.identifier
        )
        _ = try await apiClient.performAsync(request) as EmptyResponse
    }
}

// MARK: - Session State Updates

private extension Session {
    
    func updatedState(with order: PartialPaymentOrder, result: PaymentsResponse) async throws -> State {
        let initialInfo = SessionResponse(
            id: state.identifier,
            sessionData: state.data
        )
        var newState = try await Self.makeSetupCall(
            with: initialInfo,
            baseAPIClient: apiClient,
            order: order
        )
        newState.resultCode = result.resultCode
        newState.sessionResult = result.sessionResult
        return newState
    }
    
    func updateSession(with data: SessionDataAware) {
        state.data = data.sessionData
    }
    
    func updateSession(with result: SessionResultAware) {
        state.resultCode = result.resultCode
        state.sessionResult = result.sessionResult
    }
}

// MARK: - State

extension Session {
    
    /// Current state/information of session that gets updated after each internal call.
    public struct State {
        
        /// The session data.
        public internal(set) var data: String
        
        /// The session identifier
        public let identifier: String
        
        /// Country Code
        public let countryCode: String?
        
        /// Shopper Locale
        public let shopperLocale: String?
        
        /// The payment amount
        public let amount: Amount
        
        /// The payment methods
        public let paymentMethods: PaymentMethods
        
        /// Result code from the latest API call
        internal var resultCode: CheckoutResultCode?
        
        /// Encoded result string from the latest API call
        internal var sessionResult: String?
        
        /// Component related configuration object
        internal let responseConfiguration: SessionSetupResponse.Configuration
    }
}

// MARK: - Component Configuration Awareness

@_spi(AdyenInternal)
extension Session: AdyenSessionAware {
    
    public var isSession: Bool {
        true
    }
}

@_spi(AdyenInternal)
extension Session: InstallmentConfigurationAware {
    
    public var installmentConfiguration: InstallmentConfiguration? {
        state.responseConfiguration.installmentOptions
    }
}

@_spi(AdyenInternal)
extension Session: StorePaymentMethodFieldAware {
    
    public var showStorePaymentMethodField: Bool? {
        state.responseConfiguration.enableStoreDetails
    }
}
