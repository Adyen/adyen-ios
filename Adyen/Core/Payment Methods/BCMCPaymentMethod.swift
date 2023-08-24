//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Bancontact card payment method.
public struct BCMCPaymentMethod: AnyCardPaymentMethod {
    /// A string identifying the type of payment method, such as `"card"`, `"ideal"`, `"applepay"`.
    public var type: String { cardPaymentMethod.type }
    
    /// The name of the payment method, such as `"Credit Card"`, `"iDEAL"`, `"Apple Pay"`.
    public var name: String { cardPaymentMethod.name }
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`, `"bcmc"`.
    ///
    /// Used to configure the `allowedCardTypes` on the `BCMCComponent`'s configuration
    public var brands: [String] { cardPaymentMethod.brands }
    
    /// :nodoc:
    public var fundingSource: CardFundingSource? { cardPaymentMethod.fundingSource }
    
    /// :nodoc:
    private let cardPaymentMethod: CardPaymentMethod
    
    /// :nodoc:
    internal init(cardPaymentMethod: CardPaymentMethod) {
        self.cardPaymentMethod = cardPaymentMethod
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let cardPaymentMethod = try CardPaymentMethod(from: decoder)
        self.init(cardPaymentMethod: cardPaymentMethod)
    }
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
}
