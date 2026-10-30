//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Builds the additional callbacks supplied to `CheckoutCallbacks`.
///
/// Include callback values directly or conditionally with `if` and `if`/`else`.
/// When a callback type occurs more than once, the last value replaces the earlier value.
@resultBuilder
public enum CheckoutAdditionalCallbacksBuilder {

    public static func buildExpression(_ expression: any CheckoutAdditionalCallbacks) -> [any CheckoutAdditionalCallbacks] {
        [expression]
    }

    public static func buildBlock(_ callbacks: [any CheckoutAdditionalCallbacks]...) -> [any CheckoutAdditionalCallbacks] {
        callbacks.flatMap { $0 }
    }

    public static func buildOptional(_ callbacks: [any CheckoutAdditionalCallbacks]?) -> [any CheckoutAdditionalCallbacks] {
        callbacks ?? []
    }

    public static func buildEither(first callbacks: [any CheckoutAdditionalCallbacks]) -> [any CheckoutAdditionalCallbacks] {
        callbacks
    }

    public static func buildEither(second callbacks: [any CheckoutAdditionalCallbacks]) -> [any CheckoutAdditionalCallbacks] {
        callbacks
    }
}

@resultBuilder
package enum AdvancedAdditionalCallbacksBuilder {

    package static func buildExpression(_ expression: any AdvancedCheckoutAdditionalCallbacks) -> [any AdvancedCheckoutAdditionalCallbacks] {
        [expression]
    }

    package static func buildBlock(_ callbacks: [any AdvancedCheckoutAdditionalCallbacks]...) -> [any AdvancedCheckoutAdditionalCallbacks] {
        callbacks.flatMap { $0 }
    }

    package static func buildOptional(_ callbacks: [any AdvancedCheckoutAdditionalCallbacks]?) -> [any AdvancedCheckoutAdditionalCallbacks] {
        callbacks ?? []
    }

    package static func buildEither(first callbacks: [any AdvancedCheckoutAdditionalCallbacks]) -> [any AdvancedCheckoutAdditionalCallbacks] {
        callbacks
    }

    package static func buildEither(second callbacks: [any AdvancedCheckoutAdditionalCallbacks]) -> [any AdvancedCheckoutAdditionalCallbacks] {
        callbacks
    }
}
