//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package struct AdyenElements {
    package var buttons: AdyenButtonStyles
    package var labels: AdyenLabelStyles
    package var `switch`: AdyenSwitchStyle
    package var textField: AdyenTextFieldStyle

    /// Initializes all UI elements from the provided color scheme.
    /// This is the SINGLE SOURCE OF TRUTH for all default styling values.
    ///
    /// - Parameter colors: The color scheme to use.
    internal init(colors: CheckoutColors) {
        // ALL default styling configuration is defined HERE in one place

        // Define labels first so we can reuse them
        let labels = AdyenLabelStyles(
            title: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.title.rawValue, weight: .bold),
                color: colors.text,
                lineHeight: 41
            ),
            title2: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 22, weight: .bold),
                color: colors.text,
                lineHeight: 28
            ),
            subtitle: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.subtitle.rawValue, weight: .semibold),
                color: colors.text,
                lineHeight: 25
            ),
            body: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.body.rawValue, weight: .regular),
                color: colors.text,
                lineHeight: 22
            ),
            bodyEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.body.rawValue, weight: .semibold),
                color: colors.text,
                lineHeight: 22
            ),
            subheadline: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.subheadline.rawValue, weight: .regular),
                color: colors.text,
                lineHeight: 20
            ),
            subheadlineEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.subheadline.rawValue, weight: .semibold),
                color: colors.text,
                lineHeight: 20
            ),
            footnote: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.footnote.rawValue, weight: .regular),
                color: colors.text,
                lineHeight: 18
            ),
            footnoteEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.footnote.rawValue, weight: .semibold),
                color: colors.text,
                lineHeight: 18
            ),
            label: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: FontSize.body.rawValue, weight: .semibold),
                color: colors.text,
                lineHeight: 22
            )
        )

        self.buttons = AdyenButtonStyles(
            primary: .primary(for: colors),
            secondary: .secondary(for: colors),
            tertiary: .tertiary(for: colors),
            destructive: .destructive(for: colors)
        )
        self.labels = labels
        self.switch = AdyenSwitchStyle(
            title: labels.body,
            tintColor: colors.primary,
            backgroundColor: colors.container,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
        self.textField = AdyenTextFieldStyle(
            title: labels.label,
            text: labels.body,
            placeholder: labels.body.color(colors.textSecondary),
            defaultBorderWidth: 1,
            errorBorderWidth: 1.5,
            focusedBorderWidth: 2,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius),
            backgroundColor: colors.background,
            errorColor: colors.destructive,
            borderColor: colors.containerOutline,
            borderActiveColor: colors.primary
        )
    }

    internal static let `default` = AdyenElements(colors: .default)
}
