//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Interface to fetch the client public key.
@_spi(AdyenInternal)
public protocol AnyPublicKeyProvider: AnyObject {
    
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    /// Fetches the client public key with a closure for success and failure.
    func fetch(completion: @escaping CompletionHandler)
}

// TODO: Robert: This needs to be deleted.
/// `PublicKeyProvider` is used to fetch the client public key that is needed for encrypting data.
/// It adds caching and retry logic on top of `PublicKeyFetcher`, using `UniqueAssetAPIClient` for request deduplication.
@available(
    *,
    deprecated,
    message: "This needs to be deleted, we now will depend on the public key that is fetched in `CheckoutProvider`"
)
package final class PublicKeyProvider: AnyPublicKeyProvider {

    private let fetcher: PublicKeyFetching

    private let clientKey: String

    private let apiClient: APIClientKeyRequestProtocol

    internal static var publicKeysCache = [String: String]()
    
    private var cachedPublicKey: String? {
        get {
            Self.publicKeysCache[clientKey]
        }
        
        set {
            Self.publicKeysCache[clientKey] = newValue
        }
    }
    
    public convenience init(apiContext: APIContext) {
        let scheduler = SimpleScheduler(maximumCount: 2)
        let retryApiClient = APIClient(apiContext: apiContext).retryAPIClient(with: scheduler)
        let retryOnErrorApiClient = retryApiClient.retryOnErrorAPIClient()
        self.init(
            apiClient: retryOnErrorApiClient,
            clientKey: apiContext.clientKey
        )
    }

    /// For testing only
    internal init(apiClient: APIClientProtocol, clientKey: String) {
        self.fetcher = PublicKeyFetcher()
        let uniqueAssetAPIClient = UniqueAssetAPIClient<ClientKeyResponse>(apiClient: apiClient)
        self.apiClient = uniqueAssetAPIClient
        self.clientKey = clientKey
    }

    public func fetch(completion: @escaping CompletionHandler) {
        if let publicKey = cachedPublicKey {
            completion(.success(publicKey))
            return
        }

        fetcher.fetchPublicKey(apiClient: apiClient, clientKey: clientKey) { [weak self] result in
            switch result {
            case let .success(publicKey):
                DispatchQueue.main.async {
                    self?.cachedPublicKey = publicKey
                    completion(.success(publicKey))
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
