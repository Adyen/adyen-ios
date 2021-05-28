//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the current payment.
public struct Payment {
    
    /// The amount for this payment.
    public let amount: Amount
    
    /// The code of the country in which the payment is made.
    public let countryCode: String
    
    /// Initializes a payment.
    ///
    /// - Parameters:
    ///   - amount: The amount for this payment.
    ///   - countryCode: The code of the country in which the payment is made.
    public init(amount: Amount, countryCode: String) {
        assert(CountryCodeValidator().isValid(countryCode), "Country code should be in ISO-3166-1 alpha-2 format. For example: US.")
        self.amount = amount
        self.countryCode = countryCode
    }

    /// :nodoc:
    internal init(amount: Amount, unsafeCountryCode: String) {
        self.amount = amount
        self.countryCode = unsafeCountryCode
    }

}
