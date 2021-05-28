//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a switch item in a form.
public struct FormToggleItemStyle: FormValueItemStyle {
    
    /// The title style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .body),
                                 color: UIColor.Adyen.componentLabel,
                                 textAlignment: .natural)
    
    /// The color of `onTintColor` of switch.
    public var tintColor: UIColor?
    
    /// The color for separator element.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor?
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// Initializes the form switch item style.
    ///
    /// - Parameter title: The title style.
    public init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the form switch item style with the default style.
    public init() {}
}
