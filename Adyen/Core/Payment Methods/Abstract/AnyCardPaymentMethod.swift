//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any card payment method.
public protocol AnyCardPaymentMethod: PaymentMethod {
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`, `"bcmc"`.
    var brands: [String] { get }
    
    /// Indicates the Card funding source.
    var fundingSource: CardFundingSource? { get }
    
}

/// Indicates the Card funding source.
public enum CardFundingSource: String, Codable {
    
    /// Indicates that the card is a debit card.
    case debit
    
    /// Indicates that the card is a credit card.
    case credit
    
}
