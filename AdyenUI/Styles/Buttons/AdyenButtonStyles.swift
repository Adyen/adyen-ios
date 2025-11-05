//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenButtonStyles {
    
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
        let colors = AdyenColors.default
        self.init(
            primary: .primary(for: colors),
            secondary: .secondary(for: colors),
            tertiary: .tertiary(for: colors),
            destructive: .destructive(for: colors)
        )
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter colorScheme: The colorScheme to follow to style the button.
    public init(colors: AdyenColors) {
        self.init(
            primary: .primary(for: colors),
            secondary: .secondary(for: colors),
            tertiary: .tertiary(for: colors),
            destructive: .destructive(for: colors)
        )
    }

    public static let `default`: AdyenButtonStyles = .init()
}

// MARK: - Builder Methods

public extension AdyenButtonStyles {
    
    /// Returns a new AdyenButtonStyles with the specified primary button style.
    /// - Parameter style: The primary button style to set.
    /// - Returns: A new `AdyenButtonStyles` instance.
    func primary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
        AdyenButtonStyles(
            primary: style,
            secondary: secondary,
            tertiary: tertiary,
            destructive: destructive
        )
    }
    
    /// Returns a new AdyenButtonStyles with the specified secondary button style.
    /// - Parameter style: The secondary button style to set.
    /// - Returns: A new `AdyenButtonStyles` instance.
    func secondary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
        AdyenButtonStyles(
            primary: primary,
            secondary: style,
            tertiary: tertiary,
            destructive: destructive
        )
    }
    
    /// Returns a new AdyenButtonStyles with the specified tertiary button style.
    /// - Parameter style: The tertiary button style to set.
    /// - Returns: A new `AdyenButtonStyles` instance.
    func tertiary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
        AdyenButtonStyles(
            primary: primary,
            secondary: secondary,
            tertiary: style,
            destructive: destructive
        )
    }
    
    /// Returns a new AdyenButtonStyles with the specified destructive button style.
    /// - Parameter style: The destructive button style to set.
    /// - Returns: A new `AdyenButtonStyles` instance.
    func destructive(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
        AdyenButtonStyles(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            destructive: style
        )
    }
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
