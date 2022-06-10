//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

struct StoredPaymentMethodMock: StoredPaymentMethod {
    
    var identifier: String
    
    var supportedShopperInteractions: [ShopperInteraction]
    
    var type: PaymentMethodType
    
    var name: String
    
    var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case identifier = "id"
        case name
        case supportedShopperInteractions
    }
    
}
