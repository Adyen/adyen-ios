//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal protocol AnyThreeDS2FingerprintSubmitter {
    func submit(
        fingerprint: String,
        paymentData: String?,
        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void
    )
}

internal final class ThreeDS2FingerprintSubmitter: AnyThreeDS2FingerprintSubmitter {
    
    private enum Constants {
        static let fingerprintEvent = "threeDS2Fingerprint"
    }
    
    private let apiClient: APIClientProtocol
    
    private let context: AdyenContext

    internal init(context: AdyenContext, apiClient: APIClientProtocol? = nil) {
        self.context = context
        self.apiClient = apiClient ?? APIClient(apiContext: context.apiContext)
    }

    internal func submit(
        fingerprint: String,
        paymentData: String?,
        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Swift.Error>) -> Void
    ) {

        let request = Submit3DS2FingerprintRequest(
            clientKey: context.apiContext.clientKey,
            fingerprint: fingerprint,
            paymentData: paymentData
        )

        apiClient.perform(request, completionHandler: { [weak self] result in
            self?.handle(result, completionHandler: completionHandler)
        })
    }

    private func handle(
        _ result: Result<Submit3DS2FingerprintResponse, Swift.Error>,
        completionHandler: (Result<ThreeDSActionHandlerResult, Swift.Error>) -> Void
    ) {
        switch result {
        case let .success(response):
            completionHandler(.success(response.result))
        case let .failure(error):
            sendApiErrorEvent()
            completionHandler(.failure(error))
        }
    }
    
    private func sendApiErrorEvent() {
        var errorEvent = AnalyticsEventError(component: Constants.fingerprintEvent, type: .api)
        errorEvent.code = AnalyticsConstants.ErrorCode.apiErrorThreeDS2.stringValue
        context.analyticsProvider?.add(error: errorEvent)
    }
}
