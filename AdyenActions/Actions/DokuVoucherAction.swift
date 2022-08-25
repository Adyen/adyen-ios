//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes an action in which a Doku voucher is presented to the shopper.
public final class DokuVoucherAction: GenericVoucherAction, InstructionAwareVoucherAction {
    
    /// Shopper Name.
    public let shopperName: String

    /// The shopper email.
    public let shopperEmail: String
    
    /// The instruction `URL` object.
    public let instructionsURL: URL

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopperName = try container.decode(String.self, forKey: .shopperName)
        shopperEmail = try container.decode(String.self, forKey: .shopperEmail)
        instructionsURL = try container.decode(URL.self, forKey: .instructionsUrl)
        try super.init(from: decoder)
    }

    /// :nodoc:
    internal init(paymentMethodType: VoucherPaymentMethod,
                  initialAmount: Amount,
                  totalAmount: Amount,
                  reference: String,
                  shopperEmail: String,
                  expiresAt: Date,
                  merchantName: String,
                  shopperName: String,
                  instructionsUrl: URL) {
        self.shopperEmail = shopperEmail
        self.shopperName = shopperName
        self.instructionsURL = instructionsUrl
        super.init(paymentMethodType: paymentMethodType,
                   initialAmount: initialAmount,
                   totalAmount: totalAmount,
                   reference: reference,
                   expiresAt: expiresAt,
                   merchantName: merchantName)
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case shopperEmail,
             shopperName,
             instructionsUrl

    }
}
