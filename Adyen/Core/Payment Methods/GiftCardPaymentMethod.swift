//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Gift Card payment method.
public struct GiftCardPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    /// The brand of the gift card.
    public let brand: String

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: brand)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brand
    }

}
