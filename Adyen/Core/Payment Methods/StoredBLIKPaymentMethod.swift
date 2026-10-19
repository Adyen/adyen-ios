//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Stored Blik payment.
public struct StoredBLIKPaymentMethod: StoredPaymentMethod, PaymentMethodDisplayOverridable {

    public let type: PaymentMethodType

    public let name: String
    
    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]
    
    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name.uppercased(), subtitle: nil, logoName: type.rawValue)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case supportedShopperInteractions
    }

}

// MARK: - PaymentComponentBuildable

extension StoredBLIKPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
