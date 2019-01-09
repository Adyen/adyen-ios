//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A structure containing the available payment methods.
public struct SectionedPaymentMethods: Decodable {
    /// The preferred payment methods, such as stored credit cards.
    public var preferred: [PaymentMethod]
    
    /// The other types of payment methods.
    public var other: [PaymentMethod]
    
    /// The total number of available payment methods.
    public var count: Int {
        return preferred.count + other.count
    }
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.preferred = try container.decodeIfPresent([PaymentMethod].self, forKey: .preferred) ?? []
        self.other = try container.decodeIfPresent([PaymentMethod].self, forKey: .other)?.grouped ?? []
    }
    
    private enum CodingKeys: String, CodingKey {
        case preferred = "oneClickPaymentMethods"
        case other = "paymentMethods"
    }
    
}
