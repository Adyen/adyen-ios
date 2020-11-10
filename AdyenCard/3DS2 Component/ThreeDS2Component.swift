//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

/// An error that occurred during the use of the 3D Secure 2 component.
public enum ThreeDS2ComponentError: Error {
    
    /// Indicates that the challenge action was provided while no 3D Secure transaction was active.
    /// This is likely the result of calling handle(_:) with a challenge action after the challenge was already completed,
    /// or before a fingerprint action was provided.
    case missingTransaction

    /// Indicates that the Checkout API returned an unexpected `Action` during processing the finger print.
    case unexpectedAction

    /// ClientKey is required for `ThreeDS2Component` to work, and this error is thrown in case its nil.
    case missingClientKey
    
}

internal protocol AnyRedirectComponent: ActionComponent {
    func handle(_ action: RedirectAction)
}

extension RedirectComponent: AnyRedirectComponent {}

/// Handles the 3D Secure 2 fingerprint and challenge.
public final class ThreeDS2Component: ActionComponent {
    
    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?

    /// `RedirectComponent` style
    public let redirectComponentStyle: RedirectComponentStyle?
    
    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter redirectComponentStyle: `RedirectComponent` style
    public init(redirectComponentStyle: RedirectComponentStyle? = nil) {
        self.redirectComponentStyle = redirectComponentStyle
    }

    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter threeDS2ActionHandler: The internal threeDS2Component
    /// - Parameter redirectComponent: The redirect component.
    /// - Parameter redirectComponentStyle: `RedirectComponent` style
    internal convenience init(threeDS2ActionHandler: AnyThreeDS2ActionHandler,
                              redirectComponent: AnyRedirectComponent,
                              redirectComponentStyle: RedirectComponentStyle? = nil) {
        self.init(redirectComponentStyle: redirectComponentStyle)
        self.threeDS2ActionHandler = threeDS2ActionHandler
        self.redirectComponent = redirectComponent
    }

    // MARK: - 3D Secure 2 action
    
    /// Handles the 3D Secure 2 action.
    ///
    /// - Parameter threeDS2Action: The 3D Secure 2 action as received from the Checkout API.
    public func handle(_ threeDS2Action: ThreeDS2Action) {
        switch threeDS2Action {
        case let .fingerprint(fingerprintAction):
            threeDS2ActionHandler.handleFullFlow(fingerprintAction) { [weak self] actionResult in
                self?.didReceive(actionResult, fingerprintAction.paymentData)
            }
        case let .challenge(challengeAction):
            handle(challengeAction)
        }
    }

    private func didReceive(_ actionResult: Result<Action, Error>, _ paymentData: String) {
        switch actionResult {
        case let .success(action):
            didReceive(action)
        case let .failure(error):
            didFail(with: error)
        }
    }

    private func didReceive(_ action: Action) {
        switch action {
        case let .threeDS2Authenticated(authenticatedAction):
            handle(authenticatedAction)
        case let .redirect(redirectAction):
            handle(redirectAction)
        case let .threeDS2(threeDS2Action):
            handle(threeDS2Action)
        case let .threeDS2Challenge(threeDS2ChallengeAction):
            handle(threeDS2ChallengeAction)
        default:
            didFail(with: ThreeDS2ComponentError.unexpectedAction)
        }
    }

    // MARK: - Authenticated

    /// Handles the 3D Secure 2 authenticated action.
    ///
    /// - Parameter authenticatedAction: The 3D Secure 2 action as received from the Checkout API.
    public func handle(_ authenticatedAction: ThreeDS2AuthenticatedAction) {
        do {
            let result = try ChallengeResult(isAuthenticated: true)
            let details = ThreeDS2Details.challengeResult(result)
            didFinish(data: ActionComponentData(details: details, paymentData: authenticatedAction.paymentData))
        } catch {
            didFail(with: error)
        }
    }

    private func handle(_ redirectAction: RedirectAction) {
        redirectComponent.handle(redirectAction)
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    public func handle(_ fingerprintAction: ThreeDS2FingerprintAction) {
        threeDS2ActionHandler.handle(fingerprintAction) { [weak self] dataResult in
            self?.didReceive(dataResult)
        }
    }
    
    // MARK: - Challenge
    
    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    public func handle(_ challengeAction: ThreeDS2ChallengeAction) {
        threeDS2ActionHandler.handle(challengeAction) { [weak self] dataResult in
            self?.didReceive(dataResult)
        }
    }
    
    // MARK: - Private

    private func didReceive(_ dataResult: Result<ActionComponentData, Error>) {
        switch dataResult {
        case let .success(data):
            didFinish(data: data)
        case let .failure(error):
            didFail(with: error)
        }
    }

    private func didFinish(data: ActionComponentData) {
        delegate?.didProvide(data, from: self)
    }

    private func didFail(with error: Error) {
        delegate?.didFail(with: error, from: self)
    }

    private lazy var threeDS2ActionHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2ActionHandler()

        handler._isDropIn = _isDropIn
        handler.environment = environment
        handler.clientKey = clientKey

        return handler
    }()

    private lazy var redirectComponent: AnyRedirectComponent = {
        let component = RedirectComponent(style: redirectComponentStyle)

        component.delegate = self
        component._isDropIn = _isDropIn
        component.environment = environment
        component.clientKey = clientKey

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

    public func didFail(with error: Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }
}
