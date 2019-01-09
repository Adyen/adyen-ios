//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A structure that holds WeChatSDK redirect data.
public struct WeChatRedirectData {
    let appIdentifier: String
    let partnerIdentifier: String
    let prepayIdentifier: String
    let timestamp: UInt32
    let package: String
    let nonce: String
    let signature: String
    
    // Initializer that receives redirect data dictionary
    public init(dictionary: [String: String]?) {
        appIdentifier = dictionary?["appid"] ?? ""
        partnerIdentifier = dictionary?["partnerid"] ?? ""
        prepayIdentifier = dictionary?["prepayid"] ?? ""
        timestamp = UInt32(dictionary?["timestamp"] ?? "") ?? 0
        package = dictionary?["package"] ?? ""
        nonce = dictionary?["noncestr"] ?? ""
        signature = dictionary?["sign"] ?? ""
    }
}
