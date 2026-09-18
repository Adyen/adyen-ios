//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Factory for creating the component that handles a stored card payment.
///
/// Whether the shopper has to re-enter the security code is a card domain rule, so this
/// factory owns the decision: it creates a `StoredCardComponent` when the security code is
/// required, and a direct submitting `StoredPaymentMethodComponent` when it is not.
///
/// Unlike `PaymentComponentFactory`, the created component type varies with the
/// configuration, so this factory returns an existential `StoredPaymentComponent`.
@MainActor
package struct StoredCardComponentFactory {

    package typealias Method = StoredCardPaymentMethod
    package typealias Configuration = CardConfiguration

    package init() {}

    /// Creates the component for the given stored card payment method.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored card payment method to create a component for.
    ///   - context: The context object.
    ///   - configuration: The resolved card configuration.
    /// - Returns: A `StoredCardComponent` when the security code is required, a
    ///   `StoredPaymentMethodComponent` otherwise.
    package func create(
        with paymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration
    ) -> any StoredPaymentComponent {
        guard configuration.showSecurityCodeForStoredCard else {
            let component = StoredPaymentMethodComponent(
                paymentMethod: paymentMethod,
                context: context,
                theme: configuration.theme,
                showsSubmitButton: configuration.showsSubmitButton
            )
            component.localizationParameters = configuration.localizationParameters
            return component
        }

        let component = StoredCardComponent(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            theme: configuration.theme
        )
        component.localizationParameters = configuration.localizationParameters
        return component
    }

    package func defaultConfiguration() -> CardConfiguration {
        CardConfiguration()
    }
}
