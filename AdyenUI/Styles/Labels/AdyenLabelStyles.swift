//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct AdyenLabelStyles {
    public var title: AdyenLabelStyle
    public var subtitle: AdyenLabelStyle
    public var body: AdyenLabelStyle
    public var bodyEmphasized: AdyenLabelStyle
    public var subheadline: AdyenLabelStyle
    public var subheadlineEmphasized: AdyenLabelStyle
    public var footnote: AdyenLabelStyle
    public var footnoteEmphasized: AdyenLabelStyle
    
    /// A default instance of AdyenLabelStyles.
    public static let `default` = AdyenLabelStyles()
    
    public init(
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
    
    package init() {
        let defaultColors = AdyenColors.default
        
        self.title = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 34.0, weight: .bold),
            color: defaultColors.primary
        )
        self.subtitle = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
            color: defaultColors.primary
        )
        self.body = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
            color: defaultColors.primary
        )
        self.bodyEmphasized = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
            color: defaultColors.primary
        )
        self.subheadline = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
            color: defaultColors.text
        )
        self.subheadlineEmphasized = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 15.0, weight: .semibold),
            color: defaultColors.text
        )
        self.footnote = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
            color: defaultColors.textSecondary
        )
        self.footnoteEmphasized = AdyenLabelStyle(
            font: UIFont.systemFont(ofSize: 13.0, weight: .semibold),
            color: defaultColors.text
        )
    }
}
