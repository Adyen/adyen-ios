//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any buttons.
public struct ButtonStyle: ViewStyle, Equatable {
    
    /// The title style.
    public var title: TextStyle
    
    /// The corners style of the button.
    public var cornerRounding: CornerRounding = .fixed(8)

    /// The color of the Button's border.
    public var borderColor: UIColor?

    /// The width of the Button's border.
    public var borderWidth: CGFloat = 0
    
    /// :nodoc:
    public var backgroundColor = UIColor.Adyen.defaultBlue
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The title style.
    public init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter cornerRadius: The corner radius of the button.
    public init(title: TextStyle, cornerRadius: CGFloat) {
        self.title = title
        self.cornerRounding = .fixed(cornerRadius)
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter cornerRounding: The corner radius of the button style.
    public init(title: TextStyle, cornerRounding: CornerRounding) {
        self.title = title
        self.cornerRounding = cornerRounding
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The button title text style.
    /// - Parameter cornerRadius: The button corner radius.
    /// - Parameter background: Color to fill button's background.
    public init(title: TextStyle, cornerRadius: CGFloat, background: UIColor) {
        self.title = title
        self.cornerRounding = .fixed(cornerRadius)
        self.backgroundColor = background
    }
    
    /// Initializes the button style.
    ///
    /// - Parameter title: The button title text style.
    /// - Parameter cornerRounding: The button corner radius style.
    /// - Parameter background: Color to fill button's background.
    public init(title: TextStyle, cornerRounding: CornerRounding, background: UIColor) {
        self.title = title
        self.cornerRounding = cornerRounding
        self.backgroundColor = background
    }
    
}
