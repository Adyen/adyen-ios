//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored PayPal account.
public struct StoredPayPalPaymentMethod: StoredPaymentMethod {
    
    /// :nodoc:
    public let type: PaymentMethodType
    
    /// :nodoc:
    public let name: String

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    public var displayInformation: DisplayInformation {
        DisplayInformation(title: name, subtitle: emailAddress, logoName: type.rawValue)
    }

    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: emailAddress, logoName: type.rawValue)
    }
    
    /// The email address of the PayPal account.
    public let emailAddress: String
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case identifier = "id"
        case name
        case emailAddress = "shopperEmail"
        case supportedShopperInteractions
    }
    
}
