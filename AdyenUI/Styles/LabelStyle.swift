//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct LabelStyle {
    /// The font used to display the text.
    public var font: UIFont

    /// The color of the text.
    public var color: UIColor = ColorScheme.default.background

    /// The color of the text when the element is disabled.
    public var disabledColor = ColorScheme.default.disabled

    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment = .center

    /// A default instance of LabelStyle.
    public static let `default` = LabelStyle()

    /// Initializes the label style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter disabledColor: The color of the text when the element is disabled.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    public init(
        font: UIFont = FontStyle.default.body,
        color: UIColor = ColorScheme.default.primary,
        disabledColor: UIColor = ColorScheme.default.disabled,
        textAlignment: NSTextAlignment = .left
    ) {
        self.font = FontStyle.default.body
        self.color = ColorScheme.default.primary
        self.disabledColor = disabledColor
        self.textAlignment = textAlignment
    }
}

// This extension adds the method chaining to the LabelStyle struct.
extension LabelStyle {

    /// Returns a new LabelStyle with the specified font.
    /// - Parameter font: The font to set.
    /// - Returns: A new `LabelStyle` instance.
    public func font(_ font: UIFont) -> LabelStyle {
        var newStyle = self
        newStyle.font = font
        return newStyle
    }

    /// Returns a new LabelStyle with the specified color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `LabelStyle` instance.
    public func color(_ color: UIColor) -> LabelStyle {
        var newStyle = self
        newStyle.color = color
        return newStyle
    }

    /// Returns a new LabelStyle with the specified disabled color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `LabelStyle` instance.
    public func disabledColor(_ color: UIColor) -> LabelStyle {
        var newStyle = self
        newStyle.disabledColor = color
        return newStyle
    }

    /// Returns a new LabelStyle with the specified text alignment.
    /// - Parameter alignment: The text alignment to set.
    /// - Returns: A new `LabelStyle` instance.
    public func textAlignment(_ alignment: NSTextAlignment) -> LabelStyle {
        var newStyle = self
        newStyle.textAlignment = alignment
        return newStyle
    }

}
