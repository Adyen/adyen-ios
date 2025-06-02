//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Adyen3DS2_Swift
@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

final class MockTransactionRepresentable: TransactionRepresentable {
    internal var onFingerprintParameters: (
        () throws -> AnyAuthenticationRequestParameters
    )?
    
    var fingerprintParameters: AdyenActions.AnyAuthenticationRequestParameters {
        get throws {
            guard let onFingerprintParameters else {
                fatalError("mock not configured")
            }
            return try onFingerprintParameters()
        }
    }
    
    internal var onPerformChallenge: (
        (
            Adyen3DS2_Swift.ChallengeParameters,
            UIViewController,
            @escaping @Sendable (Result<any AdyenActions.AnyChallengeResult, any Error>) -> Void
        ) -> Void
    )?

    func performChallenge(
        challengeParameters: Adyen3DS2_Swift.ChallengeParameters,
        presentingViewController: UIViewController,
        completion: @escaping @Sendable (Result<any AdyenActions.AnyChallengeResult, any Error>) -> Void
    ) {
        guard let onPerformChallenge else {
            fatalError("mock not configured")
        }
        onPerformChallenge(challengeParameters, presentingViewController, completion)
    }
    
    internal var onResetTransaction: (
        () -> Void
    )?
    func resetTransaction() {
        guard let onResetTransaction else {
            fatalError("mock not configured")
        }
        onResetTransaction()
    }
}
