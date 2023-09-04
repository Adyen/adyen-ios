//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenActions)
    import AdyenActions
#endif

import Adyen
import Foundation

#if !targetEnvironment(simulator) && canImport(AdyenWeChatPayInternal)

    import AdyenWeChatPayInternal

    /// Action component to handle WeChat Pay SDK action.
    public final class WeChatPaySDKActionComponent: NSObject, AnyWeChatPaySDKActionComponent {

        private static let universalLink = "https://www.adyen.com/"
    
        /// :nodoc:
        public let apiContext: APIContext
    
        /// :nodoc:
        public weak var delegate: ActionComponentDelegate?
    
        /// :nodoc:
        private var currentlyHandledAction: WeChatPaySDKAction?
    
        /// :nodoc:
        public init(apiContext: APIContext) {
            self.apiContext = apiContext
        }
    
        /// :nodoc:
        public func handle(_ action: WeChatPaySDKAction) {
            guard Self.isDeviceSupported() else {
                delegate?.didFail(with: ComponentError.paymentMethodNotSupported, from: self)
                return
            }

            assert(Thread.isMainThread, "present(actionData:) must be called on the main thread.")
            assert(currentlyHandledAction == nil, """
              Warning: There was a WeChatPaySDKAction already in progress.
             Handling multiple WeChatPaySDKAction's in parallel is not supported.
            """)
        
            Analytics.sendEvent(component: "wechatpaySDK", flavor: _isDropIn ? .dropin : .components, context: apiContext)
        
            currentlyHandledAction = action
        
            RedirectListener.registerForURL { url in
                WXApi.handleOpen(url, delegate: self)
            }
        
            WXApi.registerApp(action.sdkData.appIdentifier, universalLink: WeChatPaySDKActionComponent.universalLink)
            WXApi.send(PayReq(actionData: action.sdkData))
        
            delegate?.didOpenExternalApplication(self)
        }
    
        /// Checks if the current device supports WeChat Pay.
        public static func isDeviceSupported() -> Bool {
            assertWeChatPayAppSchemeConfigured()
            WXApi.registerApp("", universalLink: WeChatPaySDKActionComponent.universalLink)
            return WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
        }
    
        private static func assertWeChatPayAppSchemeConfigured() {
            guard Bundle.main.adyen.isSchemeConfigured("weixin") else {
                // swiftlint:disable:next line_length
                return AdyenAssertion.assertionFailure(message: "weixin:// scheme must be added to Info.plist under LSApplicationQueriesSchemes key.")
            }
        }

    }

    /// :nodoc:
    extension WeChatPaySDKActionComponent: WXApiDelegate {

        /// :nodoc:
        public func onResp(_ resp: BaseResp) {
            guard let currentlyHandledAction else {
                return AdyenAssertion.assertionFailure(message: "no WeChatPaySDKAction were handled")
            }
            let additionalData = WeChatPayAdditionalDetails(resultCode: String(resp.errCode))
            let actionData = ActionComponentData(details: additionalData, paymentData: currentlyHandledAction.paymentData)
            delegate?.didProvide(actionData, from: self)
            self.currentlyHandledAction = nil
        }
    
    }

    /// :nodoc:
    private extension PayReq {
        /// :nodoc:
        convenience init(actionData: WeChatPaySDKData) {
            self.init()
        
            openID = actionData.appIdentifier
            partnerId = actionData.partnerIdentifier
            prepayId = actionData.prepayIdentifier
            timeStamp = UInt32(actionData.timestamp)!
            package = actionData.package
            nonceStr = actionData.nonce
            sign = actionData.signature
        }
    }
#else

    /// :nodoc:
    /// Action component to handle WeChat Pay SDK action.
    public final class WeChatPaySDKActionComponent: NSObject, AnyWeChatPaySDKActionComponent {

        /// :nodoc:
        public let apiContext: APIContext

        /// :nodoc:
        public weak var delegate: ActionComponentDelegate?

        /// :nodoc:
        public init(apiContext: APIContext) {
            self.apiContext = apiContext
        }

        /// :nodoc:
        public func handle(_ action: WeChatPaySDKAction) {
            AdyenAssertion.assertionFailure(message: "WeChatPaySDKActionComponent can only work on a real device.")
        }

        /// Checks if the current device supports WeChat Pay.
        public static func isDeviceSupported() -> Bool {
            false
        }

    }

#endif
