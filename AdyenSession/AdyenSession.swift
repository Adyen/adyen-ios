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
public final class AdyenSession {
    
    /// Session configuration.
    public struct Configuration {
        
        internal let sessionIdentifier: String
        
        internal let initialSessionData: String
        
        internal let context: AdyenContext
        
        internal let actionComponent: AdyenActionComponent.Configuration
        
        /// Initializes a new Configuration object
        ///
        /// - Parameters:
        ///   - sessionIdentifier: The session identifier.
        ///   - initialSessionData: The initial session data.
        ///   - context: The context object for this component.
        ///   - localizationParameters: The localization parameters
        ///   - actionComponent: The action handling configuration.
        public init(sessionIdentifier: String,
                    initialSessionData: String,
                    context: AdyenContext,
                    actionComponent: AdyenActionComponent.Configuration = .init()) {
            self.sessionIdentifier = sessionIdentifier
            self.initialSessionData = initialSessionData
            self.context = context
            self.actionComponent = actionComponent
        }
    }
    
    /// The session information
    public struct Context {
        
        /// The session data.
        public internal(set) var data: String
        
        /// The session identifier
        public let identifier: String
        
        /// Country Code
        public let countryCode: String
        
        /// Shopper Locale
        public let shopperLocale: String?
        
        /// The payment amount
        public let amount: Amount
        
        /// The payment methods
        public let paymentMethods: PaymentMethods
        
        /// Result code from the latest API call
        internal var resultCode: PaymentsResponse.ResultCode?
        
        /// Component related configuration object
        internal let configuration: SessionSetupResponse.Configuration
    }
    
    /// The session context information.
    public internal(set) var sessionContext: Context
    
    /// The presentation delegate.
    public private(set) weak var presentationDelegate: PresentationDelegate?
    
    /// The delegate object.
    public private(set) weak var delegate: AdyenSessionDelegate?
    
    /// Initializes an instance of ``AdyenSession`` asynchronously.
    /// - Parameter configuration: The session configuration.
    /// - Parameter delegate: The session delegate.
    /// - Parameter presentationDelegate: The presentation delegate.
    /// - Parameter completion: The completion closure, that delivers the new instance asynchronously.
    public static func initialize(with configuration: Configuration,
                                  delegate: AdyenSessionDelegate,
                                  presentationDelegate: PresentationDelegate,
                                  completion: @escaping ((Result<AdyenSession, Error>) -> Void)) {
        let baseAPIClient = APIClient(apiContext: configuration.context.apiContext)
            .retryAPIClient(with: SimpleScheduler(maximumCount: 2))
            .retryOnErrorAPIClient()
        initialize(with: configuration,
                   delegate: delegate,
                   presentationDelegate: presentationDelegate,
                   baseAPIClient: baseAPIClient,
                   completion: completion)
    }
    
    internal static func initialize(with configuration: Configuration,
                                    delegate: AdyenSessionDelegate,
                                    presentationDelegate: PresentationDelegate,
                                    baseAPIClient: APIClientProtocol,
                                    completion: @escaping ((Result<AdyenSession, Error>) -> Void)) {
        makeSetupCall(with: configuration,
                      baseAPIClient: baseAPIClient) { result in
            switch result {
            case let .success(sessionContext):
                let session = AdyenSession(configuration: configuration,
                                           sessionContext: sessionContext)
                session.delegate = delegate
                session.presentationDelegate = presentationDelegate
                completion(.success(session))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    internal static func makeSetupCall(with configuration: Configuration,
                                       baseAPIClient: APIClientProtocol,
                                       order: PartialPaymentOrder? = nil,
                                       completion: @escaping ((Result<Context, Error>) -> Void)) {
        let sessionId = configuration.sessionIdentifier
        let sessionData = configuration.initialSessionData
        let request = SessionSetupRequest(sessionId: sessionId,
                                          sessionData: sessionData,
                                          order: order)
        let apiClient = SelfRetainingAPIClient(apiClient: baseAPIClient)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let sessionContext = Context(data: response.sessionData,
                                             identifier: sessionId,
                                             countryCode: response.countryCode,
                                             shopperLocale: response.shopperLocale,
                                             amount: response.amount,
                                             paymentMethods: response.paymentMethods,
                                             configuration: response.configuration)
                completion(.success(sessionContext))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Action Handling for Components

    internal lazy var actionComponent: ActionHandlingComponent = {
        let handler = AdyenActionComponent(context: configuration.context,
                                           configuration: configuration.actionComponent)
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()
    
    // MARK: - Private
    
    internal let configuration: Configuration
    
    internal lazy var apiClient: APIClientProtocol = {
        let apiClient = SessionAPIClient(apiClient: APIClient(apiContext: configuration.context.apiContext), session: self)
        return apiClient
            .retryAPIClient(with: SimpleScheduler(maximumCount: 2))
            .retryOnErrorAPIClient()
    }()
    
    private init(configuration: Configuration, sessionContext: Context) {
        self.sessionContext = sessionContext
        self.configuration = configuration
    }
}

@_spi(AdyenInternal)
extension AdyenSession: AdyenSessionAware {
    
    public var isSession: Bool { true }
}

@_spi(AdyenInternal)
extension AdyenSession: InstallmentConfigurationAware {
    
    public var installmentConfiguration: InstallmentConfiguration? { sessionContext.configuration.installmentOptions }
}

@_spi(AdyenInternal)
extension AdyenSession: StorePaymentMethodFieldAware {
    
    public var showStorePaymentMethodField: Bool? { sessionContext.configuration.enableStoreDetails }
}
