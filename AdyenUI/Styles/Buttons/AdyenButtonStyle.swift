//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

// MARK: - AdyenButtonStyle

/// Defines the style for a button.
package struct AdyenButtonStyle {
    
    package var backgroundColor: UIColor
    package var textColor: UIColor
    package var loadingBackgroundColor: UIColor
    package var loadingTextColor: UIColor
    package var disabledBackgroundColor: UIColor
    package var disabledTextColor: UIColor
    package var cornerRadius: CornerRounding?

    internal init(
        backgroundColor: UIColor,
        textColor: UIColor,
        loadingBackgroundColor: UIColor,
        loadingTextColor: UIColor,
        disabledBackgroundColor: UIColor,
        disabledTextColor: UIColor,
        cornerRadius: CornerRounding? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.loadingBackgroundColor = loadingBackgroundColor
        self.loadingTextColor = loadingTextColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.disabledTextColor = disabledTextColor
        self.cornerRadius = cornerRadius
    }
    
    internal static func primary(for colors: CheckoutColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.primary,
            textColor: colors.textOnPrimary,
            loadingBackgroundColor: colors.disabled,
            loadingTextColor: colors.text,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    internal static func secondary(for colors: CheckoutColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.container,
            textColor: colors.text,
            loadingBackgroundColor: colors.disabled,
            loadingTextColor: colors.text,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    internal static func tertiary(for colors: CheckoutColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.background,
            textColor: colors.highlight,
            loadingBackgroundColor: colors.disabled,
            loadingTextColor: colors.highlight,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    internal static func destructive(for colors: CheckoutColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.destructive,
            textColor: colors.textOnDestructive,
            loadingBackgroundColor: colors.disabled,
            loadingTextColor: colors.text,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
}
