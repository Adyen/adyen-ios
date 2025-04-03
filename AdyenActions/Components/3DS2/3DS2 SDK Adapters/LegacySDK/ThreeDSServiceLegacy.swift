//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation
@_spi(AdyenInternal) import Adyen

/// This is a wrapper class for the Objective C 3ds2 sdk.
/// This translates simple non specific sdk bound types such as
/// `FingerprintServiceParameters` & `ChallengeParameters` to sdk specific types and performs actions.
internal final class ThreeDSServiceLegacy: ThreeDSServiceable {
    private var service: AnyADYService
    private var transaction: AnyADYTransaction?
    
    internal init(
        service: AnyADYService = ADYServiceAdapter()
    ) {
        self.service = service
    }
    
    internal func performFingerprint(
        parameters: FingerprintServiceParameters,
        completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {
        let serviceParameters = ADYServiceParameters(
            directoryServerIdentifier: parameters.directoryServerIdentifier,
            directoryServerPublicKey: parameters.directoryServerPublicKey,
            directoryServerRootCertificates: parameters.directoryServerRootCertificates
        )
        service.service(
            with: serviceParameters,
            appearanceConfiguration: parameters.appearanceConfiguration
        ) { [weak self] service in
            guard let self else { return }
            do {
                let transaction = try service.transaction(withMessageVersion: parameters.threeDSMessageVersion)
                self.transaction = transaction
                completionHandler(.success(transaction.authenticationParameters))
                
            } catch {
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
        completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceChallengeError>) -> Void
    ) {
        let challengeParameters = ADYChallengeParameters(
            serverTransactionIdentifier: parameters.challengeToken.serverTransactionIdentifier,
            threeDSRequestorAppURL: parameters.threeDSRequestorAppURL,
            acsTransactionIdentifier: parameters.challengeToken.acsTransactionIdentifier,
            acsReferenceNumber: parameters.challengeToken.acsReferenceNumber,
            acsSignedContent: parameters.challengeToken.acsSignedContent
        )
        
        guard let transaction else {
            return completionHandler(.failure(.transactionNotInitialized))
        }
        
        transaction.performChallenge(
            with: challengeParameters
        ) { [weak self] challengeResult, error in
            guard let self else { return }
            
            guard let result = challengeResult else {
                guard let error else {
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
        let error: NSError = error as NSError
        return (error.code == Int(ADYRuntimeErrorCode.challengeCancelled.rawValue)) && (error.domain == ADYRuntimeErrorDomain)
    }
    
    internal func opaqueErrorObject(error: any Error) -> String {
        (error as NSError).base64Representation()
    }

    internal func resetTransaction() {
        self.transaction = nil
    }
}

extension Adyen3DS2.ADYAuthenticationRequestParameters: AnyAuthenticationRequestParameters {}
extension Adyen3DS2.ADYChallengeResult: AnyChallengeResult {}
