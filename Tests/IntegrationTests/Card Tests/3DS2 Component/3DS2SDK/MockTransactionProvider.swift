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

final class MockTransactionProvider: TransactionProviding {
    var onCreateTransaction: (
        (
            @escaping @MainActor (Result<TransactionRepresentable, any Error>) -> Void
        ) -> Void
    )?

    func createTransaction(
        serviceParameters: ServiceParameters,
        messageVersion: MessageVersion,
        securityDelegate: any SecurityWarningsDelegate,
        appearanceConfiguration: AppearanceConfiguration,
        completion: @escaping @MainActor (Result<TransactionRepresentable, any Error>) -> Void
    ) {
        guard let onCreateTransaction else {
            fatalError("Provide a mock handler if using this mock")
        }
        onCreateTransaction(
            completion
        )
    }

    var onPerformChallenge: (
        (
            @escaping (Result<ChallengeResult, any Error>) -> Void
        ) -> Void
    )?
    
    func performChallenge(
        transaction: Transaction,
        challengeParameters: Adyen3DS2_Swift.ChallengeParameters,
        presentingViewController: UIViewController,
        completion: @escaping (Result<ChallengeResult, any Error>) -> Void
    ) {
        guard let onPerformChallenge else {
            fatalError("Provide a mock handler if using this mock")
        }
        onPerformChallenge(
            completion
        )
    }
}
