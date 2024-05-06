//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the data required by the Twint SDK to complete the payment.
public struct TwintSDKData: Decodable {

    /// SDK token.
    public let token: String

    private enum CodingKeys: String, CodingKey {
        case token
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
    }

    internal init(token: String) {
        self.token = token
    }
}
