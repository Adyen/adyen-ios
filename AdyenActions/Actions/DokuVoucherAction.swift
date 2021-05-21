//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes an action in which a Doku voucher is presented to the shopper.
public final class DokuVoucherAction: GenericVoucherAction {
    
    /// Shopper Name.
    public let shopperName: String

    /// The shopper email.
    public let shopperEmail: String

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopperName = try container.decode(String.self, forKey: .shopperName)
        shopperEmail = try container.decode(String.self, forKey: .shopperEmail)
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
                  instructionsUrl: String) {
        self.shopperEmail = shopperEmail
        self.shopperName = shopperName
        super.init(paymentMethodType: paymentMethodType,
                   initialAmount: initialAmount,
                   totalAmount: totalAmount,
                   reference: reference,
                   expiresAt: expiresAt,
                   merchantName: merchantName,
                   instructionsUrl: instructionsUrl)
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case shopperEmail,
             shopperName

    }
}
