//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2_Swift
import UIKit

internal protocol TransactionProviding {
    func createTransaction(
        serviceParameters: Adyen3DS2_Swift.ServiceParameters,
        messageVersion: Adyen3DS2_Swift.MessageVersion,
        securityDelegate: Adyen3DS2_Swift.SecurityWarningsDelegate,
        appearanceConfiguration: Adyen3DS2_Swift.AppearanceConfiguration,
        completion: @MainActor @escaping @Sendable (Result<TransactionRepresentable, Error>) -> Void
    )
}

internal final class TransactionProvider: TransactionProviding {
    internal func createTransaction(
        serviceParameters: Adyen3DS2_Swift.ServiceParameters,
        messageVersion: Adyen3DS2_Swift.MessageVersion,
        securityDelegate: Adyen3DS2_Swift.SecurityWarningsDelegate,
        appearanceConfiguration: Adyen3DS2_Swift.AppearanceConfiguration,
        completion: @MainActor @escaping @Sendable (Result<TransactionRepresentable, any Error>) -> Void
    ) {
        Adyen3DS2_Swift.Transaction.initialize(
            serviceParameters: serviceParameters,
            messageVersion: messageVersion,
            securityDelegate: securityDelegate,
            appearanceConfiguration: appearanceConfiguration
        ) { result in
            switch result {
            case let .success(transaction):
                completion(.success(transaction))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
