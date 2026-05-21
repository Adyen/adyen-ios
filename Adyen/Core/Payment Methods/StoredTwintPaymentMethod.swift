//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored TwintPaymentMethod.
public struct StoredTwintPaymentMethod: StoredPaymentMethod, PaymentMethodDisplayable {

    public let type: PaymentMethodType

    public let name: String

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    package func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(
            title: name,
            subtitle: nil,
            logoName: type.rawValue
        )
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case supportedShopperInteractions

    }
}
