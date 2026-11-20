//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import Foundation

@MainActor
final class AnyThreeDS2FingerprintSubmitterMock: @MainActor AnyThreeDS2FingerprintSubmitter {
    var mockedResult: Result<ThreeDSActionHandlerResult, Error>?
    var onSubmitFingerprint: (
        (
            String, String?, @escaping @MainActor @Sendable (Result<ThreeDSActionHandlerResult, Error>) -> Void
        ) -> Void
    )?
    
    func submit(
        fingerprint: String,
        paymentData: String?,
        completionHandler: @escaping @MainActor @Sendable (Result<ThreeDSActionHandlerResult, Error>) -> Void
    ) {
        if let onSubmitFingerprint {
            onSubmitFingerprint(fingerprint, paymentData, completionHandler)
            return
        }
            
        guard let result = mockedResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
