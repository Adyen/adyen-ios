//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a form button item.
public struct FormButtonItemStyle: ViewStyle {
    
    /// The font used to display the text.
    public var button: ButtonStyle
    
    /// The background of the view.
    public var backgroundColor: UIColor = .clear
    
    /// Initializes the secondary button style.
    ///
    /// - Parameter font: The font of a title.
    public init(button: ButtonStyle) {
        self.button = button
    }
    
    /// Initializes the button style.
    ///
    public init(button: ButtonStyle, background: UIColor) {
        self.button = button
        self.backgroundColor = background
    }
    
    /// Get instance of `FormButtonItemStyle` styled as filled button with corner radius.
    /// - Parameters:
    ///   - font: The font of button's title.
    ///   - textColor: The color of button's title.
    ///   - mainColor: The filling color of a button..
    ///   - cornerRadius: The corner radius of the button.
    public static func main(font: UIFont, textColor: UIColor, mainColor: UIColor, cornerRadius: CGFloat) -> FormButtonItemStyle {
        FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: font, color: textColor),
                                                cornerRadius: cornerRadius,
                                                background: mainColor))
    }
    
    /// Get instance of `FormButtonItemStyle` styled as filled button with default corner radius.
    /// - Parameters:
    ///   - font: The font of button's title.
    ///   - textColor: The color of button's title.
    ///   - mainColor: The filling color of a button..
    public static func main(font: UIFont, textColor: UIColor, mainColor: UIColor) -> FormButtonItemStyle {
        FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: font, color: textColor),
                                                cornerRounding: .fixed(8),
                                                background: mainColor))
    }
    
    /// Get instance of `FormButtonItemStyle` styled as filled button with corner radius.
    /// - Parameters:
    ///   - font: The font of button's title.
    ///   - textColor: The color of button's title.
    ///   - mainColor: The filling color of a button..
    ///   - cornerRounding: The corner style of the button.
    public static func main(font: UIFont, textColor: UIColor, mainColor: UIColor, cornerRounding: CornerRounding) -> FormButtonItemStyle {
        FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: font, color: textColor),
                                                cornerRounding: cornerRounding,
                                                background: mainColor))
    }
    
    /// Get instance of `FormButtonItemStyle` styled as plane button transparent background.
    /// - Parameters:
    ///   - font: The font of button's title.
    ///   - textColor: The color of button's title.
    public static func secondary(font: UIFont, textColor: UIColor) -> FormButtonItemStyle {
        FormButtonItemStyle(button: ButtonStyle(title: TextStyle(font: font, color: textColor),
                                                cornerRadius: 0,
                                                background: .clear))
    }
    
}
