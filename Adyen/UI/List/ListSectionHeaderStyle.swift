//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for a list section header.
public struct ListSectionHeaderStyle: ViewStyle {
    
    /// The title style.
    public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0, weight: .medium),
                                            color: UIColor.AdyenCore.componentSecondaryLabel,
                                            textAlignment: .natural)
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the list header style.
    ///
    /// - Parameter title: The title style.
    public init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the list header style with the default style.
    public init() {}
    
}
