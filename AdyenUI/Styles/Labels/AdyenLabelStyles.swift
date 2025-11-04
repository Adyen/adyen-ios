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
    
    public init() {
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
}

public extension AdyenLabelStyles {
    func title(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: style,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func subtitle(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: style,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func body(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: style,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func bodyEmphasized(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: style,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func subheadline(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: style,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func subheadlineEmphasized(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: style,
            footnote: self.footnote,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func footnote(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: style,
            footnoteEmphasized: self.footnoteEmphasized
        )
    }
    
    func footnoteEmphasized(_ style: AdyenLabelStyle) -> Self {
        AdyenLabelStyles(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body,
            bodyEmphasized: self.bodyEmphasized,
            subheadline: self.subheadline,
            subheadlineEmphasized: self.subheadlineEmphasized,
            footnote: self.footnote,
            footnoteEmphasized: style
        )
    }
}
