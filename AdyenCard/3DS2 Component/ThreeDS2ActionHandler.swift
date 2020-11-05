//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

/// :nodoc:
internal protocol AnyThreeDS2ActionHandler: Component {

    /// :nodoc:
    func handleFullFlow(_ fingerprintAction: ThreeDS2FingerprintAction,
                        completionHandler: @escaping (Result<Action?, Error>) -> Void)

    /// :nodoc:
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void)

    /// :nodoc:
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void)
}

/// Handles the 3D Secure 2 fingerprint and challenge.
/// :nodoc:
internal final class ThreeDS2ActionHandler: AnyThreeDS2ActionHandler {

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal let appearanceConfiguration = ADYAppearanceConfiguration()

    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter fingerprintSubmitter: The fingerprint handler.
    /// - Parameter service: The 3DS2 Service.
    /// :nodoc:
    internal convenience init(fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter, service: AnyADYService) {
        self.init()
        self.fingerprintSubmitter = fingerprintSubmitter
        self.service = service
    }

    /// Initializes the 3D Secure 2 component.
    internal init() { /* empty init */ }

    // MARK: - 3D Secure 2 Action

    /// Handles the 3D Secure 2 action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handleFullFlow(_ fingerprintAction: ThreeDS2FingerprintAction,
                                 completionHandler: @escaping (Result<Action?, Error>) -> Void) {
        Analytics.sendEvent(component: threeDS2EventName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        createFingerprint(fingerprintAction) { [weak self] result in
            switch result {
            case let .success(encodedFingerprint):
                self?.fingerprintSubmitter.submit(fingerprint: encodedFingerprint,
                                                  paymentData: fingerprintAction.paymentData,
                                                  completionHandler: completionHandler)
            case let .failure(error):
                self?.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void) {
        Analytics.sendEvent(component: fingerprintEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        createFingerprint(fingerprintAction) { [weak self] result in
            switch result {
            case let .success(encodedFingerprint):
                let additionalDetails = ThreeDS2Details.fingerprint(encodedFingerprint)

                completionHandler(.success(ActionComponentData(details: additionalDetails, paymentData: fingerprintAction.paymentData)))
            case let .failure(error):
                self?.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }

    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                         completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void) {
        guard let transaction = transaction else {
            didFail(with: ThreeDS2ComponentError.missingTransaction, completionHandler: completionHandler)

            return
        }

        Analytics.sendEvent(component: challengeEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)

        do {
            let token = try Coder.decodeBase64(challengeAction.token) as ThreeDS2Component.ChallengeToken
            let challengeParameters = ADYChallengeParameters(from: token)
            transaction.performChallenge(with: challengeParameters) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    self.didFail(with: error, completionHandler: completionHandler)
                } else if let result = result {
                    self.handle(result,
                                paymentData: challengeAction.paymentData,
                                completionHandler: completionHandler)
                }
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    // MARK: - Private

    /// :nodoc:
    private lazy var fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter = {
        let handler = ThreeDS2FingerprintSubmitter()

        handler.environment = environment
        handler.clientKey = clientKey

        return handler
    }()

    private let fingerprintEventName = "3ds2fingerprint"

    private let challengeEventName = "3ds2challenge"

    private let threeDS2EventName = "3ds2"

    private var transaction: AnyADYTransaction?

    private lazy var service: AnyADYService = ADYServiceAdapter()

    private func createFingerprint(_ action: ThreeDS2FingerprintAction,
                                   completionHandler: @escaping (Result<String, Error>) -> Void) {

        do {
            let token = try Coder.decodeBase64(action.token) as ThreeDS2Component.FingerprintToken

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

    private func handle(_ sdkChallengeResult: AnyChallengeResult,
                        paymentData: String,
                        completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void) {
        do {
            let challengeResult = try ThreeDS2Component.ChallengeResult(from: sdkChallengeResult)
            didFinish(with: challengeResult,
                      paymentData: paymentData,
                      completionHandler: completionHandler)
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func didFinish(with challengeResult: ThreeDS2Component.ChallengeResult,
                           paymentData: String,
                           completionHandler: @escaping (Result<ActionComponentData, Error>) -> Void) {
        transaction = nil

        let additionalDetails = ThreeDS2Details.challengeResult(challengeResult)
        completionHandler(.success(ActionComponentData(details: additionalDetails, paymentData: paymentData)))
    }

    private func didFail<R>(with error: Error,
                            completionHandler: @escaping (Result<R, Error>) -> Void) {
        transaction = nil

        completionHandler(.failure(error))
    }

}
