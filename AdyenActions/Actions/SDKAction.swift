//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to an SDK.
public enum SDKAction: Decodable {
    
    /// Indicates a WeChat Pay SDK action.
    case weChatPay(WeChatPaySDKAction)
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SDKType.self, forKey: CodingKeys.type)
        
        switch type {
        case .weChatPay:
            self = .weChatPay(try WeChatPaySDKAction(from: decoder))
        }
    }

    /// :nodoc:
    internal init(sdkData: WeChatPaySDKData, paymentData: String) {
        self = .weChatPay(WeChatPaySDKAction(sdkData: sdkData, paymentData: paymentData))
    }
    
    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case type = "paymentMethodType"
    }
    
    /// :nodoc:
    private enum SDKType: String, Decodable {
        case weChatPay = "wechatpaySDK"
    }
}
