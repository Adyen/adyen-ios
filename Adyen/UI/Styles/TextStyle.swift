//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any labels.
public struct TextStyle: ViewStyle {
    
    /// The font used to display the text.
    public var font: UIFont
    
    /// The color of the text.
    public var color: UIColor

    /// The color of the text when the element is disabled.
    public var disabledColor = UIColor.Adyen.secondaryComponentBackground
    
    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment = .center
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear

    /// The corners style of the text item.
    public var cornerRounding: CornerRounding = .none
    
    /// Initializes the text style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter disabledColor: The color of the text when the element is disabled.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    /// - Parameter cornerRounding: The corners style of the text item.
    /// - Parameter backgroundColor: The background color.
    public init(font: UIFont,
                color: UIColor,
                disabledColor: UIColor = UIColor.Adyen.componentSecondaryLabel,
                textAlignment: NSTextAlignment,
                cornerRounding: CornerRounding = .none,
                backgroundColor: UIColor = .clear) {
        self.font = font
        self.color = color
        self.disabledColor = disabledColor
        self.textAlignment = textAlignment
        self.cornerRounding = cornerRounding
        self.backgroundColor = backgroundColor
    }
    
    /// Initializes the text style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    public init(font: UIFont, color: UIColor) {
        self.font = font
        self.color = color
    }
    
}

extension NSTextAlignment {}

extension TextStyle: Equatable {
    
    public static func == (lhs: TextStyle, rhs: TextStyle) -> Bool {
        lhs.font == rhs.font &&
            lhs.color.cgColor == rhs.color.cgColor &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.textAlignment == rhs.textAlignment
    }

    /// Convert TextSyle into collection of attributes.
    public var stringAttributes: [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.backgroundColor: backgroundColor,
                          NSAttributedString.Key.font: font]

        if let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle.alignment = textAlignment
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }

        return attributes
    }
}
