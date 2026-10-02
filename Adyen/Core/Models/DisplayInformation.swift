//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a payment method display information.
package struct DisplayInformation: Equatable {

    package enum SubtitleStatus: Equatable {
        case normal
        case warning
    }

    package enum TrailingInfoType: Equatable {
        case text(String)
        case logos(named: [String], trailingText: String?)
        
        internal var accessibilityLabel: String? {
            switch self {
            case let .text(text): return text
            case .logos: return nil
            }
        }
    }
    
    /// The title for the payment method, adapted for displaying in a list.
    /// In the case of stored payment methods, this will include information identifying the stored payment method.
    /// For example, this could be the last 4 digits of the card number, or the used email address.
    package let title: String

    /// The subtitle for the payment method, adapted for displaying in a list.
    /// This property represents optional data that can help identify a payment method.
    package let subtitle: String?

    /// The semantic status of the subtitle.
    package let subtitleStatus: SubtitleStatus

    /// The name of the logo resource.
    package let logoName: String

    /// The trailing info element
    package let trailingInfo: TrailingInfoType?

    /// The footnote if any.
    package let footnoteText: String?

    /// An optional custom `accessibilityLabel` to use.
    package let accessibilityLabel: String?

    /// Initializes a `DisplayInformation`
    ///
    /// - Parameter title: The title.
    /// - Parameter subtitle: The subtitle.
    /// - Parameter subtitleStatus: The semantic status of the subtitle.
    /// - Parameter logoName: The logo name.
    /// - Parameter disclosureText: The trailing disclosure text.
    /// - Parameter footnoteText: The footnote text if any.
    /// - Parameter accessibilityLabel: An optional custom `accessibilityLabel` to use.
    /// Set this if the title / subtitle might not be sufficient enough to provide a good accessibility
    package init(
        title: String,
        subtitle: String?,
        subtitleStatus: SubtitleStatus = .normal,
        logoName: String,
        disclosureText: String? = nil,
        footnoteText: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            subtitleStatus: subtitleStatus,
            logoName: logoName,
            trailingInfo: disclosureText.map { .text($0) },
            footnoteText: footnoteText,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    package init(
        title: String,
        subtitle: String?,
        subtitleStatus: SubtitleStatus = .normal,
        logoName: String,
        trailingInfo: TrailingInfoType?,
        footnoteText: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleStatus = subtitleStatus
        self.logoName = logoName
        self.trailingInfo = trailingInfo
        self.footnoteText = footnoteText
        self.accessibilityLabel = accessibilityLabel
    }
}
