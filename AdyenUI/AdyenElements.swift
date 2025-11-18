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
    internal init(colors: AdyenColors) {
        // ALL default styling configuration is defined HERE in one place

        // Define labels first so we can reuse them
        let labels = AdyenLabelStyles(
            title: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 34.0, weight: .bold),
                color: colors.primary
            ),
            subtitle: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 20.0, weight: .semibold),
                color: colors.primary
            ),
            body: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                color: colors.primary
            ),
            bodyEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
                color: colors.primary
            ),
            subheadline: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
                color: colors.text
            ),
            subheadlineEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 15.0, weight: .semibold),
                color: colors.text
            ),
            footnote: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                color: colors.textSecondary
            ),
            footnoteEmphasized: AdyenLabelStyle(
                font: UIFont.systemFont(ofSize: 13.0, weight: .semibold),
                color: colors.text
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
            title: labels.bodyEmphasized,
            text: labels.body,
            placeholder: labels.body.color(colors.textSecondary),
            borderWidth: AdyenUIConstants.defaultBorderWidth,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius),
            backgroundColor: colors.background,
            containerColor: colors.container,
            errorColor: colors.destructive,
            borderColor: colors.containerOutline,
            borderActiveColor: colors.primary
        )
    }

    internal static let `default` = AdyenElements(colors: .default)
}
