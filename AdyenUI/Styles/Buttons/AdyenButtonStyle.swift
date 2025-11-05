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

// MARK: - Builder Methods

public extension AdyenButtonStyle {
    
    /// Returns a new AdyenButtonStyle with the specified background color.
    /// - Parameter color: The background color to set.
    /// - Returns: A new `AdyenButtonStyle` instance.
    func backgroundColor(_ color: UIColor) -> AdyenButtonStyle {
        AdyenButtonStyle(
            backgroundColor: color,
            textColor: textColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            cornerRadius: cornerRadius
        )
    }
    
    /// Returns a new AdyenButtonStyle with the specified text color.
    /// - Parameter color: The text color to set.
    /// - Returns: A new `AdyenButtonStyle` instance.
    func textColor(_ color: UIColor) -> AdyenButtonStyle {
        AdyenButtonStyle(
            backgroundColor: backgroundColor,
            textColor: color,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            cornerRadius: cornerRadius
        )
    }
    
    /// Returns a new AdyenButtonStyle with the specified corner radius.
    /// - Parameter radius: The corner radius to set.
    /// - Returns: A new `AdyenButtonStyle` instance.
    func cornerRadius(_ radius: CornerRounding?) -> AdyenButtonStyle {
        AdyenButtonStyle(
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            cornerRadius: radius
        )
    }
    
    /// Returns a new AdyenButtonStyle with the specified disabled background color.
    /// - Parameter color: The disabled background color to set.
    /// - Returns: A new `AdyenButtonStyle` instance.
    func disabledBackgroundColor(_ color: UIColor) -> AdyenButtonStyle {
        AdyenButtonStyle(
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabledBackgroundColor: color,
            disabledTextColor: disabledTextColor,
            cornerRadius: cornerRadius
        )
    }
    
    /// Returns a new AdyenButtonStyle with the specified disabled text color.
    /// - Parameter color: The disabled text color to set.
    /// - Returns: A new `AdyenButtonStyle` instance.
    func disabledTextColor(_ color: UIColor) -> AdyenButtonStyle {
        AdyenButtonStyle(
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: color,
            cornerRadius: cornerRadius
        )
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
