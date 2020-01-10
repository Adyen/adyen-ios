//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct NavigationStyle: ViewStyle {
    
    /// Indicates the navigation bar background color.
    public var barBackgroundColor: UIColor = .componentBackground
    
    /// Indicates the navigation bar tint color.
    public var barTintColor: UIColor = .defaultBlue
    
    /// Indicates the bar title text style.
    public var barTitle: TextStyle = TextStyle(font: .systemFont(ofSize: 20, weight: .semibold),
                                               color: .componentLabel,
                                               textAlignment: .natural)
    
    /// Indicates the navigation level tint color.
    public var tintColor: UIColor = .defaultBlue
    
    /// :nodoc:
    public var backgroundColor: UIColor = .componentBackground
    
    /// Initializes the navigation style.
    public init() {}
    
}
