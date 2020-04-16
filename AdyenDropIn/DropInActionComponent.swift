//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A drop-in component to perform any supported action out of the box.
public final class DropInActionComponent: ActionComponent {
    
    /// The view controller to use to present other action related view controllers, e.g Redirect Action.
    public weak var presenterViewController: UIViewController?
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// Indicates the UI configuration of the redirect component.
    public var redirectComponentStyle: RedirectComponentStyle?
    
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
        case let .sdk(sdkAction):
            perform(sdkAction)
        }
    }
    
    // MARK: - Private
    
    private var redirectComponent: RedirectComponent?
    private var threeDS2Component: ThreeDS2Component?
    private var weChatPaySDKActionComponent: AnyWeChatPaySDKActionComponent?
    
    private func perform(_ action: RedirectAction) {
        let component = RedirectComponent(style: redirectComponentStyle)
        component.delegate = delegate
        component._isDropIn = _isDropIn
        component.environment = environment
        component.presentingViewController = presenterViewController
        redirectComponent = component
        
        component.handle(action)
    }
    
    private func perform(_ action: ThreeDS2FingerprintAction) {
        let component = ThreeDS2Component()
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.environment = environment
        threeDS2Component = component
        
        component.handle(action)
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
        weChatPaySDKActionComponent?.delegate = delegate
        weChatPaySDKActionComponent?.handle(action)
    }
    
}
