//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Cash App Pay payment method
public struct CashAppPayPaymentMethod: PaymentMethod {
   
    public let type: PaymentMethodType
    
    public let name: String
    
    public let merchantId: String
    
    public let scopeId: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case merchantId
        case scopeId
    }
}
