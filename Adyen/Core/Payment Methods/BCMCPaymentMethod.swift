//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Bancontact card payment method.
public struct BCMCPaymentMethod: AnyCardPaymentMethod {

    private var cardPaymentMethod: CardPaymentMethod

    public var type: PaymentMethodType { cardPaymentMethod.type }

    public var name: String { cardPaymentMethod.name }
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? {
        get { cardPaymentMethod.merchantProvidedDisplayInformation }
        set { cardPaymentMethod.merchantProvidedDisplayInformation = newValue }
    }
    
    /// An array containing the supported brands, such as `"mc"`, `"visa"`, `"amex"`, `"bcmc"`.
    /// In this case the brands is ["bcmc"].
    public let brands: [CardType] = [CardType.bcmc]
    
    public var fundingSource: CardFundingSource? { cardPaymentMethod.fundingSource }
    
    internal init(cardPaymentMethod: CardPaymentMethod) {
        self.cardPaymentMethod = cardPaymentMethod
    }
    
    public init(from decoder: Decoder) throws {
        let cardPaymentMethod = try CardPaymentMethod(from: decoder)
        self.init(cardPaymentMethod: cardPaymentMethod)
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
}
