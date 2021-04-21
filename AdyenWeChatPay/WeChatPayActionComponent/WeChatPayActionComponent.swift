//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenActions)
    import AdyenActions
#endif
import Adyen
import AdyenWeChatPayInternal
import Foundation

/// Action component to handle WeChat Pay SDK action.
public final class WeChatPaySDKActionComponent: NSObject, AnyWeChatPaySDKActionComponent {
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    private var currentlyHandledAction: WeChatPaySDKAction?
    
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
        
        Analytics.sendEvent(component: "wechatpaySDK", flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        currentlyHandledAction = action
        
        RedirectListener.registerForURL { url in
            WXApi.handleOpen(url, delegate: self)
        }
        
        WXApi.registerApp(action.sdkData.appIdentifier)
        WXApi.send(PayReq(actionData: action.sdkData))
        
        delegate?.didOpenExternalApplication(self)
    }
    
    /// Checks if the current device supports WeChat Pay.
    public static func isDeviceSupported() -> Bool {
        assertWeChatPayAppSchemeConfigured()
        WXApi.registerApp("")
        return WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
    }
    
    private static func assertWeChatPayAppSchemeConfigured() {
        guard Bundle.main.adyen.isSchemeConfigured("weixin") else {
            return AdyenAssertion.assert(message: "weixin:// scheme must be added to Info.plist under LSApplicationQueriesSchemes key.")
        }
    }
    
}

/// :nodoc:
extension WeChatPaySDKActionComponent: WXApiDelegate {

    /// :nodoc:
    public func onResp(_ resp: BaseResp) {
        guard let currentlyHandledAction = currentlyHandledAction else {
            return AdyenAssertion.assert(message: "no WeChatPaySDKAction were handled")
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
