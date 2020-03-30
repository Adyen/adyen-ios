//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for any buttons.
public struct ButtonStyle: ViewStyle {
    
    /// The title style.
    public var title: TextStyle
    
    /// The corner radius of the button.
    public var cornerRadius: CGFloat
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.defaultBlue
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter cornerRadius: The corner radius of the button.
    public init(title: TextStyle, cornerRadius: CGFloat) {
        self.title = title
        self.cornerRadius = cornerRadius
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The button title text style.
    /// - Parameter cornerRadius: The button corner radius.
    /// - Parameter background: Color to fill button's background.
    public init(title: TextStyle, cornerRadius: CGFloat, background: UIColor) {
        self.title = title
        self.cornerRadius = cornerRadius
        self.backgroundColor = background
    }
    
}
