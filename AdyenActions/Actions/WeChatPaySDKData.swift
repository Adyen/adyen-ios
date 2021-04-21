//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the data required by the WeChat SDK to complete the payment.
public struct WeChatPaySDKData: Decodable {
    
    /// SDK app identifier.
    public let appIdentifier: String
    
    /// Partner identifier.
    public let partnerIdentifier: String
    
    /// Prepay identifier.
    public let prepayIdentifier: String
    
    /// timestamp.
    public let timestamp: String
    
    /// The package value.
    public let package: String
    
    /// Number used once.
    public let nonce: String
    
    /// The signature.
    public let signature: String
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appIdentifier = try container.decode(String.self, forKey: .appIdentifier)
        partnerIdentifier = try container.decode(String.self, forKey: .partnerIdentifier)
        prepayIdentifier = try container.decode(String.self, forKey: .prepayIdentifier)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        package = try container.decode(String.self, forKey: .package)
        nonce = try container.decode(String.self, forKey: .nonce)
        signature = try container.decode(String.self, forKey: .signature)
    }
    
    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case appIdentifier = "appid"
        case partnerIdentifier = "partnerid"
        case prepayIdentifier = "prepayid"
        case timestamp
        case package = "packageValue"
        case nonce = "noncestr"
        case signature = "sign"
    }
    
}
