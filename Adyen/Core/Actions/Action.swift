//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a follow-up action that should be taken to complete a payment.
public enum Action: Decodable {
    
    /// Indicates the user should be redirected to a URL.
    case redirect(RedirectAction)
    
    /// Indicates a 3D Secure device fingerprint should be taken.
    case threeDS2Fingerprint(ThreeDS2FingerprintAction)
    
    /// Indicates a 3D Secure challenge should be presented.
    case threeDS2Challenge(ThreeDS2ChallengeAction)
    
    // MARK: - Coding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        
        switch type {
        case .redirect:
            self = .redirect(try RedirectAction(from: decoder))
        case .threeDS2Fingerprint:
            self = .threeDS2Fingerprint(try ThreeDS2FingerprintAction(from: decoder))
        case .threeDS2Challenge:
            self = .threeDS2Challenge(try ThreeDS2ChallengeAction(from: decoder))
        }
    }
    
    private enum ActionType: String, Decodable {
        case redirect
        case threeDS2Fingerprint
        case threeDS2Challenge
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
}
