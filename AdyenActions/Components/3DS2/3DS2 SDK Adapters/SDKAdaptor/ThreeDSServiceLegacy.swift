//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation
@_spi(AdyenInternal) import Adyen

final class ThreeDSServiceLegacy: ThreeDSServiceProtocol {
    var service: Adyen3DS2.ADYService?
    var transaction: Adyen3DS2.ADYTransaction?
    
    func authenticationParameters(parameters: ServiceParameters,
                                  completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, Error>) -> Void) {

        let serviceParameters = ADYServiceParameters(directoryServerIdentifier: parameters.directoryServerIdentifier,
                                                     directoryServerPublicKey: parameters.directoryServerPublicKey,
                                                     directoryServerRootCertificates: parameters.directoryServerRootCertificates)

        ADYService.service(with: serviceParameters,
                           appearanceConfiguration: parameters.appearanceConfiguration) { [weak self] service in
            guard let self else { return }
            self.service = service
            do {
                do {
                    let transaction = try service.transaction(withMessageVersion: parameters.threeDSMessageVersion)
                    self.transaction = transaction
                    completionHandler(.success(transaction.authenticationRequestParameters))

                } catch let error as NSError {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func performChallenge(with parameters: ChallengeParameters,
                          completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceError>) -> Void) {
        let challengeParameters = ADYChallengeParameters(serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
                                                         threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
                                                         acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
                                                         acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
                                                         acsSignedContent: parameters.challengeToken.acsSignedContent)
        
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized))
        }
        
        transaction.performChallenge(with: challengeParameters) { challengeResult, error in
            guard let result = challengeResult else {
                guard let error = error as? NSError else {
                    completionHandler(.failure(.unknownError(UnknownError(errorDescription: "Both error and result are nil, this should never happen."))))
                    return
                }

                return completionHandler(.failure(.challengeError(error)))
            }
            completionHandler(.success(result))
        }
    }
}
