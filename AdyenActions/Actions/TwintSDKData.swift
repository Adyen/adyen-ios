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

    // Determines if the Twint payment is tokenized.
    public let isStored: Bool

    private enum CodingKeys: String, CodingKey {
        case token
        case isStored
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)

        // `isStored` field comes a String instead of Bool due to technical limitations
        // on the API side. This is the reason it is necessary to parse it from String to
        // Bool.
        // This is the ticket where the field was added: https://youtrack.is.adyen.com/issue/FOC-77001
        let isStoredString = try container.decode(String.self, forKey: .isStored)
        isStored = Bool(isStoredString) ?? false
    }

    internal init(token: String, isStored: Bool) {
        self.token = token
        self.isStored = isStored
    }
}
