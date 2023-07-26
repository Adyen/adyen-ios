//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

internal protocol AnyRedirectComponent: ActionComponent {
    func handle(_ action: RedirectAction)
}

/// Handles the 3D Secure 2 fingerprint and challenge.
public final class ThreeDS2Component: ActionComponent {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    public let appearanceConfiguration = ADYAppearanceConfiguration()
    
    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?

    /// `RedirectComponent` style
    public let redirectComponentStyle: RedirectComponentStyle?

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter redirectComponentStyle: `RedirectComponent` style
    public init(apiContext: APIContext,
                redirectComponentStyle: RedirectComponentStyle? = nil) {
        self.apiContext = apiContext
        self.redirectComponentStyle = redirectComponentStyle
    }

    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter threeDS2CompactFlowHandler: The internal `AnyThreeDS2ActionHandler` for the compact flow.
    /// - Parameter threeDS2ClassicFlowHandler: The internal `AnyThreeDS2ActionHandler` for the classic flow.
    /// - Parameter redirectComponent: The redirect component.
    /// - Parameter redirectComponentStyle: `RedirectComponent` style.
    /// :nodoc:
    internal convenience init(apiContext: APIContext,
                              threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler,
                              threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandler,
                              redirectComponent: AnyRedirectComponent,
                              redirectComponentStyle: RedirectComponentStyle? = nil) {
        self.init(apiContext: redirectComponent.apiContext, redirectComponentStyle: redirectComponentStyle)
        self.threeDS2CompactFlowHandler = threeDS2CompactFlowHandler
        self.threeDS2ClassicFlowHandler = threeDS2ClassicFlowHandler
        self.redirectComponent = redirectComponent
    }

    // MARK: - 3D Secure 2 action
    
    /// Handles the 3D Secure 2 action.
    ///
    /// - Parameter threeDS2Action: The 3D Secure 2 action as received from the Checkout API.
    public func handle(_ threeDS2Action: ThreeDS2Action) {
        switch threeDS2Action {
        case let .fingerprint(fingerprintAction):
            threeDS2CompactFlowHandler.handle(fingerprintAction) { [weak self] result in
                self?.didReceive(result, paymentData: nil)
            }
        case let .challenge(challengeAction):
            threeDS2CompactFlowHandler.handle(challengeAction) { [weak self] result in
                self?.didReceive(result, paymentData: nil)
            }
        }
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    public func handle(_ fingerprintAction: ThreeDS2FingerprintAction) {
        threeDS2ClassicFlowHandler.handle(fingerprintAction) { [weak self] result in
            self?.didReceive(result, paymentData: fingerprintAction.paymentData)
        }
    }
    
    // MARK: - Challenge
    
    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    public func handle(_ challengeAction: ThreeDS2ChallengeAction) {
        threeDS2ClassicFlowHandler.handle(challengeAction) { [weak self] result in
            self?.didReceive(result, paymentData: challengeAction.paymentData)
        }
    }
    
    // MARK: - Private

    private func didReceive(_ result: Result<ThreeDSActionHandlerResult, Swift.Error>, paymentData: String?) {
        switch result {
        case let .success(result):
            didReceive(result, paymentData: paymentData)
        case let .failure(error):
            didFail(with: error)
        }
    }

    private func didReceive(_ result: ThreeDSActionHandlerResult, paymentData: String?) {
        switch result {
        case let .action(action):
            didReceive(action)
        case let .details(details):
            let data = ActionComponentData(details: details, paymentData: paymentData)
            didFinish(data: data)
        }
    }

    private func didReceive(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            redirectComponent.handle(redirectAction)
        case let .threeDS2(threeDS2Action):
            handle(threeDS2Action)
        default:
            didFail(with: Error.unexpectedAction)
        }
    }

    private func didFinish(data: ActionComponentData) {
        delegate?.didProvide(data, from: self)
    }

    private func didFail(with error: Swift.Error) {
        delegate?.didFail(with: error, from: self)
    }

    private lazy var threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2CompactActionHandler(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)

        handler._isDropIn = _isDropIn

        return handler
    }()

    private lazy var threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2ClassicActionHandler(apiContext: apiContext, appearanceConfiguration: appearanceConfiguration)

        handler._isDropIn = _isDropIn

        return handler
    }()

    private lazy var redirectComponent: AnyRedirectComponent = {
        let component = RedirectComponent(apiContext: apiContext, style: redirectComponentStyle)

        component.delegate = self
        component._isDropIn = _isDropIn
        component.presentationDelegate = presentationDelegate

        return component
    }()
}

extension ThreeDS2Component: ActionComponentDelegate {

    public func didOpenExternalApplication(_ component: ActionComponent) {
        delegate?.didOpenExternalApplication(self)
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }

    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }

    public func didFail(with error: Swift.Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }

}

extension ThreeDS2Component {

    /// An error that occurred during the use of the 3D Secure 2 component.
    public enum Error: Swift.Error {

        /// Indicates that the challenge action was provided while no 3D Secure transaction was active.
        /// This is likely the result of calling handle(_:) with a challenge action after the challenge was already completed,
        /// or before a fingerprint action was provided.
        case missingTransaction

        /// Indicates that the Checkout API returned an unexpected `Action` during processing the 3DS2 flow.
        case unexpectedAction
    }

}
