//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

/// This protocol abstracts the SDK logic away.
/// The 3DS2 SDK performs 2 tasks - fingerprint & challenge.
/// Additionally we provide a way to reset the transaction.
internal protocol ThreeDSServiceable {
    func performFingerprint(
        parameters: FingerprintServiceParameters,
        completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    )
    func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceChallengeError>) -> Void
    )
    func resetTransaction()
}
