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

    /// Initializes the label style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    public init(font: UIFont, color: UIColor) {
        self.font = font
        self.color = color
    }

    /// Initializes the text style.
    ///
    /// - Parameter colorScheme: The colorScheme to follow to style the text.
    /// - Parameter fontStyle: The fontStyle to follow to style the text.
    public init(colorScheme: ColorScheme, fontStyle: FontStyle) {
        self.font = fontStyle.bodyEmphasized
        self.color = colorScheme.primary
    }

    // Default initializer using the default configurations
    public init() {
        self.font = FontStyle.default.title
        self.color = ColorScheme.default.background
    }

    /// Initializes the label style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter disabledColor: The color of the text when the element is disabled.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    public init(
        font: UIFont,
        color: UIColor,
        disabledColor: UIColor = ColorScheme.default.disabled,
        textAlignment: NSTextAlignment
    ) {
        self.init(font: font, color: color)
        self.disabledColor = disabledColor
        self.textAlignment = textAlignment
    }
}

extension LabelStyle: Equatable {
    public static func == (lhs: LabelStyle, rhs: LabelStyle) -> Bool {
        lhs.font == rhs.font &&
            lhs.color == rhs.color &&
            lhs.disabledColor == rhs.disabledColor &&
            lhs.textAlignment == rhs.textAlignment
    }
}
