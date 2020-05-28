//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for an item in a list.
public struct ListItemStyle: ViewStyle {
    
    /// The title style.
    public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                            color: UIColor.AdyenCore.componentLabel,
                                            textAlignment: .natural)
    
    /// The subtitle style.
    public var subtitle: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0),
                                               color: UIColor.AdyenCore.componentSecondaryLabel,
                                               textAlignment: .natural)
    
    /// The image style.
    public var image: ImageStyle = ImageStyle(borderColor: UIColor.AdyenCore.componentSeparator,
                                              borderWidth: 1.0 / UIScreen.main.nativeScale,
                                              cornerRadius: 4.0,
                                              clipsToBounds: true,
                                              contentMode: .scaleAspectFit)
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the list item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter subtitle: The subtitle style.
    /// - Parameter image: The image style.
    public init(title: TextStyle, subtitle: TextStyle, image: ImageStyle) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    /// Initializes the list item style with the default style.
    public init() {}
    
}
