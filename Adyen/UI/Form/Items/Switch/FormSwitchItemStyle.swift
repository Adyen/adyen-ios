//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for a switch item in a form.
public struct FormSwitchItemStyle: ViewStyle {
    
    /// The title style.
    public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                            color: UIColor.AdyenCore.componentLabel,
                                            textAlignment: .natural)
    
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
