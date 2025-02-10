//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation
@_spi(AdyenInternal) import Adyen

internal final class ThreeDSServiceLegacy: ThreeDSServiceable {
    private var service: Adyen3DS2.ADYService?
    private var transaction: Adyen3DS2.ADYTransaction?
    
    internal func opaqueErrorObject(error: any Error) -> String {
        (error as NSError).base64Representation()
    }
    
    internal func authenticationParameters(
        parameters: ServiceParameters,
        completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {

        let serviceParameters = ADYServiceParameters(
            directoryServerIdentifier: parameters.directoryServerIdentifier,
            directoryServerPublicKey: parameters.directoryServerPublicKey,
            directoryServerRootCertificates: parameters.directoryServerRootCertificates
        )

        ADYService.service(
            with: serviceParameters,
            appearanceConfiguration: parameters.appearanceConfiguration
        ) { [weak self] service in
            guard let self else { return }
            self.service = service
            do {
                let transaction = try service.transaction(withMessageVersion: parameters.threeDSMessageVersion)
                self.transaction = transaction
                completionHandler(.success(transaction.authenticationRequestParameters))
                
            } catch let error as NSError {
                completionHandler(
                    .failure(.fingerprintingError(
                        errorPayload: self.opaqueErrorObject(error: error)
                    ))
                )
            }
        }
    }
    
    internal func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceError>) -> Void
    ) {
        let challengeParameters = ADYChallengeParameters(
            serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
            threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
            acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
            acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
            acsSignedContent: parameters.challengeToken.acsSignedContent
        )
        
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized(
                errorPayload: opaqueErrorObject(error: ThreeDSServiceError.transactionNotInitialized(errorPayload: ""))
            )))
        }
        
        transaction.performChallenge(
            with: challengeParameters
        ) { [weak self] challengeResult, error in
            guard let self else { return }
            
            guard let result = challengeResult else {
                guard let error = error as? NSError else {
                    completionHandler(.failure(.errorAndResultAreNil(
                        errorPayload: opaqueErrorObject(error: UnknownError.resultAndErrorAreNil)
                    )))
                    return
                }
                
                if isCancelled(error: error) {
                    return completionHandler(.failure(.cancelled(
                        errorPayload: opaqueErrorObject(error: error)
                    )))
                } else {
                    return completionHandler(.failure(.challengeError(
                        errorPayload: opaqueErrorObject(error: error)
                    )))
                }
            }
            completionHandler(.success(result))
        }
    }
    
    private func isCancelled(error: Error) -> Bool {
        let nsError: NSError = error as NSError
        switch (nsError.code, nsError.domain) {
        case (Int(ADYRuntimeErrorCode.challengeCancelled.rawValue), ADYRuntimeErrorDomain):
            return true
        default:
            return false
        }
    }

    internal func resetTransaction() {
        self.service = nil
        self.transaction = nil
    }
}

extension Adyen3DS2.ADYAuthenticationRequestParameters: AnyAuthenticationRequestParameters {}

extension ADYChallengeResult: AnyChallengeResult {}
