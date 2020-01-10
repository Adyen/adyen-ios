//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates any `RedirectComponent` UI style.
public struct RedirectComponentStyle {
    
    /// The preferred color to tint the background of the navigation bar and toolbar.
    public let preferredBarTintColor: UIColor
    
    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    public let preferredControlTintColor: UIColor
    
    /// Initializes the `RedirectComponentStyle`.
    ///
    /// - Parameter preferredBarTintColor: The preferred color to tint the background of the navigation bar and toolbar.
    /// - Parameter preferredControlTintColor: The preferred color to tint the control buttons on the navigation bar and toolbar.
    public init(preferredBarTintColor: UIColor,
                preferredControlTintColor: UIColor) {
        self.preferredBarTintColor = preferredBarTintColor
        self.preferredControlTintColor = preferredControlTintColor
    }
    
}
