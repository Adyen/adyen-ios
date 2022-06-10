//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method that is available to use.
public protocol PaymentMethod: Decodable {
    
    /// A string identifying the type of payment method, such as `"card"`, `"ideal"`, `"applepay"`.
    var type: PaymentMethodType { get }
    
    /// The name of the payment method, such as `"Credit Card"`, `"iDEAL"`, `"Apple Pay"`.
    var name: String { get }
    
    /// Describes a payment method display information thats provided by the merchant
    /// and if not `nil`, will override the default display information.
    var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? { get set }
    
    /// Display information for the payment method, adapted for displaying in a list.
    ///
    /// - Parameters:
    ///   - using: The localization parameters.
    @_spi(AdyenInternal)
    func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation
    
    @_spi(AdyenInternal)
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent?
}

@_spi(AdyenInternal)
public extension PaymentMethod {
    
    func displayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let defaultDisplayInformation = defaultDisplayInformation(using: parameters)
        if let merchantProvidedDisplayInformation = merchantProvidedDisplayInformation {
            let subtitle = merchantProvidedDisplayInformation.subtitle ?? defaultDisplayInformation.subtitle
            return DisplayInformation(title: merchantProvidedDisplayInformation.title,
                                      subtitle: subtitle,
                                      logoName: defaultDisplayInformation.logoName,
                                      disclosureText: defaultDisplayInformation.disclosureText,
                                      footnoteText: defaultDisplayInformation.footnoteText)
        }
        return defaultDisplayInformation
    }

    @_spi(AdyenInternal)
    func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type.rawValue)
    }
    
}

/// A payment method that has been stored for later use.
public protocol StoredPaymentMethod: PaymentMethod {
    
    /// A unique identifier of the stored payment method.
    var identifier: String { get }
    
    /// The supported types of shopper interaction.
    var supportedShopperInteractions: [ShopperInteraction] { get }
    
}

@_spi(AdyenInternal)
public func == (lhs: StoredPaymentMethod, rhs: StoredPaymentMethod) -> Bool {
    lhs.type == rhs.type &&
        lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier &&
        lhs.supportedShopperInteractions == rhs.supportedShopperInteractions &&
        String(describing: type(of: lhs)) == String(describing: type(of: rhs))
}

@_spi(AdyenInternal)
public func != (lhs: StoredPaymentMethod, rhs: StoredPaymentMethod) -> Bool {
    !(lhs == rhs)
}

@_spi(AdyenInternal)
public func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
    lhs.type == rhs.type &&
        lhs.name == rhs.name &&
        String(describing: type(of: lhs)) == String(describing: type(of: rhs))
}

@_spi(AdyenInternal)
public func != (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
    !(lhs == rhs)
}
