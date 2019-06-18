//
// Copyright (c) 2019 Adyen B.V.
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
    
    /// The name of the payment method, adapted for displaying in a list.
    /// In the case of stored payment methods, this will include information identifying the stored payment method.
    /// For example, this could be the last 4 digits of the card number, or the used email address.
    var displayName: String { get }
    
    /// The name of the logo resource.
    /// :nodoc:
    var logoName: String { get }
    
}

/// :nodoc:
public extension PaymentMethod {
    
    /// :nodoc:
    var displayName: String {
        return name
    }
    
    /// :nodoc:
    var logoName: String {
        return type
    }
    
}

/// A payment method that has been stored for later use.
public protocol StoredPaymentMethod: PaymentMethod {
    
    /// A unique identifier of the stored payment method.
    var identifier: String { get }
    
    /// The supported types of shopper interaction.
    var supportedShopperInteractions: [ShopperInteraction] { get }
    
}
