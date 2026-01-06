//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

package struct AdyenLabelStyle {
    /// The font used to display the text.
    package var font: UIFont

    /// The color of the text.
    package var color: UIColor

    /// The color of the text when the element is disabled.
    package var disabledColor: UIColor

    /// The technique to use for aligning the text.
    package var textAlignment: NSTextAlignment = .center

    /// A default instance of AdyenLabelStyle.
    internal static let `default` = AdyenLabelStyle()

    /// Initializes the label style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter disabledColor: The color of the text when the element is disabled.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    internal init(
        font: UIFont = AdyenFonts.default.body,
        color: UIColor = AdyenColors.default.primary,
        disabledColor: UIColor = AdyenColors.default.textSecondary,
        textAlignment: NSTextAlignment = .left
    ) {
        self.font = font
        self.color = color
        self.disabledColor = disabledColor
        self.textAlignment = textAlignment
    }

    internal init() {
        self.font = AdyenFonts.default.body
        self.color = AdyenColors.default.primary
        self.disabledColor = AdyenColors.default.textSecondary
        self.textAlignment = .natural
    }
}

// This extension adds the method chaining to the AdyenLabelStyle struct.
extension AdyenLabelStyle {

    /// Returns a new AdyenLabelStyle with the specified font.
    /// - Parameter font: The font to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    internal func font(_ font: UIFont) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.font = font
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    internal func color(_ color: UIColor) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.color = color
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified disabled color.
    /// - Parameter color: The color to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    internal func disabledColor(_ color: UIColor) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.disabledColor = color
        return newStyle
    }

    /// Returns a new AdyenLabelStyle with the specified text alignment.
    /// - Parameter alignment: The text alignment to set.
    /// - Returns: A new `AdyenLabelStyle` instance.
    internal func textAlignment(_ alignment: NSTextAlignment) -> AdyenLabelStyle {
        var newStyle = self
        newStyle.textAlignment = alignment
        return newStyle
    }
}

extension AdyenLabelStyle {
    var stringAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font
        ]

        if let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle.alignment = textAlignment
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }

        return attributes
    }
}
