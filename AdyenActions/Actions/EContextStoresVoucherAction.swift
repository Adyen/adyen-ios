//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which an EContext Stores voucher is presented to the shopper.
public class EContextStoresVoucherAction: GenericVoucherAction,
    InstructionAwareVoucherAction {

    /// Masked shopper telephone number.
    public let maskedTelephoneNumber: String
    
    /// The instruction `URL` object.
    public let instructionsURL: URL

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maskedTelephoneNumber = try container.decode(String.self, forKey: .maskedTelephoneNumber)
        instructionsURL = try container.decode(URL.self, forKey: .instructionsUrl)
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case maskedTelephoneNumber,
             instructionsUrl
    }
}
