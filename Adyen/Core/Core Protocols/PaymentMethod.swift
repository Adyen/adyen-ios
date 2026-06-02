//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method that is available to use.
public protocol PaymentMethod: Codable {
    
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
}

// TODO: Robert: This is a temporary protocol that will eventually be removed. Each Component should have its own factory see: `CardComponentFactory` for this every component should be migrated.
/// A payment method that can build a `PaymentComponent` using a `PaymentComponentBuilder`.
package protocol PaymentComponentBuildable {
    func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent?
}

/// A protocol to define any partial payment method such as gift cards, `MealVoucher` etc.
public protocol PartialPaymentMethod: PaymentMethod {}

// MARK: - Display Information

/// Internal protocol for payment methods that provide custom display information.
package protocol PaymentMethodDisplayOverridable {
    func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation
}

package extension PaymentMethod {
    
    /// Returns the display information for this payment method.
    /// If the payment method conforms to `PaymentMethodDisplayOverridable`, its custom implementation is used.
    /// Otherwise, returns the default display information based on name and type.
    func displayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        if let displayable = self as? PaymentMethodDisplayOverridable {
            return displayable.overriddenDisplayInformation(using: parameters)
        }
        return DisplayInformation(title: name, subtitle: nil, logoName: type.rawValue)
    }
}

// MARK: - Stored Payment Method

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
