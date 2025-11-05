//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenTheme {

    package private(set) var colors: AdyenColors
    package private(set) var attributes: AdyenAttributes
    package private(set) var elements: AdyenElements

    /// A default instance of AdyenTheme.
    public static let `default` = AdyenTheme()

    /// Initializes the theme with optional overrides.
    /// Any parameter left as default will use the default value.
    ///
    /// - Parameters:
    ///   - colors: The color scheme. Defaults to `.default`.
    ///   - elements: The UI elements styles. Defaults to `.default`.
    ///   - attributes: The UI attributes. Defaults to `.default`.
    public init(
        colors: AdyenColors = .default,
        elements: AdyenElements = .default,
        attributes: AdyenAttributes = .default
    ) {
        self.colors = colors
        self.attributes = attributes
        self.elements = elements
    }
}
