//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method that is available to use.
public protocol PaymentMethod: Decodable {
    
    /// A string identifying the type of payment method, such as `"card"`, `"ideal"`, `"applepay"`.
    var type: String { get }
    
    /// The name of the payment method, such as `"Credit Card"`, `"iDEAL"`, `"Apple Pay"`.
    var name: String { get }
    
    /// Display information for the payment method, adapted for displaying in a list.
    var displayInformation: DisplayInformation { get }
    
    /// Display information for the payment method, adapted for displaying in a list.
    ///
    /// - Parameters:
    ///   - using: The localization parameters.
    func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation
    
    /// :nodoc:
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent?
}

/// :nodoc:
public extension PaymentMethod {
    
    /// :nodoc:
    var displayInformation: DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type)
    }
    
    /// :nodoc:
    func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type)
    }
    
}

/// A payment method that has been stored for later use.
public protocol StoredPaymentMethod: PaymentMethod {
    
    /// A unique identifier of the stored payment method.
    var identifier: String { get }
    
    /// The supported types of shopper interaction.
    var supportedShopperInteractions: [ShopperInteraction] { get }
    
}

/// :nodoc:
public func == (lhs: StoredPaymentMethod, rhs: StoredPaymentMethod) -> Bool {
    lhs.type == rhs.type &&
        lhs.name == rhs.name &&
        lhs.identifier == rhs.identifier &&
        lhs.supportedShopperInteractions == rhs.supportedShopperInteractions &&
        String(describing: type(of: lhs)) == String(describing: type(of: rhs))
}

/// :nodoc:
public func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
    lhs.type == rhs.type &&
        lhs.name == rhs.name &&
        String(describing: type(of: lhs)) == String(describing: type(of: rhs))
}
