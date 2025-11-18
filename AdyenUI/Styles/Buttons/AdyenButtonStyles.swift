//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Defines styles for different button types.
package struct AdyenButtonStyles {

    package var primary: AdyenButtonStyle
    package var secondary: AdyenButtonStyle
    package var tertiary: AdyenButtonStyle
    package var destructive: AdyenButtonStyle

    /// Initializes the button styles with all parameters required.
    ///
    /// - Parameters:
    ///   - primary: The primary button style.
    ///   - secondary: The secondary button style.
    ///   - tertiary: The tertiary button style.
    ///   - destructive: The destructive button style.
    internal init(
        primary: AdyenButtonStyle,
        secondary: AdyenButtonStyle,
        tertiary: AdyenButtonStyle,
        destructive: AdyenButtonStyle
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.destructive = destructive
    }

    internal static let `default`: AdyenButtonStyles = AdyenElements.default.buttons
}
