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
        
        internal let sessionIdenitifier: String
        
        internal let initialSessionData: String
        
        internal let apiContext: APIContext
        
        /// Initializes a new Configuration object
        ///
        /// - Parameters:
        ///   - apiContext: The API context.
        public init(sessionIdenitifier: String,
                    initialSessionData: String,
                    apiContext: APIContext) {
            self.sessionIdenitifier = sessionIdenitifier
            self.initialSessionData = initialSessionData
            self.apiContext = apiContext
        }
    }
    
    /// The session information
    public struct Context {
        
        /// The session data.
        public internal(set) var data: String
        
        /// The session idenitifier
        public let idenitifier: String
        
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
    
    /// Initializes an instance of `Session` asynchronously.
    /// - Parameter completion: The completion closure, that delivers the new instance.
    public static func initialize(with configuration: Configuration,
                                  completion: @escaping ((Result<Session, Error>) -> Void)) {
        let sessionId = configuration.sessionIdenitifier
        let sessionData = configuration.initialSessionData
        let request = SessionSetupRequest(sessionId: sessionId,
                                          sessionData: sessionData)
        let baseAPIClient = APIClient(apiContext: configuration.apiContext)
            .retryAPIClient(with: SimpleScheduler(maximumCount: 3))
            .retryOnErrorAPIClient()
        let apiClient = SelfRetainingAPIClient(apiClient: baseAPIClient)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let sessionContext = Context(data: response.sessionData,
                                             idenitifier: sessionId,
                                             countryCode: response.countryCode,
                                             shopperLocale: response.shopperLocale,
                                             amount: response.amount,
                                             paymentMethods: response.paymentMethods)
                let session = Session(configuration: configuration,
                                      sessionContext: sessionContext)
                completion(.success(session))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func didFail(with error: Error, from dropInComponent: Component) {
        // TODO: Call back merchant
    }
    
    // MARK: - Private
    
    private let configuration: Configuration
    
    internal lazy var apiClient: APIClientProtocol = {
        APIClient(apiContext: configuration.apiContext)
            .retryAPIClient(with: SimpleScheduler(maximumCount: 2))
    }()
    
    private init(configuration: Configuration, sessionContext: Context) {
        self.sessionContext = sessionContext
        self.configuration = configuration
    }
}
