//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A stored Cash App Pay account.
public struct StoredCashAppPayPaymentMethod: StoredPaymentMethod, PaymentMethodDisplayCustomizable {
    
    public let type: PaymentMethodType

    public let name: String
    
    /// Public identifier for the customer on Cash App.
    public let cashtag: String
    
    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    package func customizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let accessibilityLabel = [
            name,
            "\(localizedString(.cashAppPayCashtag, parameters)): \(cashtag)"
        ].joined(separator: ", ")
        
        return DisplayInformation(
            title: cashtag,
            subtitle: name,
            logoName: type.rawValue,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case cashtag
        case identifier = "id"
        case supportedShopperInteractions

    }
}
