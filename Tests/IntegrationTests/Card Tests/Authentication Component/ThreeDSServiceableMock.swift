//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import Foundation

final class ThreeDSServiceableMock: ThreeDSService {
    var configuration: ThreeDSFeatureChecker?
    
    var onResetTransaction: (() -> Void)?
    func resetTransaction() {
        guard let onResetTransaction else {
            fatalError("Need to provide a mock data if you are using this mock.")
        }
        onResetTransaction()
    }
    
    typealias FingerprintResult = Result<any AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>
    var onPerformFingerprint: ((FingerprintServiceParameters, (FingerprintResult) -> Void) -> Void)?
    
    func performFingerprint(
        parameters: FingerprintServiceParameters,
        completionHandler: @escaping (FingerprintResult) -> Void
    ) {
        guard let onPerformFingerprint else {
            fatalError("Need to provide a mock data if you are using this mock.")
        }
        onPerformFingerprint(parameters, completionHandler)
    }

    typealias ChallengeResult = Result<any AnyChallengeResult, ThreeDSServiceChallengeError>
    var onPerformChallenge: ((ChallengeParameters, (ChallengeResult) -> Void) -> Void)?
    
    func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (ChallengeResult) -> Void
    ) {
        guard let onPerformChallenge else {
            fatalError("Need to provide a mock data if you are using this mock.")
        }
        onPerformChallenge(parameters, completionHandler)
    }
}
