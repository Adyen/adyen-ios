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
    func fingerprintParameters(completion: @escaping (Result<AnyAuthenticationRequestParameters, any Error>) -> Void)
    
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
@available(iOS 13.0, *)
extension Adyen3DS2_Swift.Transaction: TransactionRepresentable {
    func fingerprintParameters(completion: @escaping (Result<AnyAuthenticationRequestParameters, any Error>) -> Void) {
        Task { @MainActor in
            do {
                try await completion(.success(authenticationRequestParameters))
            } catch {
                completion(.failure(error))
            }
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
        Task {
            await close()
        }
    }
}
