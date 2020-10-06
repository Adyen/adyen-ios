//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates the navigation level style.
public struct NavigationStyle: TintableStyle {
    
    /// Indicates the navigation bar background color.
    public var backgroundColor = UIColor.AdyenCore.componentBackground
    
    /// The color of the thin line at the bottom of the navigation bar.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor?
    
    /// Indicates the navigation bar tint color.
    public var tintColor: UIColor?
    
    /// Indicates the corner radius of navigation bar top corners.
    public var cornerRadius: CGFloat = 10
    
    /// Indicates the bar title text style.
    public var barTitle = TextStyle(font: UIFont.AdyenCore.barTitle,
                                    color: UIColor.AdyenCore.componentLabel,
                                    textAlignment: .natural)
    
    /// :nodoc:
    @available(*, deprecated, message: "Use backgroundColor instead.")
    public var barBackgroundColor: UIColor {
        get { backgroundColor }
        
        set { backgroundColor = newValue }
    }
    
    /// :nodoc:
    @available(*, deprecated, message: "Use tintColor instead.")
    public var barTintColor: UIColor {
        get { tintColor ?? UIColor.AdyenCore.defaultBlue }
        set { tintColor = newValue }
    }
    
    /// Initializes the navigation style.
    public init() {}
    
}
