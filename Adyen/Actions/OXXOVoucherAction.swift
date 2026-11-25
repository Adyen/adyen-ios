//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which an OXXO voucher is presented to the shopper.
package class OXXOVoucherAction: GenericVoucherAction,
    Downloadable,
    InstructionAwareVoucherAction {

    /// This reference is a short version of the barcode number of the voucher.
    package let alternativeReference: String
    
    /// The reference to uniquely identify a payment.
    /// This reference is used in all communication with you about the payment status.
    package let merchantReference: String
    
    /// Download URL.
    package let downloadUrl: URL
    
    /// The instruction `URL` object.
    package let instructionsURL: URL

    package required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alternativeReference = try container.decode(String.self, forKey: .alternativeReference)
        merchantReference = try container.decode(String.self, forKey: .merchantReference)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        instructionsURL = try container.decode(URL.self, forKey: .instructionsUrl)
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case alternativeReference,
             merchantReference,
             downloadUrl,
             instructionsUrl
    }
}
