//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
internal protocol AnyThreeDS2FingerprintSubmitter {
    /// :nodoc:
    func submit(fingerprint: String,
                paymentData: String?,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)
}

/// :nodoc:
internal final class ThreeDS2FingerprintSubmitter: AnyThreeDS2FingerprintSubmitter {
    
    /// :nodoc:
    private let apiClient: APIClientProtocol
    
    /// :nodoc:
    private let apiContext: APIContext

    /// :nodoc:
    internal init(apiContext: APIContext, apiClient: APIClientProtocol? = nil) {
        self.apiContext = apiContext
        self.apiClient = apiClient ?? APIClient(apiContext: apiContext)
    }

    /// :nodoc:
    internal func submit(fingerprint: String,
                         paymentData: String?,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Swift.Error>) -> Void) {

        let request = Submit3DS2FingerprintRequest(clientKey: apiContext.clientKey,
                                                   fingerprint: fingerprint,
                                                   paymentData: paymentData)

        apiClient.perform(request, completionHandler: { [weak self] result in
            self?.handle(result, completionHandler: completionHandler)
        })
    }

    /// :nodoc:
    private func handle(_ result: Result<Submit3DS2FingerprintResponse, Swift.Error>,
                        completionHandler: (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        switch result {
        case let .success(response):
            completionHandler(.success(response.result))
        case let .failure(error):
            completionHandler(.failure(error))
        }
    }
}
