//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Adyen3DS2_Swift
import Foundation
import UIKit

internal final class ThreeDSService: ThreeDSServiceProtocol, SecurityWarningsDelegate {
    internal var transaction: Adyen3DS2_Swift.Transaction?
    
    @MainActor func authenticationParameters(parameters: ServiceParameters,
                                             completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, Error>) -> Void) {
        do {
            let serviceParameters = try Adyen3DS2_Swift.ServiceParameters(directoryServerIdentifier: parameters.directoryServerIdentifier,
                                                                          directoryServerPublicKey: parameters.directoryServerPublicKey,
                                                                          directoryServerRootCertificates: parameters.directoryServerRootCertificates)
            guard let messageVersion = MessageVersion(rawValue: parameters.threeDSMessageVersion) else {
                fatalError("Unsupported message version")
            }

            Adyen3DS2_Swift.Transaction.initialize(serviceParameters: serviceParameters,
                                                   messageVersion: messageVersion,
                                                   securityDelegate: self,
                                                   appearanceConfiguration: transform(config: parameters.appearanceConfiguration)) { @MainActor result in
                switch result {
                case let .success(transaction):
                    self.transaction = transaction
                    do {
                        try completionHandler(.success(transaction.authenticationRequestParameters))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }

    func performChallenge(with parameters: ChallengeParameters,
                          completionHandler: @escaping (Result<any AnyChallengeResult, ThreeDSServiceError>) -> Void) {
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized))
        }
        
        let challengeParameters = Adyen3DS2_Swift.ChallengeParameters(serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
                                                                      threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
                                                                      acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
                                                                      acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
                                                                      acsSignedContent: parameters.challengeToken.acsSignedContent)

        transaction.performChallenge(with: challengeParameters,
                                     presenterViewController: getPresenterViewController()) { result in
            switch result {
            case let .success(success):
                completionHandler(.success(success))
            case let .failure(failure):
                completionHandler(.failure(.challengeError(failure)))
            }
        }
        
    }
    
    @MainActor
    func transform(config: Adyen3DS2.ADYAppearanceConfiguration) -> Adyen3DS2_Swift.AppearanceConfiguration {
        AppearanceConfiguration()
    }
    
    private func getPresenterViewController() -> UIViewController {
        // TODO: Robert: How do i get the presenterViewController if it  doesn't break public API.
        // Maybe we can re-use the logic how we used to get it in the sdk earlier, but optionally allow it to be configured.
        (UIApplication.shared.keyWindow?.topViewController)!
    }
    
    internal func securityWarningsFound(_ warnings: [Adyen3DS2_Swift.Warning]) {
        Swift.print("\(#function): warnings:\(warnings)")
    }
}

extension ChallengeResult: AnyChallengeResult {}
extension Adyen3DS2_Swift.AuthenticationRequestParameters: AnyAuthenticationRequestParameters {}

extension UIWindow {
    internal var topViewController: UIViewController? {
        var topViewController = rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController
    }
}
