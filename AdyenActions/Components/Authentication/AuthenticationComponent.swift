//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.Component
import Foundation

internal protocol AnyRedirectComponent: ActionComponent {
    func handle(_ action: RedirectAction)
}

/// Handles the 3D Secure 2 fingerprint and challenge.
@MainActor
package final class AuthenticationComponent: ActionComponent {

    /// The context object for this component.
    package let context: AdyenContext

    /// The delegate of the component.
    package weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.  This property must be set if you wish to use delegated authentication.
    package weak var presentationDelegate: PresentationDelegate? {
        didSet {
            threeDS2CompactFlowHandler.presentationDelegate = presentationDelegate
        }
    }
    
    package var configuration: AuthenticationConfiguration {
        didSet {
            updateConfiguration()
        }
    }
    
    package init(
        context: AdyenContext,
        configuration: AuthenticationConfiguration = .init()
    ) {
        self.context = context
        self.configuration = configuration

        self.updateConfiguration()
    }
    
    internal convenience init(
        context: AdyenContext,
        threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler,
        redirectComponent: AnyRedirectComponent,
        configuration: AuthenticationConfiguration = .init()
    ) {
        self.init(
            context: context,
            configuration: configuration
        )
        self.threeDS2CompactFlowHandler = threeDS2CompactFlowHandler
        self.redirectComponent = redirectComponent
        self.updateConfiguration()
    }
    
    private func updateConfiguration() {
        let threeDSRequestorAppURL = configuration.requestorAppURL
        threeDS2CompactFlowHandler.threeDSRequestorAppURL = threeDSRequestorAppURL
    }

    // MARK: - 3D Secure 2 action
    
    /// Handles the 3D Secure 2 action.
    ///
    /// - Parameter threeDS2Action: The 3D Secure 2 action as received from the Checkout API.
    package func handle(_ threeDS2Action: ThreeDS2Action) {
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

    internal lazy var threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2CompactActionHandler(
            context: context,
            service: ThreeDSServiceProvider(),
            theme: configuration.theme,
            delegatedAuthenticationConfiguration: configuration.delegatedAuthentication
        )
        handler.presentationDelegate = presentationDelegate
        handler._isDropIn = _isDropIn
        handler.threeDSRequestorAppURL = configuration.requestorAppURL

        return handler
    }()

    private lazy var redirectComponent: AnyRedirectComponent = {
        let component = RedirectComponent(context: context)
        component.configuration.style = configuration.redirectComponentStyle

        component.delegate = self
        component._isDropIn = _isDropIn
        component.presentationDelegate = presentationDelegate

        return component
    }()
}

/// This is for the RedirectComponent inside the AuthenticationComponent
extension AuthenticationComponent: ActionComponentDelegate {

    package func didOpenExternalApplication(component: ActionComponent) {
        delegate?.didOpenExternalApplication(component: self)
    }

    package func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }

    package func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }

    package func didFail(with error: Swift.Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }

}

extension AuthenticationComponent {

    /// An error that occurred during the use of the 3D Secure 2 component.
    // TODO: Robert: AuthenticationComponent: This should not be public, instead made as part of the Checkout objects error handling.
    package enum Error: Swift.Error {

        /// Indicates that the challenge action was provided while no 3D Secure transaction was active.
        /// This is likely the result of calling handle(_:) with a challenge action after the challenge was already completed,
        /// or before a fingerprint action was provided.
        case missingTransaction

        /// Indicates that the Checkout API returned an unexpected `Action` during processing the 3DS2 flow.
        case unexpectedAction

    }

}
