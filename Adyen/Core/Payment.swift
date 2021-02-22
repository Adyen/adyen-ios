//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the current payment.
public struct Payment {
    
    /// Describes the amount of a payment.
    public struct Amount: Codable {
        
        /// The value of the amount in minor units.
        public var value: Int
        
        /// The code of the currency in which the amount's value is specified.
        public var currencyCode: String
        
        /// Initializes an Amount.
        ///
        /// - Parameters:
        ///   - value: The value in minor units.
        ///   - currencyCode: The code of the currency.
        public init(value: Int, currencyCode: String) {
            self.value = value
            self.currencyCode = currencyCode
        }
        
        /// Initializes an Amount from a `Decimal` value expressed in major units.
        ///
        /// - Parameters:
        ///   - value: The value in major units.
        ///   - currencyCode: The code of the currency.
        public init(value: Decimal, currencyCode: String) {
            self.value = AmountFormatter.minorUnitAmount(from: value, currencyCode: currencyCode)
            self.currencyCode = currencyCode
        }

        private enum CodingKeys: String, CodingKey {
            case currencyCode = "currency"
            case value
        }
    }
    
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

/// :nodoc:
public extension Payment.Amount {
    
    /// Returns a formatter representation of the amount.
    ///
    /// :nodoc:
    var formatted: String {
        guard let formattedAmount = AmountFormatter.formatted(amount: value, currencyCode: currencyCode) else {
            return String(value) + " " + currencyCode
        }
        
        return formattedAmount
    }
    
}
