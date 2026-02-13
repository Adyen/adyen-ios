//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package protocol PublicKeyFetching {
    /// Retaining a completion handler interface as this is needed for the PublicKeyProvider to ensure that only one request is being sent through the apiClient even if there are multiple callers.
    /// We can remove this when we remove `PublicKeyProvider`
    func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String, completion: @escaping (Result<String, Error>) -> Void)
    func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String) async throws -> String
}

// sourcery:AutoMockable
package protocol APIClientKeyRequestProtocol {
    func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, Error>) -> Void)
}

package final class PublicKeyFetcher: PublicKeyFetching {
    package init() {}

    package func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = ClientKeyRequest(clientKey: clientKey)
        apiClient.perform(request: request) { result in
            switch result {
            case let .success(response):
                completion(.success(response.cardPublicKey))
            case let .failure(error):
                if error is DecodingError {
                    completion(.failure(PublicKeyFetcherError.invalidClientKey))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    package func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchPublicKey(apiClient: apiClient, clientKey: clientKey) { result in
                continuation.resume(with: result)
            }
        }
    }

    public enum PublicKeyFetcherError: Swift.Error, LocalizedError {
        case invalidClientKey

        public var errorDescription: String? {
            "Client key not found on the selected environment."
        }
    }
}

extension UniqueAssetAPIClient: APIClientKeyRequestProtocol where ResponseType == ClientKeyResponse {
    package func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, any Error>) -> Void) {
        self.perform(request, completionHandler: completionHandler)
    }
}

extension APIClient: APIClientKeyRequestProtocol {
    package func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, any Error>) -> Void) {
        self.perform(request, completionHandler: completionHandler)
    }
}
