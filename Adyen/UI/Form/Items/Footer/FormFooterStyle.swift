//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a form footer.
public struct FormFooterStyle: ViewStyle {
    
    /// The title style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                 color: UIColor.AdyenCore.componentQuaternaryLabel)
    
    /// The main button style.
    public var button = ButtonStyle(title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white))
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// Initializes the form footer style
    ///
    /// - Parameter title: The title style.
    /// - Parameter button: The button style.
    public init(title: TextStyle, button: ButtonStyle) {
        self.title = title
        self.button = button
    }
    
    /// Initializes the form footer style
    ///
    /// - Parameter button: The button style.
    public init(button: ButtonStyle) {
        self.button = button
    }
    
    /// Initializes the form footer style with the default style.
    public init() {}
    
}
