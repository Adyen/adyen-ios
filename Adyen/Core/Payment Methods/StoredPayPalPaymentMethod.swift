//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored PayPal account.
public struct StoredPayPalPaymentMethod: StoredPaymentMethod, PaymentMethodDisplayOverridable {
    
    public let type: PaymentMethodType

    public let name: String
    
    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: emailAddress, logoName: type.rawValue)
    }
    
    /// The email address of the PayPal account.
    public let emailAddress: String

    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case identifier = "id"
        case name
        case emailAddress = "shopperEmail"
        case supportedShopperInteractions
    }
    
}

// MARK: - PaymentComponentBuildable

extension StoredPayPalPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
