//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Defines styles for different button types.
public struct AdyenButtonStyles {

    public var primary: AdyenButtonStyle
    public var secondary: AdyenButtonStyle
    public var tertiary: AdyenButtonStyle
    public var destructive: AdyenButtonStyle

    /// Initializes the button styles.
    ///
    /// - Parameters:
    ///   - primary: The primary button style. Defaults to standard primary style.
    ///   - secondary: The secondary button style. Defaults to standard secondary style.
    ///   - tertiary: The tertiary button style. Defaults to standard tertiary style.
    ///   - destructive: The destructive button style. Defaults to standard destructive style.
    public init(
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

    public static let `default`: AdyenButtonStyles = .init()
}
