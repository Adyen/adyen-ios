//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct CheckoutTheme {

    public private(set) var colors: CheckoutColors
    package private(set) var attributes: AdyenAttributes
    package private(set) var elements: AdyenElements

    /// A default instance of CheckoutTheme.
    public static let `default` = CheckoutTheme()

    /// Initializes the theme with optional color palette overrides.
    ///
    /// - Parameter colors: Shared checkout color tokens. Defaults to `.default`.
    public init(colors: CheckoutColors = .default) {
        self.colors = colors
        self.attributes = .default
        self.elements = AdyenElements(colors: colors)
    }

    /// Returns a new theme with the specified colors.
    /// - Parameter colors: The color scheme to apply.
    /// - Returns: A new `CheckoutTheme` instance.
    public func colors(_ colors: CheckoutColors) -> CheckoutTheme {
        CheckoutTheme(
            colors: colors,
            elements: AdyenElements(colors: colors),
            attributes: attributes
        )
    }

    /// Returns a new theme with the specified corner radius.
    /// - Parameter cornerRadius: The corner radius to apply to UI elements.
    /// - Returns: A new `CheckoutTheme` instance.
    public func cornerRadius(_ cornerRadius: CGFloat) -> CheckoutTheme {
        CheckoutTheme(
            colors: colors,
            elements: elements,
            attributes: AdyenAttributes(cornerRadius: cornerRadius)
        )
    }
}

// MARK: - Package/Internal Methods

extension CheckoutTheme {

    /// Internal initializer that accepts elements (for SDK use).
    internal init(
        colors: CheckoutColors = .default,
        elements: AdyenElements = .default,
        attributes: AdyenAttributes = .default
    ) {
        self.colors = colors
        self.attributes = attributes
        self.elements = elements
    }

    /// Returns a new theme with the specified attributes.
    /// - Parameter attributes: The UI attributes to apply.
    /// - Returns: A new `CheckoutTheme` instance.
    internal func attributes(_ attributes: AdyenAttributes) -> CheckoutTheme {
        CheckoutTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }
}
