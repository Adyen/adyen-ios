//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyCardPublicKeyProvider: AnyObject {
    
    /// :nodoc:
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    /// :nodoc:
    func fetch(completion: @escaping CompletionHandler)
}

/// :nodoc:
internal final class CardPublicKeyProvider: AnyCardPublicKeyProvider {

    /// :nodoc:
    private let clientKey: String

    /// :nodoc:
    private let retryApiClient: AnyRetryAPIClient
    
    /// :nodoc:
    internal static var cachedCardPublicKey: String?
    
    /// :nodoc:
    internal init(apiContext: APIContext) {
        let scheduler = SimpleScheduler(maximumCount: 2)
        self.retryApiClient = APIClient(apiContext: apiContext)
            .retryAPIClient(with: scheduler)
        self.clientKey = apiContext.clientKey
    }

    /// :nodoc:
    internal init(apiClient: AnyRetryAPIClient, clientKey: String) {
        self.retryApiClient = apiClient
        self.clientKey = clientKey
    }
    
    /// :nodoc:
    internal func fetch(completion: @escaping CompletionHandler) {
        if let cardPublicKey = Self.cachedCardPublicKey {
            completion(.success(cardPublicKey))
            return
        }
        
        let request = ClientKeyRequest(clientKey: clientKey)
        
        apiClient.perform(request, completionHandler: { [weak self] result in
            self?.handle(result, completion: completion)
        })
    }
    
    // MARK: - Private
    
    /// :nodoc:
    private lazy var apiClient: UniqueAssetAPIClient<ClientKeyResponse> = {
        let retryOnErrorApiClient = retryApiClient.retryOnErrorAPIClient()
        return UniqueAssetAPIClient<ClientKeyResponse>(apiClient: retryOnErrorApiClient)
    }()
    
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
}
