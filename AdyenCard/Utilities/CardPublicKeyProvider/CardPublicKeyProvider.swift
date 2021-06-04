//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyCardPublicKeyProvider: APIContextAware {
    
    /// :nodoc:
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    /// :nodoc:
    func fetch(completion: @escaping CompletionHandler)
}

/// :nodoc:
internal final class CardPublicKeyProvider: AnyCardPublicKeyProvider {
    
    /// :nodoc:
    internal let apiContext: APIContext
    
    /// :nodoc:
    internal static var cachedCardPublicKey: String?
    
    /// :nodoc:
    internal init(apiContext: APIContext,
                  apiClient: AnyRetryAPIClient? = nil) {
        self.apiContext = apiContext
        if let apiClient = apiClient {
            self.retryApiClient = apiClient
        }
    }
    
    /// :nodoc:
    internal func fetch(completion: @escaping CompletionHandler) {
        if let cardPublicKey = Self.cachedCardPublicKey {
            completion(.success(cardPublicKey))
            return
        }
        
        let request = ClientKeyRequest(clientKey: apiContext.clientKey)
        
        apiClient.perform(request, completionHandler: { [weak self] result in
            self?.handle(result, completion: completion)
        })
    }
    
    /// :nodoc:
    private func handle(_ result: Result<ClientKeyResponse, Swift.Error>, completion: @escaping CompletionHandler) {
        switch result {
        case let .success(response):
            Self.cachedCardPublicKey = response.cardPublicKey
            completion(.success(response.cardPublicKey))
        case let .failure(error):
            completion(.failure(error))
        }
    }

    /// :nodoc:
    private lazy var apiClient: UniqueAssetAPIClient<ClientKeyResponse> = {
        let retryOnErrorApiClient = retryApiClient.retryOnErrorAPIClient()
        return UniqueAssetAPIClient<ClientKeyResponse>(apiClient: retryApiClient)
    }()

    private lazy var retryApiClient: AnyRetryAPIClient = {
        RetryAPIClient(apiClient: APIClient(apiContext: apiContext),
                       scheduler: SimpleScheduler(maximumCount: 2))
    }()
}
