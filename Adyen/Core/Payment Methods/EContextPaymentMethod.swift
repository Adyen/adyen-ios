//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An E-context (ATM, Store, Online) or 7eleven payment method.
public struct EContextPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}

/// A 7eleven payment method.
public typealias SevenElevenPaymentMethod = EContextPaymentMethod
