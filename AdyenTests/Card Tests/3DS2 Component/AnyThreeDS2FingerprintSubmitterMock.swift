//
//  AnyThreeDS2FingerprintSubmitterMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
@testable import AdyenCard

final class AnyThreeDS2FingerprintSubmitterMock: AnyThreeDS2FingerprintSubmitter {

    var mockedResult: Result<Action?, Error>?

    func submit(fingerprint: String, paymentData: String, completionHandler: @escaping (Result<Action?, Error>) -> Void) {
        guard let result = mockedResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
