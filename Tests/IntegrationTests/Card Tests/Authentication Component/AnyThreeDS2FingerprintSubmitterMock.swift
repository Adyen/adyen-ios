//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import Foundation

final class AnyThreeDS2FingerprintSubmitterMock: AnyThreeDS2FingerprintSubmitter {
    var mockedResult: Result<ThreeDSActionHandlerResult, Error>?
    var onSubmitFingerprint: (
        (
            String, String?, @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void
        ) -> Void
    )?
    
    func submit(fingerprint: String, paymentData: String?, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        if let onSubmitFingerprint {
            onSubmitFingerprint(fingerprint, paymentData, completionHandler)
            return
        }
            
        guard let result = mockedResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
