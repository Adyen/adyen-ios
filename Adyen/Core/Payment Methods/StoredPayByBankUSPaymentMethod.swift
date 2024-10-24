//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Stored PayByBank US payment.
public struct StoredPayByBankUSPaymentMethod: StoredPaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
    public let label: String?
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let title: String
        let subtitle: String?
        
        if let label {
            title = label
            subtitle = name
        } else {
            title = name
            subtitle = nil
        }
        
        return DisplayInformation(title: title, subtitle: subtitle, logoName: type.rawValue)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case label
        case identifier = "id"
        case supportedShopperInteractions
    }

}
