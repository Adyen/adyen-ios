//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenLabelStyle {
    /// The font used to display the text.
    public var font: UIFont

    /// The color of the text.
    public var color: UIColor

    /// The color of the background
    public var backgroundColor: UIColor

    /// The color of the text when the element is disabled.
    public var disabledColor: UIColor

    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment = .center

    /// A default instance of AdyenLabelStyle.
    public static let `default` = AdyenLabelStyle()

    /// Initializes the label style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter backgroundColor: The color of the background.
    /// - Parameter disabledColor: The color of the text when the element is disabled.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    public init(
        font: UIFont = AdyenFonts.default.body,
        color: UIColor = AdyenColorScheme.default.primary,
        backgroundColor: UIColor = AdyenColorScheme.default.background,
        disabledColor: UIColor = AdyenColorScheme.default.textOnDisabled,
        textAlignment: NSTextAlignment = .left
    ) {
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.disabledColor = disabledColor
        self.textAlignment = textAlignment
    }

//    public init() {
//        self.font = AdyenFonts.default.body
//        self.color = AdyenColorScheme.default.primary
//        self.backgroundColor = backgroundColor
//        self.disabledColor = AdyenColorScheme.default.disabled
//        self.textAlignment = .natural
//    }
}

// This extension adds the method chaining to the AdyenLabelStyle struct.
extension AdyenLabelStyle {

    /// Returns a new AdyenLabelStyle with the specified font.
    /// - Parameter font: The font to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    public func font(_ font: UIFont) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.font = font
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    public func color(_ color: UIColor) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.color = color
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified disabled color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    public func disabledColor(_ color: UIColor) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.disabledColor = color
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified text alignment.
    /// - Parameter alignment: The text alignment to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    public func textAlignment(_ alignment: NSTextAlignment) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.textAlignment = alignment
        return newStyle
    }
}

package extension AdyenLabelStyle {
    var stringAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .backgroundColor: backgroundColor,
            .font: font
        ]

        if let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle.alignment = textAlignment
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }

        return attributes
    }
}
