//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
/// :nodoc:
internal class ThreeDS2ClassicActionHandler: AnyThreeDS2ActionHandler, ComponentWrapper {
    
    /// :nodoc:
    internal let apiContext: APIContext

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
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    /// :nodoc:
    internal convenience init(apiContext: APIContext,
                              service: AnyADYService,
                              appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
        self.init(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)
        self.coreActionHandler.service = service
    }

    /// Initializes the 3D Secure 2 action handler.
    internal init(apiContext: APIContext, appearanceConfiguration: ADYAppearanceConfiguration) {
        self.apiContext = apiContext
        self.coreActionHandler = ThreeDS2CoreActionHandler(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter completionHandler: The completion closure.
    /// :nodoc:
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        let event = Analytics.Event(
            component: fingerprintEventName,
            flavor: _isDropIn ? .dropin : .components,
            environment: apiContext.environment
        )
        coreActionHandler.handle(fingerprintAction, event: event) { result in
            switch result {
            case let .success(encodedFingerprint):
                let additionalDetails = ThreeDS2Details.fingerprint(encodedFingerprint)
                let result = ThreeDSActionHandlerResult.details(additionalDetails)
                completionHandler(.success(result))
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
        let event = Analytics.Event(
            component: challengeEventName,
            flavor: _isDropIn ? .dropin : .components,
            environment: apiContext.environment
        )
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
        let additionalDetails = ThreeDS2Details.challengeResult(threeDSResult)
        completionHandler(.success(.details(additionalDetails)))
    }
    
    // MARK: - Private

    private let fingerprintEventName = "3ds2fingerprint"

    private let challengeEventName = "3ds2challenge"

}
