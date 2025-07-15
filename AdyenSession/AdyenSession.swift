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

/// ``AdyenSession`` acts as the delegate for the checkout payment flow.
/// It can handle the required steps internally such as `/payments` and `/payment/details`
/// calls and partial payment calls, then provide feedback
/// via ``AdyenSessionDelegate`` methods.
public final class AdyenSession: AdyenSessionProtocol {
    
    /// The session context information.
    public internal(set) var sessionContext: AdyenSession.Context
    
    /// The presentation delegate.
    public package(set) weak var presentationDelegate: PresentationDelegate?
    
    /// The delegate object.
    public package(set) weak var delegate: AdyenSessionDelegate?
    
    internal let context: AdyenContext
    
    // Session's API client should be only of SessionAPIClient type
    // in order to update session data/result after each internal API call.
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
    
    internal lazy var actionHandlingComponent: ActionHandlingComponent = {
        let handler = AdyenActionComponent(
            context: context,
            configuration: AdyenActionComponent.Configuration()
        )
        // TODO: create a way for CheckoutConfig to have AdyenActionComponent.Configuration
        // and it should provided if they want to have action handling
        // move AdyenActionComponent.Configuration to its own entity and make it public
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()
    
    /// The injected API client to be used by the session's API client.
    private let baseAPIClient: APIClientProtocol
    
    internal init(
        sessionContext: AdyenSession.Context,
        baseAPIClient: APIClientProtocol,
        context: AdyenContext,
        delegate: AdyenSessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.sessionContext = sessionContext
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
        self.baseAPIClient = baseAPIClient
        self.context = context
    }
    
    // swiftlint:disable function_parameter_count
    /// Initializes an instance of ``AdyenSession`` asynchronously.
    /// - Parameter model: The session setup model.
    /// - Parameter apiClient: The api client object for network calls.
    /// - Parameter actionHandlingComponent: Action component to handle actions.
    /// - Parameter delegate: The session delegate.
    /// - Parameter presentationDelegate: The presentation delegate.
    /// - Parameter completion: The completion closure, that delivers the new instance asynchronously.
    public static func setup(
        with model: AdyenSession.SetupModel,
        apiClient: APIClientProtocol,
        context: AdyenContext,
        delegate: AdyenSessionDelegate?,
        presentationDelegate: PresentationDelegate?,
        completion: @escaping ((Result<AdyenSession, Error>) -> Void)
    ) {
        makeSetupCall(
            with: model,
            baseAPIClient: apiClient
        ) { result in
            switch result {
            case let .success(sessionContext):
                let session = AdyenSession(
                    sessionContext: sessionContext,
                    baseAPIClient: apiClient,
                    context: context,
                    delegate: delegate,
                    presentationDelegate: presentationDelegate
                )
                session.delegate = delegate
                session.presentationDelegate = presentationDelegate
                AnalyticsForSession.sessionId = sessionContext.identifier
                completion(.success(session))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // swiftlint:enable function_parameter_count
    
    internal static func makeSetupCall(
        with model: AdyenSession.SetupModel,
        baseAPIClient: APIClientProtocol,
        order: PartialPaymentOrder? = nil,
        completion: @escaping ((Result<Context, Error>) -> Void)
    ) {
        let sessionId = model.sessionIdentifier
        let sessionData = model.initialSessionData
        let request = SessionSetupRequest(
            sessionId: sessionId,
            sessionData: sessionData,
            order: order
        )

        let apiClient = SelfRetainingAPIClient(apiClient: baseAPIClient)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let sessionContext = Context(
                    data: response.sessionData,
                    identifier: sessionId,
                    countryCode: response.countryCode,
                    shopperLocale: response.shopperLocale,
                    amount: response.amount,
                    paymentMethods: response.paymentMethods,
                    responseConfiguration: response.configuration
                )
                completion(.success(sessionContext))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private func updateSession(with data: SessionDataAware) {
        sessionContext.data = data.sessionData
    }
    
    private func updateSession(with result: SessionResultAware) {
        sessionContext.resultCode = result.resultCode
        sessionContext.sessionResult = result.sessionResult
    }
}

extension AdyenSession {
    
    /// The session context information.
    public internal(set) var sessionContext: Context
    
    /// The presentation delegate.
    public package(set) weak var presentationDelegate: PresentationDelegate?
    
    /// The delegate object.
    public package(set) weak var delegate: AdyenSessionDelegate?
    
    internal let configuration: Configuration
    
    // Session's API client should be only of SessionAPIClient type
    // in order to update session data/result after each internal API call.
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
    
    internal var actionHandlingComponent: ActionHandlingComponent
    
    /// The injected API client to be used by the session's API client.
    private let baseAPIClient: APIClientProtocol
    
    internal init(
        configuration: Configuration,
        sessionContext: Context,
        baseAPIClient: APIClientProtocol,
        actionHandlingComponent: ActionHandlingComponent,
        delegate: AdyenSessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.configuration = configuration
        self.sessionContext = sessionContext
        self.actionHandlingComponent = actionHandlingComponent
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
        self.baseAPIClient = baseAPIClient
    }
    
    // swiftlint:disable function_parameter_count
    /// Initializes an instance of ``AdyenSession`` asynchronously.
    /// - Parameter configuration: The session configuration.
    /// - Parameter apiClient: The api client object for network calls.
    /// - Parameter actionHandlingComponent: Action component to handle actions.
    /// - Parameter delegate: The session delegate.
    /// - Parameter presentationDelegate: The presentation delegate.
    /// - Parameter completion: The completion closure, that delivers the new instance asynchronously.
    public static func setup(
        with configuration: Configuration,
        apiClient: APIClientProtocol,
        actionHandlingComponent: ActionHandlingComponent,
        delegate: AdyenSessionDelegate?,
        presentationDelegate: PresentationDelegate?,
        completion: @escaping ((Result<AdyenSession, Error>) -> Void)
    ) {
        makeSetupCall(
            with: configuration,
            baseAPIClient: apiClient
        ) { result in
            switch result {
            case let .success(sessionContext):
                let session = AdyenSession(
                    configuration: configuration,
                    sessionContext: sessionContext,
                    baseAPIClient: apiClient,
                    actionHandlingComponent: actionHandlingComponent,
                    delegate: delegate,
                    presentationDelegate: presentationDelegate
                )
                session.delegate = delegate
                session.presentationDelegate = presentationDelegate
                AnalyticsForSession.sessionId = sessionContext.identifier
                completion(.success(session))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // swiftlint:enable function_parameter_count
    
    internal static func makeSetupCall(
        with configuration: Configuration,
        baseAPIClient: APIClientProtocol,
        order: PartialPaymentOrder? = nil,
        completion: @escaping ((Result<Context, Error>) -> Void)
    ) {
        let sessionId = configuration.sessionIdentifier
        let sessionData = configuration.initialSessionData
        let request = SessionSetupRequest(
            sessionId: sessionId,
            sessionData: sessionData,
            order: order
        )

        let apiClient = SelfRetainingAPIClient(apiClient: baseAPIClient)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let sessionContext = Context(
                    data: response.sessionData,
                    identifier: sessionId,
                    countryCode: response.countryCode,
                    shopperLocale: response.shopperLocale,
                    amount: response.amount,
                    paymentMethods: response.paymentMethods,
                    responseConfiguration: response.configuration
                )
                completion(.success(sessionContext))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private func updateSession(with data: SessionDataAware) {
        sessionContext.data = data.sessionData
    }
    
    private func updateSession(with result: SessionResultAware) {
        sessionContext.resultCode = result.resultCode
        sessionContext.sessionResult = result.sessionResult
    }
}

extension AdyenSession {
    
    // TODO: remove adyen context and action config from this
    /// Session configuration.
    public struct SetupModel {
        
        internal let sessionIdentifier: String
        
        internal let initialSessionData: String
        
        /// Initializes a new Configuration object
        ///
        /// - Parameters:
        ///   - sessionIdentifier: The session identifier.
        ///   - initialSessionData: The initial session data.
        public init(
            sessionIdentifier: String,
            initialSessionData: String
        ) {
            self.sessionIdentifier = sessionIdentifier
            self.initialSessionData = initialSessionData
        }
    }
    
    /// The session information
    public struct Context {
        
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
extension AdyenSession: AdyenSessionAware {
    
    public var isSession: Bool { true }
}

@_spi(AdyenInternal)
extension AdyenSession: InstallmentConfigurationAware {
    
    public var installmentConfiguration: InstallmentConfiguration? { sessionContext.responseConfiguration.installmentOptions }
}

@_spi(AdyenInternal)
extension AdyenSession: StorePaymentMethodFieldAware {
    
    public var showStorePaymentMethodField: Bool? { sessionContext.responseConfiguration.enableStoreDetails }
}
