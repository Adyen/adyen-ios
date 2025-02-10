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

@available(iOS 13, *)
internal final class ThreeDSService: ThreeDSServiceable, SecurityWarningsDelegate {
    internal var transaction: Adyen3DS2_Swift.Transaction?
    
    @MainActor
    internal func authenticationParameters(
        parameters: ServiceParameters,
        completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {
        guard let messageVersion = MessageVersion(rawValue: parameters.threeDSMessageVersion) else {
            completionHandler(.failure(
                .messageVersionCreationError(
                    errorPayload: self.opaqueErrorObject(
                        error: UnknownError.invalidMessageVersion
                    )
                )
            ))
            return
        }

        do {
            let serviceParameters = try Adyen3DS2_Swift.ServiceParameters(
                directoryServerIdentifier: parameters.directoryServerIdentifier,
                directoryServerPublicKey: parameters.directoryServerPublicKey,
                directoryServerRootCertificates: parameters.directoryServerRootCertificates
            )
            Adyen3DS2_Swift.Transaction.initialize(
                serviceParameters: serviceParameters,
                messageVersion: messageVersion,
                securityDelegate: self,
                appearanceConfiguration: transform(config: parameters.appearanceConfiguration)
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(transaction):
                    self.transaction = transaction
                    do {
                        try completionHandler(.success(transaction.authenticationRequestParameters))
                    } catch {
                        completionHandler(.failure(
                            .fingerprintingError(
                                errorPayload: self.opaqueErrorObject(error: error)
                            )
                        ))
                    }
                case let .failure(error):
                    completionHandler(.failure(
                        .transactionCreationError(
                            errorPayload: self.opaqueErrorObject(error: error)
                        )
                    ))
                }
            }

        } catch {
            completionHandler(.failure(
                .serviceParameterCreationError(
                    errorPayload: self.opaqueErrorObject(error: error)
                )
            ))
        }
    }

    internal func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<any AnyChallengeResult, ThreeDSServiceError>) -> Void
    ) {
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized(
                errorPayload: opaqueErrorObject(error: UnknownError.transactionNotInitialized)
            )))
        }
        
        let challengeParameters = Adyen3DS2_Swift.ChallengeParameters(
            serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
            threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
            acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
            acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
            acsSignedContent: parameters.challengeToken.acsSignedContent
        )

        switch getPresenterViewController() {
        case let .success(presenterViewController):
            transaction.performChallenge(
                with: challengeParameters,
                presenterViewController: presenterViewController
            ) { [weak self] result in
                guard let self else {
                    return
                }
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

        case let .failure(error):
            completionHandler(.failure(.challengeError(
                errorPayload: opaqueErrorObject(error: error)
            )))
        }

    }
    
    internal func opaqueErrorObject(error: Error) -> String {
        guard let threedsError = error as? ThreeDSError else {
            return (error as NSError).base64Representation
        }
        return threedsError.base64Representation
    }

    private func isCancelled(error: Error) -> Bool {
        guard let threedsError = error as? ThreeDSError else {
            return false
        }
        return threedsError.errorCode == "1001"
    }

    internal func resetTransaction() {
        self.transaction = nil
    }
    
    @MainActor
    internal func transform(config: Adyen3DS2.ADYAppearanceConfiguration) -> Adyen3DS2_Swift.AppearanceConfiguration {
        config.appearanceConfiguration
    }
    
    private func getPresenterViewController() -> Result<UIViewController, ThreeDSServiceError> {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        
        guard let topViewController else {
            return .failure(ThreeDSServiceError.topViewControllerCouldNotBeDetermined(
                errorPayload: opaqueErrorObject(error: UnknownError.topViewControllerNotDetermined)
            ))
        }
        return .success(topViewController)
    }
    
    internal func securityWarningsFound(_ warnings: [Adyen3DS2_Swift.Warning]) {}
}

extension ChallengeResult: AnyChallengeResult {}
extension Adyen3DS2_Swift.AuthenticationRequestParameters: AnyAuthenticationRequestParameters {}

extension NSError {
    var base64Representation: String {
        // TODO: Use the public api from the sdk.
        fatalError("Should never come here, should never have been pushed to production")
    }
}
