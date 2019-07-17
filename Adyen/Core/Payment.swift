//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the current payment.
public struct Payment {
    
    /// Describes the amount of a payment.
    public struct Amount {
        
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
    }
    
    /// The amount for this payment.
    public var amount: Amount
    
    /// The code of the country in which the payment is made.
    public var countryCode: String?
    
    /// Initializes a payment.
    ///
    /// - Parameters:
    ///   - amount: The amount for this payment.
    public init(amount: Amount) {
        self.amount = amount
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
