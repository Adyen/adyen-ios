//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

/// API Client to handle ``AdyenSession`` related requests.
/// All session related responses containing `sessionData` require updating the session data of the main `session` property,
/// which is passed as a weak reference to this class.
internal final class SessionAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    /// Closure that is called after a session related API call, to update the session data with the new value.
    private var onSessionDataUpdate: ((SessionDataAware) -> Void)?
    
    /// Closure that is called after a session related API call, to update the session result with the new values.
    private var onSessionResultUpdate: ((SessionResultAware) -> Void)?
    
    internal init(
        apiClient: APIClientProtocol,
        onSessionDataUpdate: ((SessionDataAware) -> Void)? = nil,
        onSessionResultUpdate: ((SessionResultAware) -> Void)? = nil
    ) {
        self.apiClient = apiClient
        self.onSessionDataUpdate = onSessionDataUpdate
        self.onSessionResultUpdate = onSessionResultUpdate
    }
    
    internal func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            // update session context with data and result code if exist
            if let response = try? result.get() {
                if let response = response as? SessionDataAware {
                    self.onSessionDataUpdate?(response)
                }
                if let response = response as? SessionResultAware {
                    self.onSessionResultUpdate?(response)
                }
            }
            completionHandler(result)
        }
    }
}
