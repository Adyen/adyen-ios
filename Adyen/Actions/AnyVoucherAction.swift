//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes any voucher action object.
package protocol AnyVoucherAction {
    
    /// The `paymentMethodType` for which the voucher is presented.
    var paymentMethodType: PaymentMethodType { get }

    /// The Apple wallet pass token.
    var passCreationToken: String? { get }
    
    /// The totalAmount amount.
    var totalAmount: Amount { get }
    
    /// The payment reference.
    var reference: String { get }
    
    /// The expiration date.
    var expiresAt: Date { get }

}
