//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates the navigation level style.
public struct NavigationStyle: ViewStyle {
    
    /// Indicates the navigation bar background color.
    public var barBackgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Indicates the navigation bar tint color.
    public var barTintColor: UIColor = UIColor.AdyenCore.defaultBlue
    
    /// Indicates the bar title text style.
    public var barTitle: TextStyle = TextStyle(font: .systemFont(ofSize: 20, weight: .semibold),
                                               color: UIColor.AdyenCore.componentLabel,
                                               textAlignment: .natural)
    
    /// Indicates the navigation level tint color.
    public var tintColor: UIColor = UIColor.AdyenCore.defaultBlue
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the navigation style.
    public init() {}
    
}
