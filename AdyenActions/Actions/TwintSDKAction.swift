//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to the Twint SDK.
public final class TwintSDKAction: Decodable {

    /// The TwintSDK specific data.
    public let sdkData: TwintSDKData

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    // The payment method type
    public let paymentMethodType: String

    // The payment method subtype
    public let type: String
    
    internal enum CodingKeys: CodingKey {
        case sdkData
        case paymentData
        case paymentMethodType
        case type
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sdkData = try container.decode(TwintSDKData.self, forKey: .sdkData)
        self.paymentData = try container.decode(String.self, forKey: .paymentData)
        self.paymentMethodType = try container.decode(String.self, forKey: .paymentMethodType)
        self.type = try container.decode(String.self, forKey: .type)
    }
    
    internal init(
        sdkData: TwintSDKData,
        paymentData: String,
        paymentMethodType: String,
        type: String
    ) {
        self.sdkData = sdkData
        self.paymentData = paymentData
        self.paymentMethodType = paymentMethodType
        self.type = type
    }
}
