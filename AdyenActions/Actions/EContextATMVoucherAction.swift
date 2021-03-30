//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which an EContext ATM voucher is presented to the shopper.
public class EContextATMVoucherAction: EContextStoresVoucherAction {

    /// Collection institution number.
    public let collectionInstitutionNumber: String

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        collectionInstitutionNumber = try container.decode(String.self, forKey: .collectionInstitutionNumber)
        try super.init(from: decoder)
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case collectionInstitutionNumber
    }
}
