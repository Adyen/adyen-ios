//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// PayTo  payment method.
public struct PayToPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String

    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }

}

/// A stored PayTo payment method.
public struct StoredPayToPaymentMethod: StoredPaymentMethod {
   
    public let type: PaymentMethodType
    
    public let name: String
    
    public let identifier: String
    
    public let label: String
    
    public let supportedShopperInteractions: [ShopperInteraction]
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let accessibilityLabel = [
            name,
            label
        ].joined(separator: ", ")
        
        return DisplayInformation(
            title: label,
            subtitle: name,
            logoName: type.rawValue,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case label
        case supportedShopperInteractions
    }
}
