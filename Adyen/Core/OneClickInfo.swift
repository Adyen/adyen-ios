//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances conforming to this protocol provide access to the information that was stored for a payment method.
public protocol OneClickInfo {
    
}

/// Contains information on the card that was stored for a payment method.
public struct CardOneClickInfo: OneClickInfo {
    
    /// A shortened version of the card's number.
    public let number: String
    
    /// The card's holder name.
    public let holderName: String
    
    /// The card's expiry month.
    public let expiryMonth: Int
    
    /// The card's expiry year.
    public let expiryYear: Int
    
    internal init?(dictionary: [String: Any]) {
        guard
            let number = dictionary["number"] as? String,
            let holderName = dictionary["holderName"] as? String,
            let expiryMonthString = dictionary["expiryMonth"] as? String,
            let expiryYearString = dictionary["expiryYear"] as? String,
            let expiryMonth = Int(expiryMonthString),
            let expiryYear = Int(expiryYearString)
        else {
            return nil
        }
        
        self.number = number
        self.holderName = holderName
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
    
}

/// Contains information on a PayPal account that was stored.
public struct PayPalOneClickInfo: OneClickInfo {
    
    /// The email address of the PayPal account.
    public let emailAddress: String
    
}
