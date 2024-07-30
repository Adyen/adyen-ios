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

    // TODO: - Document this property
    public let isStored: Bool

    private enum CodingKeys: String, CodingKey {
        case token
        case isStored
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        isStored = try container.decodeIfPresent(Bool.self, forKey: .isStored) ?? false
    }

    internal init(token: String, isStored: Bool) {
        self.token = token
        self.isStored = isStored
    }
}
