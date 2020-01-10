//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates any "Button" UI style.
public struct ButtonStyle: ViewStyle {
    
    /// Indicates title text style of the button.
    public var title: TextStyle
    
    /// Indicates the corner radius of the button.
    public var cornerRadius: CGFloat
    
    /// :nodoc:
    public var backgroundColor: UIColor = .defaultBlue
    
    /// Initializes the button style
    ///
    /// - Parameter title: The button title text style.
    /// - Parameter cornerRadius: The button corner radius.
    public init(title: TextStyle, cornerRadius: CGFloat) {
        self.title = title
        self.cornerRadius = cornerRadius
    }
    
}
