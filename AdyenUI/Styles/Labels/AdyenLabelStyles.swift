//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct AdyenLabelStyles {
    package var title: AdyenLabelStyle
    package var subtitle: AdyenLabelStyle
    package var body: AdyenLabelStyle
    package var bodyEmphasized: AdyenLabelStyle
    package var subheadline: AdyenLabelStyle
    package var subheadlineEmphasized: AdyenLabelStyle
    package var footnote: AdyenLabelStyle
    package var footnoteEmphasized: AdyenLabelStyle

    /// A default instance of AdyenLabelStyles.
    public static let `default` = AdyenLabelStyles()
    
    /// Initializes the label styles.
    ///
    /// - Parameters:
    ///   - title: The title label style. Defaults to 34pt bold.
    ///   - subtitle: The subtitle label style. Defaults to 20pt semibold.
    ///   - body: The body label style. Defaults to 17pt regular.
    ///   - bodyEmphasized: The emphasized body label style. Defaults to 17pt semibold.
    ///   - subheadline: The subheadline label style. Defaults to 15pt regular.
    ///   - subheadlineEmphasized: The emphasized subheadline label style. Defaults to 15pt semibold.
    ///   - footnote: The footnote label style. Defaults to 13pt regular.
    ///   - footnoteEmphasized: The emphasized footnote label style. Defaults to 13pt semibold.
    public init(
        title: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 34.0, weight: .bold),
            color: AdyenColors.default.primary
        ),
        subtitle: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
            color: AdyenColors.default.primary
        ),
        body: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
            color: AdyenColors.default.primary
        ),
        bodyEmphasized: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
            color: AdyenColors.default.primary
        ),
        subheadline: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
            color: AdyenColors.default.text
        ),
        subheadlineEmphasized: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 15.0, weight: .semibold),
            color: AdyenColors.default.text
        ),
        footnote: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
            color: AdyenColors.default.textSecondary
        ),
        footnoteEmphasized: AdyenLabelStyle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 13.0, weight: .semibold),
            color: AdyenColors.default.text
        )
    ) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.bodyEmphasized = bodyEmphasized
        self.subheadline = subheadline
        self.subheadlineEmphasized = subheadlineEmphasized
        self.footnote = footnote
        self.footnoteEmphasized = footnoteEmphasized
    }
}
