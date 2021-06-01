//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// An action handler component to perform any supported action out of the box.
public final class AdyenActionComponent: ActionComponent, Localizable {
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Indicates the UI configuration of the redirect component.
    public var redirectComponentStyle: RedirectComponentStyle?
    
    /// Indicates the UI configuration of the await component.
    public var awaitComponentStyle: AwaitComponentStyle?

    /// Indicates the UI configuration of the voucher component.
    public var voucherComponentStyle: VoucherComponentStyle?

    /// Indicates the UI configuration of the QR code component.
    public var qrCodeComponentStyle: QRCodeComponentStyle?

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public init(apiContext: APIContext) {
        self.apiContext = apiContext
    }
    
    // MARK: - Performing Actions
    
    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            handle(redirectAction)
        case let .threeDS2Fingerprint(fingerprintAction):
            handle(fingerprintAction)
        case let .threeDS2Challenge(challengeAction):
            handle(challengeAction)
        case let .threeDS2(threeDS2Action):
            handle(threeDS2Action)
        case let .sdk(sdkAction):
            handle(sdkAction)
        case let .await(awaitAction):
            handle(awaitAction)
        case let .voucher(voucher):
            handle(voucher)
        case let .qrCode(qrCode):
            handle(qrCode)
        }
    }
    
    // MARK: - Private
    
    private var redirectComponent: RedirectComponent?
    internal var threeDS2Component: ThreeDS2Component?
    internal var weChatPaySDKActionComponent: AnyWeChatPaySDKActionComponent?
    private var awaitComponent: AwaitComponent?
    private var voucherComponent: VoucherComponent?
    private var qrCodeComponent: Component?
    
    private func handle(_ action: RedirectAction) {
        let component = RedirectComponent(apiContext: apiContext, style: redirectComponentStyle)
        component.delegate = delegate
        component._isDropIn = _isDropIn
        component.presentationDelegate = presentationDelegate
        redirectComponent = component
        
        component.handle(action)
    }

    private func handle(_ action: ThreeDS2Action) {
        let component = createThreeDS2Component()
        threeDS2Component = component

        component.handle(action)
    }
    
    private func handle(_ action: ThreeDS2FingerprintAction) {
        let component = createThreeDS2Component()
        threeDS2Component = component
        
        component.handle(action)
    }

    private func createThreeDS2Component() -> ThreeDS2Component {
        let component = ThreeDS2Component(apiContext: apiContext)
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate

        return component
    }
    
    private func handle(_ action: ThreeDS2ChallengeAction) {
        guard let threeDS2Component = threeDS2Component else { return }
        threeDS2Component.handle(action)
    }
    
    private func handle(_ sdkAction: SDKAction) {
        switch sdkAction {
        case let .weChatPay(weChatPaySDKAction):
            handle(weChatPaySDKAction)
        }
    }
    
    private func handle(_ action: WeChatPaySDKAction) {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else {
            delegate?.didFail(with: ComponentError.paymentMethodNotSupported, from: self)
            return
        }
        weChatPaySDKActionComponent = classObject.init(apiContext: apiContext)
        weChatPaySDKActionComponent?._isDropIn = _isDropIn
        weChatPaySDKActionComponent?.delegate = delegate
        weChatPaySDKActionComponent?.handle(action)
    }
    
    private func handle(_ action: AwaitAction) {
        let component = AwaitComponent(apiContext: apiContext, style: awaitComponentStyle)
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.localizationParameters = localizationParameters
        
        component.handle(action)
        awaitComponent = component
    }
    
    private func handle(_ action: VoucherAction) {
        let component = VoucherComponent(apiContext: apiContext, style: voucherComponentStyle)
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.localizationParameters = localizationParameters

        component.handle(action)
        voucherComponent = component
    }
    
    private func handle(_ action: QRCodeAction) {
        let component = QRCodeComponent(apiContext: apiContext, style: QRCodeComponentStyle())
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.localizationParameters = localizationParameters
        
        component.handle(action)
        qrCodeComponent = component
    }
}
