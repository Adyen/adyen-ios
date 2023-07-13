//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

// TODO: Remove this once 3ds2 sdk is released.
extension NSError {
    func base64Representation() -> String {
        "base64Representation"
    }
}

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
/// :nodoc:
internal class ThreeDS2CoreActionHandler: Component {
    
    /// :nodoc:
    internal let apiContext: APIContext

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal let appearanceConfiguration: ADYAppearanceConfiguration

    /// :nodoc:
    internal lazy var service: AnyADYService = ADYServiceAdapter()

    /// :nodoc:
    internal var transaction: AnyADYTransaction?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal convenience init(apiContext: APIContext,
                              service: AnyADYService,
                              appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.init(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)
        self.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    internal init(apiContext: APIContext,
                  appearanceConfiguration: ADYAppearanceConfiguration) {
        self.apiContext = apiContext
        self.appearanceConfiguration = appearanceConfiguration
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
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
            case let .success(newTransaction):
                let encodedFingerprint = try Coder.encodeBase64(ThreeDS2Component.Fingerprint(
                    authenticationRequestParameters: newTransaction.authenticationParameters
                ))
                self.transaction = newTransaction
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
    /// :nodoc:
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

        let challengeParameters = ADYChallengeParameters(from: token,
                                                         threeDSRequestorAppURL: token.threeDSRequestorAppURL)
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
            let threeDSResult = try ThreeDSResult(authorizationToken: authorizationToken, threeDS2SDKError: threeDS2SDKError)
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