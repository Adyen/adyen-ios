//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A stored Cash App Pay account.
public struct StoredCashAppPayPaymentMethod: StoredPaymentMethod {
    
    public let type: PaymentMethodType

    public let name: String
    
    /// Public identifier for the customer on Cash App.
    public let cashtag: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: cashtag,
                           subtitle: name,
                           logoName: type.rawValue,
                           accessibilityLabel: "\(name), Cashtag: \(cashtag)")
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case cashtag
        case identifier = "id"
        case supportedShopperInteractions

    }
}
