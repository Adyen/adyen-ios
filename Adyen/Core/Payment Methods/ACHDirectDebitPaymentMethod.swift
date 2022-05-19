//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An ACH Direct Debit payment method.
public struct ACHDirectDebitPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name.uppercased(), subtitle: nil, logoName: type.rawValue)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
}
