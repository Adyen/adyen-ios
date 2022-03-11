//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import AdyenNetworking
import Foundation

/// The Session object.
public final class Session: SessionProtocol {
    
    /// Session configuration.
    public struct Configuration {
        
        internal let sessionIdentifier: String
        
        internal let initialSessionData: String
        
        internal let apiContext: APIContext
        
        /// Initializes a new Configuration object
        ///
        /// - Parameters:
        ///   - apiContext: The API context.
        public init(sessionIdentifier: String,
                    initialSessionData: String,
                    apiContext: APIContext) {
            self.sessionIdentifier = sessionIdentifier
            self.initialSessionData = initialSessionData
            self.apiContext = apiContext
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
        public let shopperLocale: String
        
        /// The payment amount
        public let amount: Amount
        
        /// The payment methods
        public let paymentMethods: PaymentMethods
    }
    
    /// The session context information.
    public internal(set) var sessionContext: Context
    
    /// The presentation delegate.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Initializes an instance of `Session` asynchronously.
    /// - Parameter configuration: The session configuration.
    /// - Parameter completion: The completion closure, that delivers the new instance asynchronously.
    public static func initialize(with configuration: Configuration,
                                  completion: @escaping ((Result<Session, Error>) -> Void)) {
        let baseAPIClient = APIClient(apiContext: configuration.apiContext)
            .retryAPIClient(with: SimpleScheduler(maximumCount: 3))
            .retryOnErrorAPIClient()
        initialize(with: configuration,
                   baseAPIClient: baseAPIClient,
                   completion: completion)
    }
    
    internal static func initialize(with configuration: Configuration,
                                    baseAPIClient: APIClientProtocol,
                                    completion: @escaping ((Result<Session, Error>) -> Void)) {
        makeSetupCall(with: configuration,
                      baseAPIClient: baseAPIClient) { result in
            switch result {
            case let .success(sessionContext):
                let session = Session(configuration: configuration,
                                      sessionContext: sessionContext)
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
                                             paymentMethods: response.paymentMethods)
                completion(.success(sessionContext))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func didFail(with error: Error, from dropInComponent: Component) {
        // TODO: Call back merchant
    }
    
    // MARK: - Action Handling for Components

    internal lazy var actionComponent: ActionHandlingComponent = {
        let handler = AdyenActionComponent(apiContext: configuration.apiContext)
        handler.delegate = self
        handler.presentationDelegate = presentationDelegate
        return handler
    }()
    
    // MARK: - Private
    
    internal let configuration: Configuration
    
    internal lazy var apiClient: APIClientProtocol = {
        APIClient(apiContext: configuration.apiContext)
            .retryAPIClient(with: SimpleScheduler(maximumCount: 2))
            .retryOnErrorAPIClient()
    }()
    
    private init(configuration: Configuration, sessionContext: Context) {
        self.sessionContext = sessionContext
        self.configuration = configuration
    }
}
