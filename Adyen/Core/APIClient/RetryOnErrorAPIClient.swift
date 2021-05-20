//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// An API Client that enables retying request on error.
public final class RetryOnErrorAPIClient: APIClientProtocol {

    /// :nodoc:
    private let apiClient: AnyRetryAPIClient

    /// :nodoc:
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    public init(apiClient: AnyRetryAPIClient) {
        self.apiClient = apiClient
    }

    /// :nodoc:
    public func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request, shouldRetry: { result in
            switch result {
            case .success:
                return false
            case .failure:
                return true
            }
        }, completionHandler: completionHandler)
    }

}
