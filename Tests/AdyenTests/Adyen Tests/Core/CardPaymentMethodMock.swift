//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

struct CardPaymentMethodMock: AnyCardPaymentMethod {
    var fundingSource: CardFundingSource?
    
    var type: PaymentMethodType
    
    var name: String
    
    var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    var brands: [CardType]
    
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brands
    }
    
}
