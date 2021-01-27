//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// An action handler component to perform any supported action out of the box.
public final class AdyenActionHandler: ActionComponent, Localizable {
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Indicates the UI configuration of the redirect component.
    public var redirectComponentStyle: RedirectComponentStyle?
    
    /// Indicates the UI configuration of the await component.
    public var awaitComponentStyle: AwaitComponentStyle?

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public init() {}
    
    // MARK: - Performing Actions
    
    /// Performs an action to complete a payment.
    ///
    /// - Parameter action: The action to perform.
    public func perform(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            perform(redirectAction)
        case let .threeDS2Fingerprint(fingerprintAction):
            perform(fingerprintAction)
        case let .threeDS2Challenge(challengeAction):
            perform(challengeAction)
        case let .threeDS2(threeDS2Action):
            perform(threeDS2Action)
        case let .sdk(sdkAction):
            perform(sdkAction)
        case let .await(awaitAction):
            perform(awaitAction)
        }
    }
    
    /// Dismiss any `DismissableComponent` managed by the `AdyenActionHandler`, for example when payment has concluded.
    ///
    /// - Parameter animated: A boolean indicating whether to dismiss with animation or not.
    /// - Parameter completion: A closure to execute when dismissal animation has completed.
    internal func dismiss(_ animated: Bool, completion: (() -> Void)?) {
        redirectComponent?.dismiss(animated, completion: completion)
    }
    
    // MARK: - Private
    
    private var redirectComponent: RedirectComponent?
    private var threeDS2Component: ThreeDS2Component?
    internal var weChatPaySDKActionComponent: AnyWeChatPaySDKActionComponent?
    private var awaitComponent: AwaitComponent?
    
    private func perform(_ action: RedirectAction) {
        let component = RedirectComponent(style: redirectComponentStyle)
        component.delegate = delegate
        component._isDropIn = _isDropIn
        component.environment = environment
        component.clientKey = clientKey
        redirectComponent = component
        
        component.handle(action)
    }

    private func perform(_ action: ThreeDS2Action) {
        let component = createThreeDS2Component()
        threeDS2Component = component

        component.handle(action)
    }
    
    private func perform(_ action: ThreeDS2FingerprintAction) {
        let component = createThreeDS2Component()
        threeDS2Component = component
        
        component.handle(action)
    }

    private func createThreeDS2Component() -> ThreeDS2Component {
        let component = ThreeDS2Component()
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.environment = environment
        component.clientKey = clientKey

        return component
    }
    
    private func perform(_ action: ThreeDS2ChallengeAction) {
        guard let threeDS2Component = threeDS2Component else { return }
        threeDS2Component.handle(action)
    }
    
    private func perform(_ sdkAction: SDKAction) {
        switch sdkAction {
        case let .weChatPay(weChatPaySDKAction):
            perform(weChatPaySDKAction)
        }
    }
    
    private func perform(_ action: WeChatPaySDKAction) {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else {
            delegate?.didFail(with: ComponentError.paymentMethodNotSupported, from: self)
            return
        }
        weChatPaySDKActionComponent = classObject.init()
        weChatPaySDKActionComponent?._isDropIn = _isDropIn
        weChatPaySDKActionComponent?.environment = environment
        weChatPaySDKActionComponent?.clientKey = clientKey
        weChatPaySDKActionComponent?.delegate = delegate
        weChatPaySDKActionComponent?.handle(action)
    }
    
    private func perform(_ action: AwaitAction) {
        guard environment.clientKey != nil else {
            // swiftlint:disable:next line_length
            assertionFailure("Failed to instantiate AwaitComponent because client key is not configured. Please supply the client key in the PaymentMethodsConfiguration if using DropInComponent, or AdyenActionHandler.clientKey if using AdyenActionHandler separately.")
            return
        }
        let component = AwaitComponent(style: awaitComponentStyle)
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.environment = environment
        component.localizationParameters = localizationParameters
        component.clientKey = clientKey
        component.localizationParameters = localizationParameters
        
        component.handle(action)
        awaitComponent = component
    }
    
}
