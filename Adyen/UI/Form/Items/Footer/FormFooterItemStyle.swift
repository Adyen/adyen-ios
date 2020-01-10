//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension FormFooterItem {
    
    /// Indicates the `FormFooterItemView` UI style.
    struct Style: ViewStyle {
        
        /// Indicates the title text UI style.
        public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0),
                                                color: .componentQuaternaryLabel,
                                                textAlignment: .center)
        
        /// Indicates the button UI style.
        public var button = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 17.0, weight: .semibold),
                                                         color: .white,
                                                         textAlignment: .center),
                                        cornerRadius: 8.0)
        
        /// :nodoc:
        public var backgroundColor: UIColor = .componentBackground
        
        /// Initializes the form footer style
        ///
        /// - Parameter title: The footer title text style.
        /// - Parameter button: The footer button style.
        public init(title: TextStyle, button: ButtonStyle) {
            self.title = title
            self.button = button
        }
        
        /// Initializes the form footer style with default style.
        public init() {}
        
    }
    
}
