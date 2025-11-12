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

    /// Initializes the elements with optional overrides.
    /// Any parameter left as default will use the default value.
    ///
    /// - Parameters:
    ///   - buttons: The button styles. Defaults to `.default`.
    ///   - labels: The label styles. Defaults to `.default`.
    ///   - switch: The switch style. Defaults to `.default`.
    ///   - textField: The text field style. Defaults to `.default`.
    internal init(
        buttons: AdyenButtonStyles = .default,
        labels: AdyenLabelStyles = .default,
        switch: AdyenSwitchStyle = .default,
        textField: AdyenTextFieldStyle = .default
    ) {
        self.buttons = buttons
        self.labels = labels
        self.switch = `switch`
        self.textField = textField
    }

    internal static let `default` = AdyenElements()
}
