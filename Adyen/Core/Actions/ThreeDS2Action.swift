//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a full 3D Secure 2 flow should be executed including fingerprint collection,
/// and potentially a challenge or a fallback to 3DS1.
public enum ThreeDS2Action: Decodable {

    /// Indicates a 3D Secure device fingerprint should be taken.
    case fingerprint(ThreeDS2FingerprintAction)

    /// Indicates a 3D Secure challenge should be presented.
    case challenge(ThreeDS2ChallengeAction)

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .challenge:
            self = .challenge(try ThreeDS2ChallengeAction(from: decoder))
        case .fingerprint:
            self = .fingerprint(try ThreeDS2FingerprintAction(from: decoder))
        }
    }

    /// The 3DS2 flow type.
    public enum ActionType: String, Decodable {
        case fingerprint
        case challenge
    }

    private enum CodingKeys: String, CodingKey {
        case type = "subtype"
        case token
        case paymentData
    }

}
