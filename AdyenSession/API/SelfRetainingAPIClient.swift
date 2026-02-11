//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

/// An API Client that retains itself by implicit self capturing until the closure executed.
internal final class SelfRetainingAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    internal func perform<R: Request>(
        _ request: R,
        completionHandler: @escaping CompletionHandler<R.ResponseType>
    ) {
        apiClient.perform(request) {
            completionHandler($0)
        }
    }
}
