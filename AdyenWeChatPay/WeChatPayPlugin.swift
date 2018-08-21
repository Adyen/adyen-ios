//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import AdyenWeChatPayInternal
import Foundation

/// A plugin that handles WeChatPay SDK communication.
internal final class WeChatPayPlugin: Plugin {
    
    override var isDeviceSupported: Bool {
        var isSupported = false
        
        DispatchQueue.main.sync {
            WXApi.registerApp("")
            isSupported = WXApi.isWXAppInstalled() && WXApi.isWXAppSupport()
        }
        
        return isSupported
    }
    
    internal var completionHandler: Completion<[PaymentDetail]>?
    
    internal lazy var redirectData: WeChatRedirectData = {
        WeChatRedirectData(dictionary: additionalPaymentDetails?.redirectData)
    }()
    
    override func present(using navigationController: UINavigationController, completion: @escaping ([PaymentDetail]) -> Void) {
        completionHandler = completion
        
        RedirectListener.registerForURL { [weak self] url in
            WXApi.handleOpen(url, delegate: self)
        }
        
        WXApi.registerApp(redirectData.appIdentifier)
        WXApi.send(payRequest(for: redirectData))
    }
    
    // MARK: - Private
    
    private func payRequest(for redirectData: WeChatRedirectData) -> PayReq {
        let request = PayReq()
        
        request.openID = redirectData.appIdentifier
        request.partnerId = redirectData.partnerIdentifier
        request.prepayId = redirectData.prepayIdentifier
        request.timeStamp = redirectData.timestamp
        request.package = redirectData.package
        request.nonceStr = redirectData.nonce
        request.sign = redirectData.signature
        
        return request
    }
}

extension WeChatPayPlugin: WXApiDelegate {
    func onResp(_ resp: BaseResp!) {
        guard var details = additionalPaymentDetails?.details else {
            completionHandler?([])
            return
        }
        
        details.weChatResulCode?.value = String(resp.errCode)
        
        completionHandler?(details)
    }
}
