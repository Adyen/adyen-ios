//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package struct AdyenLabelStyles {
    package var title: AdyenLabelStyle
    package var subtitle: AdyenLabelStyle
    package var body: AdyenLabelStyle
    package var bodyEmphasized: AdyenLabelStyle
    package var subheadline: AdyenLabelStyle
    package var subheadlineEmphasized: AdyenLabelStyle
    package var footnote: AdyenLabelStyle
    package var footnoteEmphasized: AdyenLabelStyle

    /// A default instance of AdyenLabelStyles.
    internal static let `default` = AdyenElements.default.labels

    /// Initializes the label styles with all parameters required.
    ///
    /// - Parameters:
    ///   - title: The title label style (34pt bold).
    ///   - subtitle: The subtitle label style (20pt semibold).
    ///   - body: The body label style (17pt regular).
    ///   - bodyEmphasized: The emphasized body label style (17pt semibold).
    ///   - subheadline: The subheadline label style (15pt regular).
    ///   - subheadlineEmphasized: The emphasized subheadline label style (15pt semibold).
    ///   - footnote: The footnote label style (13pt regular).
    ///   - footnoteEmphasized: The emphasized footnote label style (13pt semibold).
    internal init(
        title: AdyenLabelStyle,
        subtitle: AdyenLabelStyle,
        body: AdyenLabelStyle,
        bodyEmphasized: AdyenLabelStyle,
        subheadline: AdyenLabelStyle,
        subheadlineEmphasized: AdyenLabelStyle,
        footnote: AdyenLabelStyle,
        footnoteEmphasized: AdyenLabelStyle
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
