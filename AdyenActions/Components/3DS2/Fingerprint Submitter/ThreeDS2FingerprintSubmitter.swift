//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyThreeDS2FingerprintSubmitter {
    /// :nodoc:
    func submit(fingerprint: String,
                paymentData: String?,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)
}

/// :nodoc:
internal final class ThreeDS2FingerprintSubmitter: AnyThreeDS2FingerprintSubmitter, Component {

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = APIClient(environment: environment)

    /// :nodoc:
    internal init(apiClient: APIClientProtocol? = nil) {
        if let apiClient = apiClient {
            self.apiClient = apiClient
        }
    }

    /// :nodoc:
    internal func submit(fingerprint: String,
                         paymentData: String?,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Swift.Error>) -> Void) {
        guard let clientKey = clientKey else {
            AdyenAssertion.assert(message: "Client key is missing.")
            completionHandler(.failure(ThreeDS2ComponentError.missingClientKey))
            return
        }
        let request = Submit3DS2FingerprintRequest(clientKey: clientKey,
                                                   fingerprint: fingerprint,
                                                   paymentData: paymentData)

        apiClient.perform(request, completionHandler: { [weak self] result in
            self?.handle(result, completionHandler: completionHandler)
        })
    }

    /// :nodoc:
    private func handle(_ result: Result<Submit3DS2FingerprintResponse, Swift.Error>,
                        completionHandler: (Result<ThreeDSActionHandlerResult, Swift.Error>) -> Void) {
        switch result {
        case let .success(response):
            completionHandler(.success(response.result))
        case let .failure(error):
            completionHandler(.failure(error))
        }
    }
}
