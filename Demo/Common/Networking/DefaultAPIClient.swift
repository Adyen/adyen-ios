//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

final class DefaultAPIClient: AnyRetryAPIClient {
    
    init(apiContext: AnyAPIContext = DemoAPIContext()) {
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: apiContext),
            scheduler: SimpleScheduler(maximumCount: 2)
        )
    }
    
    let apiClient: RetryAPIClient
    
    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R: Request {
        perform(request, shouldRetry: nil, completionHandler: completionHandler)
    }
    
    func perform<R>(
        _ request: R, shouldRetry: ((Result<R.ResponseType, Error>) -> Bool)?,
        completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void
    ) where R: Request {
        apiClient.perform(request, shouldRetry: {
            if case .failure = $0 {
                return true
            }
            return false
        }, completionHandler: completionHandler)
    }
}
