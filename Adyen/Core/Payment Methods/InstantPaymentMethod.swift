//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method that does not require any handling and could be submitted directly.
public struct InstantPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(
            title: name,
            subtitle: nil,
            logoName: type.rawValue,
            trailingInfo: .logos(named: Array(1...4).map { "US-\($0)" }, trailingText: "+")
        )
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
