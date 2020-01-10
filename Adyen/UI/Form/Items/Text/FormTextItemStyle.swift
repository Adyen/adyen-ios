//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension FormTextItem {
    
    /// Indicates the `FormTextItemView` UI style.
    struct Style: ViewStyle {
        
        /// Indicates the `FormTextItemView` title style.
        public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0),
                                                color: .componentSecondaryLabel,
                                                textAlignment: .natural)
        
        /// Indicates text style of the field.
        public var text: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                               color: .componentLabel,
                                               textAlignment: .natural)
        
        /// Indicates the placeholder text style.
        public var placeholderText: TextStyle?
        
        /// Indicates the icons UI style.
        public var icon: ImageStyle = ImageStyle(borderColor: UIColor(white: 0.0, alpha: 0.2),
                                                 borderWidth: 1.0 / UIScreen.main.nativeScale,
                                                 cornerRadius: 4.0,
                                                 clipsToBounds: true,
                                                 contentMode: .scaleAspectFit)
        
        /// :nodoc:
        public var backgroundColor: UIColor = .clear
        
        /// Initializes the form field style
        ///
        /// - Parameter title: The field title text style.
        /// - Parameter text: The text style.
        /// - Parameter placeholderText: The placeholder text style.
        /// - Parameter icon: Any icon image style.
        public init(title: TextStyle,
                    text: TextStyle,
                    placeholderText: TextStyle? = nil,
                    icon: ImageStyle) {
            self.title = title
            self.text = text
            self.placeholderText = placeholderText
            self.icon = icon
        }
        
        /// Initializes the form field style with default style.
        public init() {}
        
    }
    
}
