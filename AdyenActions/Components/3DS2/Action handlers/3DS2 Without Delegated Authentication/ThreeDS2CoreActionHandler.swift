//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation

internal protocol AnyThreeDS2CoreActionHandler: Component {
    var threeDSRequestorAppURL: URL? { get set }
    
    var service: AnyADYService { get set }
    
    var transaction: AnyADYTransaction? { get set }
    
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<String, Error>) -> Void)
    
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void)
}

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
internal class ThreeDS2CoreActionHandler: AnyThreeDS2CoreActionHandler {
    
    internal let context: AdyenContext

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    internal let appearanceConfiguration: ADYAppearanceConfiguration

    internal lazy var service: AnyADYService = ADYServiceAdapter()

    internal var transaction: AnyADYTransaction?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
    internal var threeDSRequestorAppURL: URL?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    internal init(context: AdyenContext,
                  service: AnyADYService = ADYServiceAdapter(),
                  appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.context = context
        self.appearanceConfiguration = appearanceConfiguration
        self.service = service
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         event: Analytics.Event,
                         completionHandler: @escaping (Result<String, Error>) -> Void) {
        Analytics.sendEvent(event)

        createFingerprint(fingerprintAction) { [weak self] result in
            switch result {
            case let .success(encodedFingerprint):
                completionHandler(.success(encodedFingerprint))
            case let .failure(error):
                self?.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }
    
    private func createFingerprint(_ action: ThreeDS2FingerprintAction,
                                   completionHandler: @escaping (Result<String, Error>) -> Void) {
        do {
            let token = try Coder.decodeBase64(action.fingerprintToken) as ThreeDS2Component.FingerprintToken

            let serviceParameters = ADYServiceParameters()
            serviceParameters.directoryServerIdentifier = token.directoryServerIdentifier
            serviceParameters.directoryServerPublicKey = token.directoryServerPublicKey
            serviceParameters.directoryServerRootCertificates = token.directoryServerRootCertificates

            service.service(with: serviceParameters, appearanceConfiguration: appearanceConfiguration) { [weak self] _ in
                self?.getFingerprint(messageVersion: token.threeDSMessageVersion,
                                     completionHandler: completionHandler)
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func getFingerprint(messageVersion: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        do {
            switch transaction(messageVersion: messageVersion) {
            case let .success(transaction):
                let encodedFingerprint = try Coder.encodeBase64(ThreeDS2Component.Fingerprint(
                    authenticationRequestParameters: transaction.authenticationParameters,
                    delegatedAuthenticationSDKOutput: nil
                ))
                self.transaction = transaction
                completionHandler(.success(encodedFingerprint))

            case let .failure(error):
                let encodedError = try Coder.encodeBase64(ThreeDS2Component.Fingerprint(threeDS2SDKError: error.base64Representation()))
                completionHandler(.success(encodedError))
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func transaction(messageVersion: String) -> Result<AnyADYTransaction, NSError> {
        do {
            let newTransaction = try service.transaction(withMessageVersion: messageVersion)
            return .success(newTransaction)
        } catch let error as NSError {
            return .failure(error)
        }
    }
    
    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                         event: Analytics.Event,
                         completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        guard let transaction = transaction else {
            return didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)
        }

        Analytics.sendEvent(event)

        let token: ThreeDS2Component.ChallengeToken
        do {
            token = try Coder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
        } catch {
            return didFail(with: error, completionHandler: completionHandler)
        }

        let challengeParameters = ADYChallengeParameters(challengeToken: token,
                                                         threeDSRequestorAppURL: threeDSRequestorAppURL ?? token.threeDSRequestorAppURL)
        transaction.performChallenge(with: challengeParameters) { [weak self] challengeResult, error in
            guard let result = challengeResult else {
                self?.didReceiveErrorOnChallenge(error: error, challengeAction: challengeAction, completionHandler: completionHandler)
                return
            }

            self?.didFinish(with: result,
                            authorizationToken: challengeAction.authorisationToken,
                            completionHandler: completionHandler)
        }
    }
    
    /// Invoked to handle the error flow of a challenge handling by the 3ds2sdk.
    /// For challenge cancelled we return the control back to the merchant immediately as an error.
    private func didReceiveErrorOnChallenge(error: Error?,
                                            challengeAction: ThreeDS2ChallengeAction,
                                            completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        guard let error = error as? NSError else {
            didFail(with: UnknownError(errorDescription: "Both error and result are nil, this should never happen."),
                    completionHandler: completionHandler)
            return
        }
        switch (error.domain, error.code) {
        case (ADYRuntimeErrorDomain, Int(ADYRuntimeErrorCode.challengeCancelled.rawValue)):
            didFail(with: error,
                    completionHandler: completionHandler)
        default:
            didFinish(threeDS2SDKError: error.base64Representation(),
                      authorizationToken: challengeAction.authorisationToken,
                      completionHandler: completionHandler)
        }
    }
    
    private func didFinish(threeDS2SDKError: String,
                           authorizationToken: String?,
                           completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        do {
            // When we get an error we need to send transStatus as "U" along with the threeDS2SDKError field.
            let threeDSResult = try ThreeDSResult(authorizationToken: authorizationToken,
                                                  threeDS2SDKError: threeDS2SDKError,
                                                  transStatus: "U")
            transaction = nil
            completionHandler(.success(threeDSResult))
        } catch {
            completionHandler(.failure(error))
        }
    }

    private func didFinish(with challengeResult: AnyChallengeResult,
                           authorizationToken: String?,
                           completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        do {
            let threeDSResult = try ThreeDSResult(from: challengeResult,
                                                  delegatedAuthenticationSDKOutput: nil,
                                                  authorizationToken: authorizationToken,
                                                  threeDS2SDKError: nil)

            transaction = nil
            completionHandler(.success(threeDSResult))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func didFail<R>(with error: Error,
                            completionHandler: @escaping (Result<R, Error>) -> Void) {
        transaction = nil

        completionHandler(.failure(error))
    }

}
