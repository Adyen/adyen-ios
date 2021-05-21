//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the current payment.
public struct Payment {
    
    /// The amount for this payment.
    public var amount: Amount
    
    /// The code of the country in which the payment is made.
    public var countryCode: String?
    
    /// Initializes a payment.
    ///
    /// - Parameters:
    ///   - amount: The amount for this payment.
    ///   - countryCode: The code of the country in which the payment is made.
    public init(amount: Amount, countryCode: String? = nil) {
        self.amount = amount
        self.countryCode = countryCode
    }

}
