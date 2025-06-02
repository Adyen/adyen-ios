//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2_Swift
import UIKit

@MainActor
internal protocol TransactionRepresentable {
    /// The transaction provides the fingerprint
    var fingerprintParameters: AnyAuthenticationRequestParameters { get throws }

    /// The transaction can perform a challenge
    func performChallenge(
        challengeParameters: Adyen3DS2_Swift.ChallengeParameters,
        presentingViewController: UIViewController,
        completion: @escaping @Sendable (Result<AnyChallengeResult, any Error>) -> Void
    )
    
    /// A transaction can be reset
    func resetTransaction()
}

/// Interfaces to the Adyen3DS2_Swift
extension Adyen3DS2_Swift.Transaction: TransactionRepresentable {
    internal var fingerprintParameters: any AnyAuthenticationRequestParameters {
        get throws {
            try authenticationRequestParameters
        }
    }
    
    internal func performChallenge(
        challengeParameters: Adyen3DS2_Swift.ChallengeParameters,
        presentingViewController: UIViewController,
        completion: @escaping @Sendable (Result<AnyChallengeResult, any Error>) -> Void
    ) {
        performChallenge(
            with: challengeParameters,
            presenterViewController: presentingViewController
        ) { result in
            switch result {
            case let .success(challengeResult):
                completion(.success(challengeResult))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func resetTransaction() {
        close()
    }
}
