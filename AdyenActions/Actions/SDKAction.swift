//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to an SDK.
public enum SDKAction: Decodable {
    
    /// Indicates a WeChat Pay SDK action.
    case weChatPay(WeChatPaySDKAction)
    
    case twint(TwintSDKAction)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SDKType.self, forKey: CodingKeys.type)
        
        switch type {
        case .weChatPay:
            self = try .weChatPay(WeChatPaySDKAction(from: decoder))
        case .twint:
            self = try .twint(TwintSDKAction(from: decoder))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type = "paymentMethodType"
    }
    
    private enum SDKType: String, Decodable {
        case weChatPay = "wechatpaySDK"
        case twint
    }
}
