//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes an action in which a Multibanco voucher is presented to the shopper.
public final class MultibancoVoucherAction: GenericVoucherAction {
    
    /// Multibanco entity.
    public let entity: String
    
    /// The reference to uniquely identify a payment.
    /// This reference is used in all communication with you about the payment status.
    public let merchantReference: String
    
    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entity = try container.decode(String.self, forKey: .entity)
        merchantReference = try container.decode(String.self, forKey: .merchantReference)
        try super.init(from: decoder)
    }
    
    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case entity,
             merchantReference
    }
}
