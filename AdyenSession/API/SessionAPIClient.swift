//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

/// API Client to handle ``Session`` related requests.
/// All session related responses containing `sessionData` require updating the session data of the main `session` property,
/// which is passed as a weak reference to this class.
internal final class SessionAPIClient: AsyncAPIClientProtocol {
    
    private let apiClient: AsyncAPIClientProtocol
    
    /// Closure that is called after a session related API call, to update the session data with the new value.
    private var onSessionDataUpdate: ((SessionDataAware) -> Void)?
    
    /// Closure that is called after a session related API call, to update the session result with the new values.
    private var onSessionResultUpdate: ((SessionResultAware) -> Void)?
    
    internal init(
        apiClient: AsyncAPIClientProtocol,
        onSessionDataUpdate: ((SessionDataAware) -> Void)? = nil,
        onSessionResultUpdate: ((SessionResultAware) -> Void)? = nil
    ) {
        self.apiClient = apiClient
        self.onSessionDataUpdate = onSessionDataUpdate
        self.onSessionResultUpdate = onSessionResultUpdate
    }
    
    internal func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> {
        let response = try await apiClient.perform(request)
        updateSession(with: response.responseBody)
        return response
    }
    
    internal func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> where R.ResponseType == DownloadResponse {
        try await apiClient.perform(request)
    }
    
    private func updateSession(with response: Any) {
        if let response = response as? SessionDataAware {
            onSessionDataUpdate?(response)
        }
        if let response = response as? SessionResultAware {
            onSessionResultUpdate?(response)
        }
    }
}
