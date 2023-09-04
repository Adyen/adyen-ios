//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

/// Handles the 3D Secure 2 fingerprint and challenge in one call using a `fingerprintSubmitter`.
/// :nodoc:
internal final class ThreeDS2CompactActionHandler: AnyThreeDS2ActionHandler, ComponentWrapper {

    /// :nodoc:
    internal var wrappedComponent: Component { coreActionHandler }

    /// :nodoc:
    private let coreActionHandler: ThreeDS2CoreActionHandler

    /// :nodoc:
    internal var transaction: AnyADYTransaction? {
        get {
            coreActionHandler.transaction
        }

        set {
            coreActionHandler.transaction = newValue
        }
    }

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter fingerprintSubmitter: The fingerprint submitter.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal convenience init(apiContext: APIContext,
                              fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter? = nil,
                              service: AnyADYService,
                              appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.init(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)
        if let fingerprintSubmitter {
            self.fingerprintSubmitter = fingerprintSubmitter
        }
        self.coreActionHandler.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    internal init(apiContext: APIContext, appearanceConfiguration: ADYAppearanceConfiguration) {
        self.coreActionHandler = ThreeDS2CoreActionHandler(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action using full flow.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let event = Analytics.Event(component: "\(threeDS2EventName).fingerprint",
                                    flavor: _isDropIn ? .dropin : .components,
                                    environment: apiContext.environment)
        coreActionHandler.handle(fingerprintAction, event: event) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(encodedFingerprint):
                self.fingerprintSubmitter.submit(fingerprint: encodedFingerprint,
                                                 paymentData: fingerprintAction.paymentData,
                                                 completionHandler: completionHandler)
            case let .failure(error):
                completionHandler(.failure(error))
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
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let event = Analytics.Event(component: "\(threeDS2EventName).challenge",
                                    flavor: _isDropIn ? .dropin : .components,
                                    environment: apiContext.environment)
        coreActionHandler.handle(challengeAction, event: event) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(result):
                self.handle(result, completionHandler: completionHandler)
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    private func handle(_ threeDSResult: ThreeDSResult,
                        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let additionalDetails = ThreeDS2Details.completed(threeDSResult)
        completionHandler(.success(.details(additionalDetails)))
    }

    // MARK: - Private

    /// :nodoc:
    private lazy var fingerprintSubmitter: AnyThreeDS2FingerprintSubmitter = ThreeDS2FingerprintSubmitter(apiContext: apiContext)

    private let threeDS2EventName = "3ds2"

}
