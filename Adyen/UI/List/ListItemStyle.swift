//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension ListItem {
    
    /// Indicates the `ListItemView` UI style.
    struct Style: ViewStyle {
        
        /// Indicates the title text UI style.
        public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                                color: .componentLabel,
                                                textAlignment: .natural)
        
        /// Indicates the subtitle text UI style.
        public var subtitle: TextStyle = TextStyle(font: .systemFont(ofSize: 14.0),
                                                   color: .componentSecondaryLabel,
                                                   textAlignment: .natural)
        
        /// Indicates the image UI style.
        public var image: ImageStyle = ImageStyle(borderColor: .componentSeparator,
                                                  borderWidth: 1.0 / UIScreen.main.nativeScale,
                                                  cornerRadius: 4.0,
                                                  clipsToBounds: true,
                                                  contentMode: .scaleAspectFit)
        
        /// :nodoc:
        public var backgroundColor: UIColor = .componentBackground
        
        /// Initializes the list item style
        ///
        /// - Parameter title: The title text style.
        /// - Parameter subtitle: The subtitle text style.
        /// - Parameter image: The image style.
        public init(title: TextStyle, subtitle: TextStyle, image: ImageStyle) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
        }
        
        /// Initializes the list item style with default style.
        public init() {}
        
    }
    
}
