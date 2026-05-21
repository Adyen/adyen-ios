//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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
    
    private let apiClient: AsyncAPIClientProtocol
    
    private let context: AdyenContext

    internal init(context: AdyenContext, apiClient: AsyncAPIClientProtocol? = nil) {
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

        Task { @MainActor in
            do {
                let response: Submit3DS2FingerprintResponse = try await apiClient.performAsync(request)
                completionHandler(.success(response.result))
            } catch {
                sendApiErrorEvent()
                completionHandler(.failure(error))
            }
        }
    }
    
    private func sendApiErrorEvent() {
        var errorEvent = AnalyticsEventError(component: Constants.fingerprintEvent, type: .api)
        errorEvent.code = AnalyticsConstants.ErrorCode.apiErrorThreeDS2.stringValue
        context.analyticsProvider?.add(error: errorEvent)
    }
}
