//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
/// :nodoc:
internal class ThreeDS2ClassicActionHandler: AnyThreeDS2ActionHandler {

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal let appearanceConfiguration: ADYAppearanceConfiguration

    /// :nodoc:
    internal lazy var service: AnyADYService = ADYServiceAdapter()

    /// :nodoc:
    internal var transaction: AnyADYTransaction?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal convenience init(service: AnyADYService,
                              appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.init(appearanceConfiguration: appearanceConfiguration)
        self.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    internal init(appearanceConfiguration: ADYAppearanceConfiguration) {
        self.appearanceConfiguration = appearanceConfiguration
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        Analytics.sendEvent(component: fingerprintEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        createFingerprint(fingerprintAction) { [weak self] result in
            switch result {
            case let .success(encodedFingerprint):
                let additionalDetails = ThreeDS2Details.fingerprint(encodedFingerprint)
                let result = ThreeDSActionHandlerResult.details(additionalDetails)
                completionHandler(.success(result))
            case let .failure(error):
                self?.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }

    internal func createFingerprint(_ action: ThreeDS2FingerprintAction,
                                    completionHandler: @escaping (Result<String, Error>) -> Void) {

        do {
            let token = try Coder.decodeBase64(action.fingerprintToken) as ThreeDS2Component.FingerprintToken

            let serviceParameters = ADYServiceParameters()
            serviceParameters.directoryServerIdentifier = token.directoryServerIdentifier
            serviceParameters.directoryServerPublicKey = token.directoryServerPublicKey

            service.service(with: serviceParameters, appearanceConfiguration: appearanceConfiguration) { [weak self] _ in
                if let encodedFingerprint = self?.getFingerprint(completionHandler: completionHandler) {
                    completionHandler(.success(encodedFingerprint))
                }
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func getFingerprint<R>(completionHandler: @escaping (Result<R, Error>) -> Void) -> String? {
        do {
            let newTransaction = try service.transaction(withMessageVersion: "2.1.0")
            self.transaction = newTransaction

            let fingerprint = try ThreeDS2Component.Fingerprint(
                authenticationRequestParameters: newTransaction.authenticationParameters
            )
            let encodedFingerprint = try Coder.encodeBase64(fingerprint)

            return encodedFingerprint
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
        return nil
    }

    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let transaction = transaction else {
            didFail(with: ThreeDS2ComponentError.missingTransaction, completionHandler: completionHandler)

            return
        }

        Analytics.sendEvent(component: challengeEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)

        do {
            let token = try Coder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
            let challengeParameters = ADYChallengeParameters(from: token)
            transaction.performChallenge(with: challengeParameters) { [weak self] challengeResult, error in
                self?.handle(challengeResult, error: error,
                             for: challengeAction,
                             completionHandler: completionHandler)
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func handle(_ challengeResult: AnyChallengeResult?,
                        error: Error?,
                        for challengeAction: ThreeDS2ChallengeAction,
                        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        do {
            if let error = error {
                self.didFail(with: error, completionHandler: completionHandler)
            } else if let result = challengeResult {

                let threeDSResult = try ThreeDSResult(from: result,
                                                      authorizationToken: challengeAction.authorisationToken)

                self.didFinish(with: threeDSResult,
                               paymentData: challengeAction.paymentData,
                               completionHandler: completionHandler)
            } else {
                assertionFailure("Both error and result are nil, this should never happen.")
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    internal func didFinish(with challengeResult: ThreeDSResult,
                            paymentData: String?,
                            completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        transaction = nil

        let additionalDetails = createDetailsObject(from: challengeResult)
        completionHandler(.success(.details(additionalDetails)))
    }

    internal func createDetailsObject(from result: ThreeDSResult) -> AdditionalDetails {
        ThreeDS2Details.challengeResult(result)
    }

    internal func didFail<R>(with error: Error,
                             completionHandler: @escaping (Result<R, Error>) -> Void) {
        transaction = nil

        completionHandler(.failure(error))
    }

    // MARK: - Private

    private let fingerprintEventName = "3ds2fingerprint"

    private let challengeEventName = "3ds2challenge"

}
