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

/// Describes a payment method display information.
public struct DisplayInformation {
    
    /// The title for the payment method, adapted for displaying in a list.
    /// In the case of stored payment methods, this will include information identifying the stored payment method.
    /// For example, this could be the last 4 digits of the card number, or the used email address.
    public let title: String
    
    /// The subtitle for the payment method, adapted for displaying in a list.
    /// This property represents optional data that can help identify a payment method.
    /// For example, this could be the expiration date of a stored credit card.
    public let subtitle: String?
    
    /// The name of the logo resource.
    /// :nodoc:
    public let logoName: String

    /// The trailing disclosure text.
    /// :nodoc:
    public let disclosureText: String?

    /// Initializes a`DisplayInformation`.
    ///
    /// - Parameter title: The title.
    /// - Parameter subtitle: The subtitle.
    /// - Parameter logoName: The logo name.
    /// - Parameter disclosureText: The trailing disclosure text.
    public init(title: String, subtitle: String?, logoName: String, disclosureText: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.logoName = logoName
        self.disclosureText = disclosureText
    }
}

/// :nodoc:
extension DisplayInformation: Equatable {}

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
