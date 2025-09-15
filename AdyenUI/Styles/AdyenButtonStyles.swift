//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenButtonStyles: CheckoutButtonStyles {
    
    public var primary: AdyenButtonStyle
    public var secondary: AdyenButtonStyle
    public var tertiary: AdyenButtonStyle
    public var destructive: AdyenButtonStyle
    
    public init(
        primary: AdyenButtonStyle,
        secondary: AdyenButtonStyle,
        tertiary: AdyenButtonStyle,
        destructive: AdyenButtonStyle
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.destructive = destructive
    }
    
    // Default initializer using the default configurations
    public init() {
        let defaultColorScheme = AdyenColorScheme.default
        self.init(
            primary: .primary(for: defaultColorScheme),
            secondary: .secondary(for: defaultColorScheme),
            tertiary: .tertiary(for: defaultColorScheme),
            destructive: .destructive(for: defaultColorScheme)
        )
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter colorScheme: The colorScheme to follow to style the button.
    public init(colorScheme: AdyenColorScheme) {
        self.init(
            primary: .primary(for: colorScheme),
            secondary: .secondary(for: colorScheme),
            tertiary: .tertiary(for: colorScheme),
            destructive: .destructive(for: colorScheme)
        )
    }

    public static let `default`: AdyenButtonStyles = .init()
}

// Defines styles for different button types
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
    
    public static func primary(for colorScheme: AdyenColorScheme) -> AdyenButtonStyle {
        .init(
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.textOnPrimary,
            disabledBackgroundColor: colorScheme.disabled,
            disabledTextColor: colorScheme.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func secondary(for colorScheme: AdyenColorScheme) -> AdyenButtonStyle {
        .init(
            backgroundColor: colorScheme.container,
            textColor: colorScheme.text,
            disabledBackgroundColor: colorScheme.disabled,
            disabledTextColor: colorScheme.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func tertiary(for colorScheme: AdyenColorScheme) -> AdyenButtonStyle {
        .init(
            backgroundColor: .clear,
            textColor: colorScheme.highlight,
            disabledBackgroundColor: colorScheme.disabled,
            disabledTextColor: colorScheme.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
    
    public static func destructive(for colorScheme: AdyenColorScheme) -> AdyenButtonStyle {
        .init(
            backgroundColor: colorScheme.destructive,
            textColor: colorScheme.textOnDestructive,
            disabledBackgroundColor: colorScheme.disabled,
            disabledTextColor: colorScheme.textOnDisabled,
            cornerRadius: .fixed(AdyenUIConstants.defaultCornerRadius)
        )
    }
}

extension AdyenButtonStyles: Equatable {
    public static func == (lhs: AdyenButtonStyles, rhs: AdyenButtonStyles) -> Bool {
        lhs.primary == rhs.primary &&
            lhs.destructive == rhs.destructive &&
            lhs.secondary == rhs.secondary &&
            lhs.tertiary == rhs.tertiary
    }
}

extension AdyenButtonStyle: Equatable {
    public static func == (lhs: AdyenButtonStyle, rhs: AdyenButtonStyle) -> Bool {
        lhs.textColor == rhs.textColor &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.disabledTextColor == rhs.disabledTextColor &&
            lhs.disabledBackgroundColor == rhs.disabledBackgroundColor &&
            lhs.cornerRadius == rhs.cornerRadius
    }
}
