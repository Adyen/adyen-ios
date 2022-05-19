//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

/// An API Client that retains its self until destroyed manually or request is concluded.
internal final class SelfRetainingAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    private var instance: APIClientProtocol?
    
    /// For Testing only
    internal var onDeinit: (() -> Void)?
    
    private var retainCount: Int = 0
    
    deinit {
        onDeinit?()
    }
    
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    internal func perform<R>(_ request: R,
                             completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        AdyenAssertion.assert(message: "This function must be called on the main thread",
                              condition: !Thread.isMainThread)
        instance = self
        retainCount += 1
        apiClient.perform(request) { [weak self] in
            completionHandler($0)
            self?.destroyIfNeeded()
        }
    }
    
    /// Destroy the retain cycle to enable `self` to be deallocated.
    private func destroyIfNeeded() {
        AdyenAssertion.assert(message: "This function must be called on the main thread",
                              condition: !Thread.isMainThread)
        retainCount -= 1
        
        if retainCount == 0 {
            instance = nil
        }
    }
}
