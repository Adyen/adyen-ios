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

    /// Initializes the button styles.
    ///
    /// - Parameters:
    ///   - primary: The primary button style. Defaults to standard primary style.
    ///   - secondary: The secondary button style. Defaults to standard secondary style.
    ///   - tertiary: The tertiary button style. Defaults to standard tertiary style.
    ///   - destructive: The destructive button style. Defaults to standard destructive style.
    internal init(
        primary: AdyenButtonStyle = .primary(for: .default),
        secondary: AdyenButtonStyle = .secondary(for: .default),
        tertiary: AdyenButtonStyle = .tertiary(for: .default),
        destructive: AdyenButtonStyle = .destructive(for: .default)
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.destructive = destructive
    }

    internal static let `default`: AdyenButtonStyles = .init()
}
