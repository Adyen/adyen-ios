//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// API Client to handle ``Session`` related requests.
/// All session related responses containing `sessionData` require updating the session data of the main `session` property,
/// which is passed as a weak reference to this class.
internal final class SessionAPIClient: AsyncAPIClientProtocol {
    
    private let apiClient: AsyncAPIClientProtocol
    
    /// Closure that is called after a session related API call, to update the session data with the new value.
    private let onSessionDataUpdate: (@MainActor (SessionDataAware) -> Void)?
    
    /// Closure that is called after a session related API call, to update the session result with the new values.
    private let onSessionResultUpdate: (@MainActor (SessionResultAware) -> Void)?
    
    internal init(
        apiClient: AsyncAPIClientProtocol,
        onSessionDataUpdate: (@MainActor (SessionDataAware) -> Void)? = nil,
        onSessionResultUpdate: (@MainActor (SessionResultAware) -> Void)? = nil
    ) {
        self.apiClient = apiClient
        self.onSessionDataUpdate = onSessionDataUpdate
        self.onSessionResultUpdate = onSessionResultUpdate
    }
    
    internal func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> {
        let response = try await apiClient.perform(request)
        let body = response.responseBody
        let onData = onSessionDataUpdate
        let onResult = onSessionResultUpdate
        await MainActor.run {
            if let aware = body as? SessionDataAware {
                onData?(aware)
            }
            if let aware = body as? SessionResultAware {
                onResult?(aware)
            }
        }
        return response
    }
    
    internal func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> where R.ResponseType == DownloadResponse {
        try await apiClient.perform(request)
    }
}
