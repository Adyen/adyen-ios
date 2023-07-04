//
//  AnyThreeDS2FingerprintSubmitterMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import AdyenActions
import Foundation

final class AnyThreeDS2FingerprintSubmitterMock: AnyThreeDS2FingerprintSubmitter {
    var mockedResult: Result<ThreeDSActionHandlerResult, ThreeDS2FingerprintSubmitterError>?

    func submit(fingerprint: String, paymentData: String?, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, ThreeDS2FingerprintSubmitterError>) -> Void) {
        guard let result = mockedResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
