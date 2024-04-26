//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions
import Foundation

final class AnyThreeDS2FingerprintSubmitterMock: AnyThreeDS2FingerprintSubmitter {
    var mockedResult: Result<ThreeDSActionHandlerResult, Error>?

    func submit(fingerprint: String, paymentData: String?, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let result = mockedResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
