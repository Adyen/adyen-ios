//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package protocol PublicKeyFetching {
    func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String) async throws -> String
}

package protocol APIClientKeyRequestProtocol {
    func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, Error>) -> Void)
}

package final class PublicKeyFetcher: PublicKeyFetching {
    package init() {}

    package func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String) async throws -> String {
        let request = ClientKeyRequest(clientKey: clientKey)
        do {
            let response: ClientKeyResponse = try await withCheckedThrowingContinuation { continuation in
                apiClient.perform(request: request) { result in
                    continuation.resume(with: result)
                }
            }
            return response.cardPublicKey
        } catch is DecodingError {
            // Disclaimer: This error check is not 100% reliable. Need to improve the endpoint.
            throw PublicKeyFetcherError.invalidClientKey
        } catch {
            throw error
        }
    }

    public enum PublicKeyFetcherError: Swift.Error, LocalizedError {
        case invalidClientKey

        public var errorDescription: String? {
            "Client key not found on the selected environment."
        }
    }
}

internal struct UniqueAssetAPIClientAdaptor: APIClientKeyRequestProtocol {
    internal func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, any Error>) -> Void) {
        apiClient.perform(request, completionHandler: completionHandler)
    }
    
    private let apiClient: UniqueAssetAPIClient<ClientKeyResponse>

    internal init(uniqueAssetAPIClient: UniqueAssetAPIClient<ClientKeyResponse>) {
        self.apiClient = uniqueAssetAPIClient
    }
}

extension APIClient: APIClientKeyRequestProtocol {
    package func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, any Error>) -> Void) {
        self.perform(request, completionHandler: completionHandler)
    }
}
