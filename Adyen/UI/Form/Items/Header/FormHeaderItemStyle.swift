//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension FormHeaderItem {
    
    /// Indicates the `FormHeaderItemView` UI style.
    struct Style: ViewStyle {
        
        /// Indicates the header title style.
        public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 32.0, weight: .bold),
                                                color: .componentLabel,
                                                textAlignment: .center)
        
        /// :nodoc:
        public var backgroundColor: UIColor = .componentBackground
        
        /// Initializes the form header style
        ///
        /// - Parameter title: The header title text style.
        public init(title: TextStyle) {
            self.title = title
        }
        
        /// Initializes the form header style with default style.
        public init() {}
    }
    
}
