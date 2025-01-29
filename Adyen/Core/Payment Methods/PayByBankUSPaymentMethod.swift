//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// PayByBank US payment method.
public struct PayByBankUSPaymentMethod: PaymentMethod {
    public let type: PaymentMethodType
    
    public var name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    @_spi(AdyenInternal)
    public static var logoNames: [String] {
        ["US-1", "US-2", "US-3", "US-4"]
    }
    
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        .init(
            title: name,
            subtitle: nil,
            logoName: type.rawValue,
            trailingInfo: .logos(
                named: Self.logoNames,
                trailingText: "+"
            ),
            accessibilityLabel: name
        )
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
