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
    /// - Parameter threeDS2Component: The internal threeDS2Component
    /// - Parameter redirectComponentStyle: `RedirectComponent` style
    internal convenience init(threeDS2Component: AnyThreeDS2Component,
                              redirectComponentStyle: RedirectComponentStyle? = nil) {
        self.init(redirectComponentStyle: redirectComponentStyle)
        self.threeDS2Component = threeDS2Component
    }
    
    // MARK: - Fingerprint
    
    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter action: The fingerprint action as received from the Checkout API.
    public func handle(_ action: ThreeDS2FingerprintAction) {
        threeDS2Component.handle(action) { [weak self] result in
            self?.handle(result)
        }
    }
    
    // MARK: - Challenge
    
    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter action: The challenge action as received from the Checkout API.
    public func handle(_ action: ThreeDS2ChallengeAction) {
        threeDS2Component.handle(action) { [weak self] result in
            switch result {
            case let .success(data):
                self?.didFinish(data: data)
            case let .failure(error):
                self?.didFail(with: error)
            }
        }
    }
    
    // MARK: - Private

    private func handle(_ result: Result<Action, Error>) {
        switch result {
        case let .success(action):
            handle(action)
        case let .failure(error):
            didFail(with: error)
        }
    }

    private func handle(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            handle(redirectAction)
        case let .threeDS2Challenge(threeDS2ChallengeAction):
            handle(threeDS2ChallengeAction)
        default:
            didFail(with: ThreeDS2ComponentError.unexpectedAction)
        }
    }

    private func handle(_ redirectAction: RedirectAction) {
        redirectComponent.handle(redirectAction)
    }

    private func didFinish(data: ActionComponentData) {
        delegate?.didProvide(data, from: self)
    }

    private func didFail(with error: Error) {
        delegate?.didFail(with: error, from: self)
    }

    private lazy var threeDS2Component: AnyThreeDS2Component = {
        let component = InternalThreeDS2Component()

        component._isDropIn = _isDropIn
        component.environment = environment
        component.clientKey = clientKey

        return component
    }()

    private lazy var redirectComponent: RedirectComponent = {
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
