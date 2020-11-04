//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyThreeDS2FingerprintSubmitter {
    /// :nodoc:
    func submit(fingerprint: String,
                paymentData: String,
                completionHandler: @escaping (Result<Action?, Error>) -> Void)
}

/// :nodoc:
internal final class ThreeDS2FingerprintSubmitter: AnyThreeDS2FingerprintSubmitter, Component {

    /// :nodoc:
    private lazy var apiClient: AnyRetryAPIClient = RetryAPIClient(apiClient: APIClient(environment: environment),
                                                                   scheduler: SimpleScheduler(maximumCount: 2))

    /// :nodoc:
    internal init(apiClient: AnyRetryAPIClient? = nil) {
        if let apiClient = apiClient {
            self.apiClient = apiClient
        }
    }

    /// :nodoc:
    internal func submit(fingerprint: String,
                         paymentData: String,
                         completionHandler: @escaping (Result<Action?, Swift.Error>) -> Void) {
        guard let clientKey = clientKey else {
            assertionFailure("Client key is missing.")
            completionHandler(.failure(ThreeDS2ComponentError.missingClientKey))
            return
        }
        let request = Submit3DS2FingerprintRequest(clientKey: clientKey,
                                                   fingerprint: fingerprint,
                                                   paymentData: paymentData)

        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result) ?? false
        }, completionHandler: { [weak self] result in
            self?.handle(result, completionHandler: completionHandler)
        })
    }

    /// :nodoc:
    private func shouldRetry(_ result: Result<Submit3DS2FingerprintResponse, Swift.Error>) -> Bool {
        if case Result.success = result {
            return false
        }
        return true
    }

    /// :nodoc:
    private func handle(_ result: Result<Submit3DS2FingerprintResponse, Swift.Error>,
                        completionHandler: (Result<Action?, Swift.Error>) -> Void) {
        switch result {
        case let .success(response):
            completionHandler(.success(response.action))
        case let .failure(error):
            completionHandler(.failure(error))
        }
    }
}
