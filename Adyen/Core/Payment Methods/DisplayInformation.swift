//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a payment method display information.
public struct DisplayInformation: Equatable {

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

    /// The footnote if any.
    /// :nodoc:
    public let footnoteText: String?

    /// Initializes a`DisplayInformation`.
    ///
    /// - Parameter title: The title.
    /// - Parameter subtitle: The subtitle.
    /// - Parameter logoName: The logo name.
    /// - Parameter disclosureText: The trailing disclosure text.
    /// - Parameter footnoteText: The footnote text if any.
    public init(title: String,
                subtitle: String?,
                logoName: String,
                disclosureText: String? = nil,
                footnoteText: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.logoName = logoName
        self.disclosureText = disclosureText
        self.footnoteText = footnoteText
    }
}
