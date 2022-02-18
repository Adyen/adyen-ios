//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
/// Interface to fetch the client public key.
public protocol AnyPublicKeyProvider: AnyObject {
    
    /// :nodoc:
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    /// :nodoc:
    /// Fetches the client public key with a closure for success and failure.
    func fetch(completion: @escaping CompletionHandler)
}

/// :nodoc:
/// `PublicKeyProvider` is used to fetch the client public key that is needed for encrypting data.
public final class PublicKeyProvider: AnyPublicKeyProvider {

    private let request: ClientKeyRequest

    private let retryApiClient: AnyRetryAPIClient
    
    internal static var publicKeysCache = [String: String]()
    
    private var cachedPublicKey: String? {
        get {
            Self.publicKeysCache[request.clientKey]
        }
        
        set {
            Self.publicKeysCache[request.clientKey] = newValue
        }
    }
    
    /// :nodoc:
    public convenience init(apiContext: APIContext) {
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
    public func fetch(completion: @escaping CompletionHandler) {
        if let publicKey = cachedPublicKey {
            completion(.success(publicKey))
            return
        }
        
        apiClient.perform(request, completionHandler: { [weak self] result in
            DispatchQueue.main.async {
                self?.handle(result, completion: completion)
            }
        })
    }
    
    // MARK: - Private
    
    private lazy var apiClient: UniqueAssetAPIClient<ClientKeyResponse> = {
        let retryOnErrorApiClient = retryApiClient.retryOnErrorAPIClient()
        return UniqueAssetAPIClient<ClientKeyResponse>(apiClient: retryOnErrorApiClient)
    }()
    
    private func handle(_ result: Result<ClientKeyResponse, Swift.Error>, completion: @escaping CompletionHandler) {
        switch result {
        case let .success(response):
            cachedPublicKey = response.cardPublicKey
            completion(.success(response.cardPublicKey))
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
