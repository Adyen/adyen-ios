//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
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
    private let request: ClientKeyRequest

    /// :nodoc:
    private let retryApiClient: AnyRetryAPIClient
    
    /// :nodoc:
    internal static var cachedCardPublicKey: String?
    
    /// :nodoc:
    internal convenience init(apiContext: APIContext) {
        let scheduler = SimpleScheduler(maximumCount: 2)
        self.init(apiClient: APIClient(apiContext: apiContext).retryAPIClient(with: scheduler),
                  request: ClientKeyRequest(clientKey: apiContext.clientKey))
    }

    /// :nodoc:
    /// For testing only
    internal init(apiClient: AnyRetryAPIClient, request: ClientKeyRequest) {
        self.retryApiClient = apiClient
        self.request = request
    }
    
    /// :nodoc:
    internal func fetch(completion: @escaping CompletionHandler) {
        if let cardPublicKey = Self.cachedCardPublicKey {
            completion(.success(cardPublicKey))
            return
        }
        
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
