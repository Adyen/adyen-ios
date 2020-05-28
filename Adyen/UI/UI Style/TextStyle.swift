//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for any labels.
public struct TextStyle: ViewStyle {
    
    /// The font used to display the text.
    public var font: UIFont
    
    /// The color of the text.
    public var color: UIColor
    
    /// The technique to use for aligning the text.
    public var textAlignment: NSTextAlignment
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// Initializes the text style.
    ///
    /// - Parameter font: The font used to display the text.
    /// - Parameter color: The color of the text.
    /// - Parameter textAlignment: The technique to use for aligning the text.
    public init(font: UIFont, color: UIColor, textAlignment: NSTextAlignment) {
        self.font = font
        self.color = color
        self.textAlignment = textAlignment
    }
    
}
