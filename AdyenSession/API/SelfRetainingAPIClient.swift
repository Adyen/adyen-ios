//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
/// An API Client that retains its self until destroyed manually.
internal final class SelfRetainingAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    private var instance: APIClientProtocol?
    
    internal var onDeinit: (() -> Void)?
    
    deinit {
        onDeinit?()
    }
    
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        self.instance = self
    }
    
    internal func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request) { [weak self] in
            completionHandler($0)
            self?.destroy()
        }
    }
    
    /// Destroy the retain cycle to enable `self` to be deallocated.
    private func destroy() {
        instance = nil
    }
}
