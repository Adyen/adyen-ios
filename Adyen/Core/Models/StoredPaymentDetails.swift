//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Conforming instances provide access to payment details from previously used payment methods.
public protocol StoredPaymentDetails: Decodable {}

/// Contains payment details from a previously used card.
public struct StoredCardPaymentDetails: StoredPaymentDetails {
    /// A shortened version of the card's number.
    public let number: String
    
    /// The card's holder name.
    public let holderName: String
    
    /// The card's expiry month.
    public let expiryMonth: Int
    
    /// The card's expiry year.
    public let expiryYear: Int
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.number = try container.decode(String.self, forKey: .number)
        self.holderName = try container.decode(String.self, forKey: .holderName)
        self.expiryMonth = try container.decodeIntString(forKey: .expiryMonth)
        self.expiryYear = try container.decodeIntString(forKey: .expiryYear)
    }
    
    private enum CodingKeys: String, CodingKey {
        case number
        case holderName
        case expiryMonth
        case expiryYear
    }
    
}

/// Contains payment details from a previously used PayPal account.
public struct StoredPayPalPaymentDetails: StoredPaymentDetails {
    /// The email address of the PayPal account.
    public let emailAddress: String
    
}
