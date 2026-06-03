//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored TwintPaymentMethod.
public struct StoredTwintPaymentMethod: StoredPaymentMethod, PaymentMethodDisplayOverridable {

    public let type: PaymentMethodType

    public let name: String

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
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

// MARK: - PaymentComponentBuildable

extension StoredTwintPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
