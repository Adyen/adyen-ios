//
//  AnyThreeDS2ActionHandlerMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
@testable import AdyenCard

final class AnyThreeDS2ActionHandlerMock: AnyThreeDS2ActionHandler {

    var mockedFingerprintResult: Result<Action?, Error>?

    func handle(_ action: ThreeDS2FingerprintAction, completionHandler: @escaping (Result<Action?, Error>) -> Void) {
        guard let result = mockedFingerprintResult else { assertionFailure(); return }
        completionHandler(result)
    }

    var mockedChallengeResult: Result<ActionComponentData, Error>?

    func handle(_ action: ThreeDS2ChallengeAction, completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void) {
        guard let result = mockedChallengeResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
