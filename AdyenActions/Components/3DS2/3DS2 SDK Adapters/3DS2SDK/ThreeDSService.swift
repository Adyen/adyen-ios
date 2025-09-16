//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Adyen3DS2_Swift
import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

/// Service layer for the Adyen3DS2_Swift sdk.
@available(iOS 13, *)
internal final class ThreeDSService: ThreeDSServiceable {
    private let transactionProvider: TransactionProviding
    private var transaction: TransactionRepresentable?
    private let presentingControllerHandler: () throws -> UIViewController
    
    internal init(
        transactionProvider: TransactionProviding = TransactionProvider(),
        presentingControllerHandler: @escaping () throws -> UIViewController = presenterViewController
    ) {
        self.transactionProvider = transactionProvider
        self.presentingControllerHandler = presentingControllerHandler
    }
    
    internal func performFingerprint(
        parameters: FingerprintServiceParameters,
        completionHandler: @escaping (Result<any AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {
        guard let messageVersion = Adyen3DS2_Swift.MessageVersion(
            rawValue: parameters.threeDSMessageVersion
        ) else {
            return completionHandler(.failure(.messageVersionCreationError(
                errorPayload: opaqueErrorObject(error: UnknownError.invalidMessageVersion)
            )))
        }
        
        let serviceParameters: Adyen3DS2_Swift.ServiceParameters
        do {
            serviceParameters = try Adyen3DS2_Swift.ServiceParameters(
                directoryServerIdentifier: parameters.directoryServerIdentifier,
                directoryServerPublicKey: parameters.directoryServerPublicKey,
                directoryServerRootCertificates: parameters.directoryServerRootCertificates
            )
        } catch {
            return completionHandler(.failure(.serviceParameterCreationError(
                errorPayload: self.opaqueErrorObject(error: error)
            )))
        }
        
        transform(
            appearanceConfiguration: parameters.appearanceConfiguration
        ) { [weak self] appearanceConfiguration in
            guard let self else { return }
            self.createTransaction(
                serviceParameters: serviceParameters,
                messageVersion: messageVersion,
                appearanceConfiguration: appearanceConfiguration,
                completionHandler: completionHandler
            )
        }
    }
    
    private func createTransaction(
        serviceParameters: Adyen3DS2_Swift.ServiceParameters,
        messageVersion: Adyen3DS2_Swift.MessageVersion,
        appearanceConfiguration: Adyen3DS2_Swift.AppearanceConfiguration,
        completionHandler: @escaping (Result<any AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {
        transactionProvider.createTransaction(
            serviceParameters: serviceParameters,
            messageVersion: messageVersion,
            securityDelegate: self,
            appearanceConfiguration: appearanceConfiguration
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case let .success(transaction):
                    self.transaction = transaction
                    do {
                        try await completionHandler(.success(transaction.fingerprintParameters))
                    } catch {
                        completionHandler(.failure(.fingerprintingError(
                            errorPayload: self.opaqueErrorObject(error: error)
                        )))
                    }
                case let .failure(error):
                    completionHandler(.failure(.transactionCreationError(
                        errorPayload: self.opaqueErrorObject(error: error)
                    )))
                }
            }
        }
    }
    
    internal func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<any AnyChallengeResult, ThreeDSServiceChallengeError>) -> Void
    ) {
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized))
        }
        
        let presenterViewController: UIViewController
        do {
            presenterViewController = try presentingControllerHandler()
        } catch {
            return completionHandler(.failure(.topViewControllerCouldNotBeDetermined(
                errorPayload: opaqueErrorObject(error: error)
            )))
        }
        let challengeParameters = Adyen3DS2_Swift.ChallengeParameters(
            serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
            threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
            acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
            acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
            acsSignedContent: parameters.challengeToken.acsSignedContent
        )
        DispatchQueue.main.async {
            transaction.performChallenge(
                challengeParameters: challengeParameters,
                presentingViewController: presenterViewController
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(success):
                    completionHandler(.success(success))
                case let .failure(error):
                    if isCancelled(error: error) {
                        completionHandler(.failure(.cancelled(
                            errorPayload: opaqueErrorObject(error: error)
                        )))
                    } else {
                        completionHandler(.failure(.challengeError(
                            errorPayload: opaqueErrorObject(error: error)
                        )))
                    }
                }
            }
        }
    }
    
    internal func resetTransaction() {
        Task { @MainActor in
            await self.transaction?.resetTransaction()
            self.transaction = nil
        }
    }

    private func opaqueErrorObject(error: Error) -> String {
        guard let threeDSError = error as? ThreeDSError else {
            return (error as NSError).opaqueBase64StringRepresentation()
        }
        return threeDSError.base64Representation
    }

    private func isCancelled(error: Error) -> Bool {
        guard let threeDSError = error as? Adyen3DS2_Swift.ThreeDSError else {
            return false
        }
        return threeDSError.isCancellation
    }

    private func transform(
        appearanceConfiguration: Adyen3DS2.ADYAppearanceConfiguration,
        completion: @escaping (Adyen3DS2_Swift.AppearanceConfiguration) -> Void
    ) {
        DispatchQueue.main.async {
            completion(appearanceConfiguration.appearanceConfiguration)
        }
    }
    
    internal static func presenterViewController() throws -> UIViewController {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        
        guard let topViewController else {
            throw UnknownError.topViewControllerNotDetermined
        }
        return topViewController
    }
}

@available(iOS 13, *)
extension ThreeDSService: SecurityWarningsDelegate {
    internal func securityWarningsFound(_ warnings: [Adyen3DS2_Swift.Warning]) {}
}

extension Adyen3DS2_Swift.ChallengeResult: AnyChallengeResult {}
extension Adyen3DS2_Swift.AuthenticationRequestParameters: AnyAuthenticationRequestParameters {}
