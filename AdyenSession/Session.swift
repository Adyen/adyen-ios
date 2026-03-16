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
    private let baseAPIClient: APIClientProtocol
    
    internal init(
        state: Session.State,
        baseAPIClient: APIClientProtocol,
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
    
    /// Initializes an instance of ``Session`` asynchronously.
    /// - Parameter sessionResponse: The session setup initial data.
    /// - Parameter apiClient: The api client object for network calls.
    /// - Parameter context: The context object for the session.
    /// - Returns: A configured Session instance.
    /// - Throws: An error if the session setup fails.
    package static func setup(
        with sessionResponse: SessionResponse,
        apiClient: APIClientProtocol,
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
        baseAPIClient: APIClientProtocol,
        order: PartialPaymentOrder? = nil
    ) async throws -> State {
        
        let sessionId = sessionResponse.id
        let sessionData = sessionResponse.sessionData
        
        let request = SessionSetupRequest(
            sessionId: sessionId,
            sessionData: sessionData,
            order: order
        )
        
        let response = try await withCheckedThrowingContinuation { continuation in
            baseAPIClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }
        
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
    
    // MARK: - Private
    
    private func updateSession(with data: SessionDataAware) {
        state.data = data.sessionData
    }
    
    private func updateSession(with result: SessionResultAware) {
        state.resultCode = result.resultCode
        state.sessionResult = result.sessionResult
    }
}

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
