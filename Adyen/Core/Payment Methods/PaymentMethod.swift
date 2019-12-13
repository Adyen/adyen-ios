//
// Copyright (c) 2019 Adyen N.V.
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
    ///   - tableName: Indicates the localizable strings table name, pass nil to use the default table name.
    func localizedDisplayInformation(usingTableName tableName: String?) -> DisplayInformation
}

public struct DisplayInformation {
    
    /// The title for the payment method, adapted for displaying in a list.
    /// In the case of stored payment methods, this will include information identifying the stored payment method.
    /// For example, this could be the last 4 digits of the card number, or the used email address.
    public var title: String
    
    /// The subtitle for the payment method, adapted for displaying in a list.
    /// This property represents optional data that can help identify a payment method.
    /// For example, this could be the expiration date of a stored credit card.
    public var subtitle: String?
    
    /// The name of the logo resource.
    /// :nodoc:
    public var logoName: String
}

extension DisplayInformation: Equatable {}

/// :nodoc:
public extension PaymentMethod {
    
    /// :nodoc:
    var displayInformation: DisplayInformation {
        return DisplayInformation(title: name, subtitle: nil, logoName: type)
    }
    
    /// :nodoc:
    func localizedDisplayInformation(usingTableName tableName: String?) -> DisplayInformation {
        return DisplayInformation(title: name, subtitle: nil, logoName: type)
    }
    
}

/// A payment method that has been stored for later use.
public protocol StoredPaymentMethod: PaymentMethod {
    
    /// A unique identifier of the stored payment method.
    var identifier: String { get }
    
    /// The supported types of shopper interaction.
    var supportedShopperInteractions: [ShopperInteraction] { get }
    
}
