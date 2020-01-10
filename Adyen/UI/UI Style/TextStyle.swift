//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates any text UI style like UILabel's for example.
public struct TextStyle: ViewStyle {
    
    /// Indicates the text font.
    public var font: UIFont
    
    /// Indicates the text color.
    public var color: UIColor
    
    /// Indicates text alignment.
    public var textAlignment: NSTextAlignment
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// Initializes the text style.
    ///
    /// - Parameter font: text font.
    /// - Parameter color: text color.
    /// - Parameter textAlignment: text alignment.
    public init(font: UIFont, color: UIColor, textAlignment: NSTextAlignment) {
        self.font = font
        self.color = color
        self.textAlignment = textAlignment
    }
    
}
