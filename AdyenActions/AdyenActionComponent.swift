//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation
import UIKit

/**
 An action handler component to perform any supported action out of the box.
 
 - SeeAlso:
 [Implementation Reference](https://github.com/Adyen/adyen-ios#handling-an-action)
 */
public final class AdyenActionComponent: ActionComponent, ActionHandlingComponent {
    
    /// :nodoc:
    /// The context object for this component.
    public let context: AdyenContext
    
    /// The object that acts as the delegate of the action component.
    public weak var delegate: ActionComponentDelegate?
    
    /// The object that acts as the presentation delegate of the action component.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Action handling configurations.
    public var configuration: Configuration
    
    /// Action handling configurations.
    public struct Configuration: Localizable {
        
        /// Localization parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// The UI style configurations.
        public var style: ActionComponentStyle = .init()
        
        /// Three DS configurations
        public var threeDS: ThreeDS = .init()
        
        /// Three DS configurations
        public struct ThreeDS {
            /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
            public var requestorAppURL: URL?
            
            /// The configuration for Delegated Authentication.
            public var delegateAuthentication: ThreeDS2Component.Configuration.DelegatedAuthentication?
            
            /// ThreeDS2Component UI configuration.
            public var appearanceConfiguration: ADYAppearanceConfiguration
            
            /// Initializes a new instance
            ///
            /// - Parameter requestorAppURL: `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
            public init(requestorAppURL: URL? = nil,
                        delegateAuthentication: ThreeDS2Component.Configuration.DelegatedAuthentication? = nil,
                        appearanceConfiguration: ADYAppearanceConfiguration = .init()) {
                self.requestorAppURL = requestorAppURL
                self.delegateAuthentication = delegateAuthentication
                self.appearanceConfiguration = appearanceConfiguration
            }
        }
        
        public var twint: Twint?
        
        public struct Twint {
            
            /// The callback app scheme invoked once the Twint app is done with the payment
            public var callbackAppScheme: String
            
            /// Initializes a new instance
            ///
            /// - Parameter callbackAppScheme: The callback app scheme invoked once the Twint app is done with the payment
            ///
            /// - Important: The value of ``callbackAppScheme`` is  required to only provide the scheme,
            /// without a host/path/... (e.g. "my-app", not a url "my-app://...")
            public init(callbackAppScheme: String) {
                if !Self.isCallbackSchemeValid(callbackAppScheme) {
                    AdyenAssertion.assertionFailure(message: "Format of provided callbackAppScheme '\(callbackAppScheme)' is incorrect.")
                }
                
                self.callbackAppScheme = callbackAppScheme
            }
            
            /// Validating whether or not the provided `callbackAppScheme` only contains a scheme
            private static func isCallbackSchemeValid(_ callbackAppScheme: String) -> Bool {
                if let url = URL(string: callbackAppScheme), url.scheme != nil {
                    // If the scheme is not nil it means that more information than just the scheme was provided
                    return false
                }
                
                return true
            }
        }
        
        /// Initializes a new instance
        ///
        /// - Parameters:
        ///   - localizationParameters: Localization parameters.
        ///   - style: The UI style configurations.
        ///   - threeDS: Three DS configurations
        ///   - twint: Twint configurations
        public init(
            localizationParameters: LocalizationParameters? = nil,
            style: ActionComponentStyle = .init(),
            threeDS: AdyenActionComponent.Configuration.ThreeDS = .init(),
            twint: Twint? = nil
        ) {
            self.localizationParameters = localizationParameters
            self.style = style
            self.threeDS = threeDS
            self.twint = twint
        }
    }
    
    internal var currentActionComponent: Component?
    
    /// Initializes a new instance of `AdyenActionComponent`
    ///
    /// - Parameters:
    ///   - context: The context object.
    ///   - configuration: The configuration.
    public init(context: AdyenContext,
                configuration: Configuration = Configuration()) {
        self.context = context
        self.configuration = configuration
    }
    
