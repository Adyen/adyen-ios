//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A BLIK payment method.
public struct BLIKPaymentMethod: PaymentMethod, PaymentMethodDisplayCustomizable {
    
    public let type: PaymentMethodType

    public let name: String
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    package func customizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name.uppercased(), subtitle: nil, logoName: type.rawValue)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
