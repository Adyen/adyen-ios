//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension FormSwitchItem {
    
    /// Indicates the `FormSwitchItemView` UI style.
    struct Style: ViewStyle {
        
        /// Indicates the `FormSwitchItemView` title style.
        public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                                color: .componentLabel,
                                                textAlignment: .natural)
        
        /// :nodoc:
        public var backgroundColor: UIColor = .componentBackground
        
        /// Initializes the form switch style
        ///
        /// - Parameter title: The switch title text style.
        public init(title: TextStyle) {
            self.title = title
        }
        
        /// Initializes the form switch style with default style.
        public init() {}
    }
    
}
