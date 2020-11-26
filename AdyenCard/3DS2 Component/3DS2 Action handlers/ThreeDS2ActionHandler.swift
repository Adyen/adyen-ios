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
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)

    /// :nodoc:
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)
}

/// Handles the 3D Secure 2 fingerprint and challenge.
/// :nodoc:
internal final class ThreeDS2ActionHandler: ThreeDS2ClassicActionHandler {

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter fingerprintSubmitter: The fingerprint submiter.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal init(fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter,
                  service: AnyADYService,
                  appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        super.init(appearanceConfiguration: appearanceConfiguration)
        self.fingerprintSubmitter = fingerprintSubmitter
        self.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    override internal init(appearanceConfiguration: ADYAppearanceConfiguration) {
        super.init(appearanceConfiguration: appearanceConfiguration)
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action using full flow.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    override internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                                  completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
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

    override internal func createDetailsObject(from result: ThreeDSResult) -> AdditionalDetails {
        ThreeDS2Details.completed(result)
    }

    // MARK: - Private

    /// :nodoc:
    private lazy var fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter = {
        let handler = ThreeDS2FingerprintSubmitter()

        handler.environment = environment
        handler.clientKey = clientKey

        return handler
    }()

    private let threeDS2EventName = "3ds2"

}
