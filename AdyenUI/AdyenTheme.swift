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

extension AdyenTheme {
    @discardableResult
    public func colors(_ colors: AdyenColors) -> AdyenTheme {
        AdyenTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }

    @discardableResult
    public func elements(_ elements: AdyenElements) -> AdyenTheme {
        AdyenTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }

    @discardableResult
    public func attributes(_ attributes: AdyenAttributes) -> AdyenTheme {
        AdyenTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }
}
