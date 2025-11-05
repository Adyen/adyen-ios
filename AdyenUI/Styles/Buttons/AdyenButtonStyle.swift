//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

// MARK: - AdyenButtonStyle

/// Defines the style for a button.
public struct AdyenButtonStyle {
    
    public var backgroundColor: UIColor
    public var textColor: UIColor
    public var disabledBackgroundColor: UIColor
    public var disabledTextColor: UIColor
    public var cornerRadius: CornerRounding?

    public init(
        backgroundColor: UIColor,
        textColor: UIColor,
        disabledBackgroundColor: UIColor,
        disabledTextColor: UIColor,
        cornerRadius: CornerRounding? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.disabledTextColor = disabledTextColor
        self.cornerRadius = cornerRadius
    }
    
    public static func primary(for colors: AdyenColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.primary,
            textColor: colors.textOnPrimary,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func secondary(for colors: AdyenColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.container,
            textColor: colors.text,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func tertiary(for colors: AdyenColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: .clear,
            textColor: colors.highlight,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func destructive(for colors: AdyenColors) -> AdyenButtonStyle {
        .init(
            backgroundColor: colors.destructive,
            textColor: colors.textOnDestructive,
            disabledBackgroundColor: colors.disabled,
            disabledTextColor: colors.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
}