    // MARK: - Performing Actions
    
    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        
        sendHandleEvent(for: action)
        
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
        case let .redirectableAwait(redirectableAwaitAction):
            handleRedirectableAwait(redirectableAwaitAction)
        case let .voucher(voucher):
            handle(voucher)
        case let .qrCode(qrCode):
            handle(qrCode)
        case let .document(documentAction):
            handle(documentAction)
        }
    }
    
    private func sendHandleEvent(for action: Action) {
        let logEvent = AnalyticsEventLog(component: action.analyticsType, type: .action)
        context.analyticsProvider?.add(log: logEvent)
    }
    
    // MARK: - Private
    
    private func handle(_ action: RedirectAction) {
        let component = RedirectComponent(context: context)
        component.configuration.style = configuration.style.redirectComponentStyle
        component.delegate = delegate
        component._isDropIn = _isDropIn
        component.presentationDelegate = presentationDelegate
        currentActionComponent = component
        
        component.handle(action)
    }
    
    private func handle(_ action: ThreeDS2Action) {
        let component = createThreeDS2Component()
        currentActionComponent = component
        
        component.handle(action)
    }
    
    private func handle(_ action: ThreeDS2FingerprintAction) {
        let component = createThreeDS2Component()
        currentActionComponent = component
        
        component.handle(action)
    }
    
    private func createThreeDS2Component() -> ThreeDS2Component {
        let threeDS2Configuration = ThreeDS2Component.Configuration(redirectComponentStyle: configuration.style.redirectComponentStyle,
                                                                    appearanceConfiguration: configuration.threeDS.appearanceConfiguration,
                                                                    requestorAppURL: configuration.threeDS.requestorAppURL,
                                                                    delegateAuthentication: configuration.threeDS.delegateAuthentication)
        let component = ThreeDS2Component(context: context, configuration: threeDS2Configuration)
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        
        return component
    }
    
    private func handle(_ action: ThreeDS2ChallengeAction) {
        guard let threeDS2Component = currentActionComponent as? ThreeDS2Component else {
            AdyenAssertion.assertionFailure(
                // swiftlint:disable:next line_length
                message: "ThreeDS2Component is nil. There must be a ThreeDS2FingerprintAction action preceding a ThreeDS2ChallengeAction action"
            )
            return
        }
        threeDS2Component.handle(action)
    }
    
    private func handle(_ sdkAction: SDKAction) {
        switch sdkAction {
        case let .weChatPay(weChatPaySDKAction):
            handle(weChatPaySDKAction)
        case let .twint(twintSDKAction):
            handle(twintSDKAction)
        }
    }
    
    private func handle(_ action: WeChatPaySDKAction) {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else {
            delegate?.didFail(with: ComponentError.paymentMethodNotSupported, from: self)
            return
        }
        
        let weChatPaySDKActionComponent = classObject.init(context: context)
        weChatPaySDKActionComponent._isDropIn = _isDropIn
        weChatPaySDKActionComponent.delegate = delegate
        weChatPaySDKActionComponent.handle(action)
        
        currentActionComponent = weChatPaySDKActionComponent
    }
    
    private func handle(_ action: TwintSDKAction) {
        #if canImport(TwintSDK)
            guard let twintConfiguration = configuration.twint else {
                AdyenAssertion.assertionFailure(
                    message: "Twint action configuration instance must not be nil in order to use AdyenTwint")
                return
            }
        
            let component = TwintSDKActionComponent(
                context: context,
                configuration: .init(
                    style: configuration.style.awaitComponentStyle,
                    callbackAppScheme: twintConfiguration.callbackAppScheme,
                    localizationParameters: configuration.localizationParameters
                )
            )
            component._isDropIn = _isDropIn
            component.delegate = delegate
            component.presentationDelegate = presentationDelegate
        
            component.handle(action)
            currentActionComponent = component
        #endif
    }
    
    private func handle(_ action: AwaitAction) {
        let component = AwaitComponent(context: context)
        component.configuration.style = configuration.style.awaitComponentStyle
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.configuration.localizationParameters = configuration.localizationParameters
        
        component.handle(action)
        currentActionComponent = component
    }

    private func handleRedirectableAwait(_ action: RedireactableAwaitAction) {
        let component = AwaitComponent(context: context)
        component.configuration.style = configuration.style.awaitComponentStyle
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.configuration.localizationParameters = configuration.localizationParameters

        component.handleRedirectableAwait(action)
        currentActionComponent = component
    }

    private func handle(_ action: VoucherAction) {
        let component = VoucherComponent(context: context)
        component.configuration.style = configuration.style.voucherComponentStyle
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.configuration.localizationParameters = configuration.localizationParameters
        
        component.handle(action)
        currentActionComponent = component
    }
    
    private func handle(_ action: QRCodeAction) {
        let component = QRCodeActionComponent(context: context)
        component.configuration.style = configuration.style.qrCodeComponentStyle
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.presentationDelegate = presentationDelegate
        component.configuration.localizationParameters = configuration.localizationParameters
        
        component.handle(action)
        currentActionComponent = component
    }
    
    private func handle(_ action: DocumentAction) {
        let component = DocumentComponent(context: context)
        component.configuration.style = configuration.style.documentActionComponentStyle
        component._isDropIn = _isDropIn
        component.delegate = delegate
        component.configuration.localizationParameters = configuration.localizationParameters
        component.presentationDelegate = presentationDelegate
        
        component.handle(action)
        currentActionComponent = component
    }
}

private extension Action {
    
    var analyticsType: String {
        switch self {
        case .redirect:
            return "redirect"
        case .sdk:
            return "sdk"
        case .threeDS2Fingerprint:
            return "threeDS2Fingerprint"
        case .threeDS2Challenge:
            return "threeDS2Challenge"
        case .threeDS2:
            return "threeDS2"
        case .await, .redirectableAwait:
            return "await"
        case .voucher, .document:
            return "voucher"
        case .qrCode:
            return "qrCode"
        }
    }
}
