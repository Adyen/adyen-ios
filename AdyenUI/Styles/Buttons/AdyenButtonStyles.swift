//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Defines styles for different button types.
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
    /// - Parameter colors: The colors to follow to style the button.
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

extension AdyenButtonStyles {

    /// Returns a new AdyenButtonStyles with the specified primary button style.
    /// - Parameter style: The primary button style to set.
    /// - Returns: A new `AdyenButtonStyles` instance.
    public func primary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
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
    public func secondary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
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
    public func tertiary(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
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
    public func destructive(_ style: AdyenButtonStyle) -> AdyenButtonStyles {
        AdyenButtonStyles(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            destructive: style
        )
    }
}

extension AdyenButtonStyles: Equatable {
    public static func == (lhs: AdyenButtonStyles, rhs: AdyenButtonStyles) -> Bool {
        lhs.primary == rhs.primary && lhs.destructive == rhs.destructive
            && lhs.secondary == rhs.secondary && lhs.tertiary == rhs.tertiary
    }
}
