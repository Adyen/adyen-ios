//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal final class DefaultAPIClient: AnyRetryAPIClient {
    
    internal init(apiContext: AnyAPIContext = DemoAPIContext()) {
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: apiContext),
            scheduler: SimpleScheduler(maximumCount: 2)
        )
    }
    
    internal let apiClient: RetryAPIClient
    
    internal func perform<R: Request>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) {
        perform(request, shouldRetry: nil, completionHandler: completionHandler)
    }
    
    internal func perform<R: Request>(
        _ request: R,
        shouldRetry: ((Result<R.ResponseType, Error>) -> Bool)?,
        completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void
    ) {
        apiClient.perform(request, shouldRetry: {
            if case .failure = $0 {
                return true
            }
            return false
        }, completionHandler: completionHandler)
    }
}
