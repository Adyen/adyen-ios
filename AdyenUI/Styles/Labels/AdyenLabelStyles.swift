//
// Copyright (c) Adyen N.V.
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
    package static let `default` = AdyenElements.default.labels

    /// Initializes the label styles with all parameters required.
    ///
    /// Note: Default values are defined in `AdyenElements.init(colors:)`.
    ///
    /// - Parameters:
    ///   - title: The title label style.
    ///   - subtitle: The subtitle label style.
    ///   - body: The body label style.
    ///   - bodyEmphasized: The emphasized body label style.
    ///   - subheadline: The subheadline label style.
    ///   - subheadlineEmphasized: The emphasized subheadline label style.
    ///   - footnote: The footnote label style.
    ///   - footnoteEmphasized: The emphasized footnote label style.
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
