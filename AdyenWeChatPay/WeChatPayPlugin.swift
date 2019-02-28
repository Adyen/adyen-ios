//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import AdyenWeChatPayInternal
import Foundation

/// A plugin that handles WeChatPay SDK communication.
internal final class WeChatPayPlugin: NSObject, AdditionalPaymentDetailsPlugin {
    
    // MARK: - Plugin
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
    internal var isDeviceSupported: Bool {
        var isSupported = false
        
        DispatchQueue.main.sync {
            WXApi.registerApp("")
            isSupported = WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
        }
        
        return isSupported
    }
    
    // MARK: - AdditionalPaymentDetailsPlugin
    
    internal func present(_ details: AdditionalPaymentDetails, using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<Result<[PaymentDetail]>>) {
        additionalPaymentDetails = details
        completionHandler = completion
        
        RedirectListener.registerForURL { [weak self] url in
            WXApi.handleOpen(url, delegate: self)
        }
        
        let redirectData = WeChatRedirectData(dictionary: details.userInfo)
        WXApi.registerApp(redirectData.appIdentifier)
        WXApi.send(PayReq(redirectData: redirectData))
    }
    
    private var additionalPaymentDetails: AdditionalPaymentDetails?
    private var completionHandler: Completion<Result<[PaymentDetail]>>?
    
}

extension WeChatPayPlugin: WXApiDelegate {
    
    func onResp(_ resp: BaseResp!) {
        var details = additionalPaymentDetails?.details ?? []
        details.weChatResultCode?.value = String(resp.errCode)
        completionHandler?(.success(details))
    }
    
}

fileprivate extension PayReq {
    
    convenience init(redirectData: WeChatRedirectData) {
        self.init()
        
        openID = redirectData.appIdentifier
        partnerId = redirectData.partnerIdentifier
        prepayId = redirectData.prepayIdentifier
        timeStamp = redirectData.timestamp
        package = redirectData.package
        nonceStr = redirectData.nonce
        sign = redirectData.signature
    }
    
}
