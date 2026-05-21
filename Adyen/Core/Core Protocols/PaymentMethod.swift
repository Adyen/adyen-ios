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
    
    @_spi(AdyenInternal)
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent?
}

public extension PaymentMethod {
    
    /// This default implementation has to be provided to be able to build with `BUILD_LIBRARY_FOR_DISTRIBUTION` enabled
    ///
    /// - Warning: Access will cause an failure in debug mode to assure the correct implementation of the `PaymentMethod` protocol
    @_spi(AdyenInternal)
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        AdyenAssertion.assertionFailure(
            message: "`@_spi(AdyenInternal) \(#function)` needs to be implemented on `\(String(describing: Self.self))`"
        )
        
        return nil
    }
}

/// A protocol to define any partial payment method such as gift cards, `MealVoucher` etc.
public protocol PartialPaymentMethod: PaymentMethod {}

// MARK: - Display Information

/// Internal protocol for payment methods that provide custom display information.
package protocol PaymentMethodDisplayable {
    
    /// Display information for the payment method, adapted for displaying in a list.
    ///
    /// - Parameters:
    ///   - parameters: The localization parameters.
    func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation
}

package extension PaymentMethod {
    
    /// Returns the display information for this payment method.
    /// If the payment method conforms to `PaymentMethodDisplayable`, its custom implementation is used.
    /// Otherwise, returns the default display information based on name and type.
    func displayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        if let displayable = self as? PaymentMethodDisplayable {
            return displayable.defaultDisplayInformation(using: parameters)
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
