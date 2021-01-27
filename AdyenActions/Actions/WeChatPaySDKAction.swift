//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to the WeChat Pay SDK.
public final class WeChatPaySDKAction: Decodable {
    
    /// The WeChat Pay SDK specific data.
    public let sdkData: WeChatPaySDKData
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    internal init(sdkData: WeChatPaySDKData, paymentData: String) {
        self.sdkData = sdkData
        self.paymentData = paymentData
    }
    
}
