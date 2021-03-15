//
//  AnyThreeDS2ActionHandlerMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import AdyenActions
@testable import AdyenCard
import Foundation

final class AnyThreeDS2ActionHandlerMock: AnyThreeDS2ActionHandler {

    var mockedFingerprintResult: Result<ThreeDSActionHandlerResult, Error>?

    func handle(_ action: ThreeDS2FingerprintAction, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let result = mockedFingerprintResult else { assertionFailure(); return }
        completionHandler(result)
    }

    var mockedChallengeResult: Result<ThreeDSActionHandlerResult, Error>?

    func handle(_ action: ThreeDS2ChallengeAction, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let result = mockedChallengeResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
