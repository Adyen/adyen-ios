//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Indicates the navigation level style.
package struct NavigationStyle: TintableStyle {

    /// Indicates the navigation bar background color.
    package var backgroundColor = UIColor.Adyen.componentBackground

    /// The color of the thin line at the bottom of the navigation bar.
    /// If value is nil, the default color would be used.
    package var separatorColor: UIColor?

    /// Indicates the navigation bar tint color.
    package var tintColor: UIColor?

    /// Indicates the corner radius of navigation bar top corners.
    package var cornerRadius: CGFloat = 10

    /// Indicates the bar title text style.
    package var barTitle = TextStyle(
        font: UIFont.AdyenCore.barTitle,
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )

    /// Initializes the navigation style.
    package init() {}

}
