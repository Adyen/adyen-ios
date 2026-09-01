//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Factory for creating stored card payment components.
///
/// Decides whether a stored card needs a CVC input form or can pay directly without extra UI.
@MainActor
package struct StoredCardComponentFactory {

    package init() {}

    /// Creates the appropriate stored card component.
    ///
    /// - Parameters:
    ///   - storedCardPaymentMethod: The stored card payment method.
    ///   - context: The context object.
    ///   - configuration: The card configuration used to decide whether CVC is required.
    ///   - localizationParameters: Optional localization parameters.
    /// - Returns: A configured payment component.
    package func create(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration,
        localizationParameters: LocalizationParameters?
    ) -> PaymentComponent {
        if configuration.showSecurityCodeForStoredCard {
            let component = StoredCardComponent(
                storedCardPaymentMethod: storedCardPaymentMethod,
                context: context,
                theme: configuration.theme
            )
            component.localizationParameters = localizationParameters
            return component
        }

        let component = StoredPaymentMethodComponent(
            paymentMethod: storedCardPaymentMethod,
            context: context
        )
        component.localizationParameters = localizationParameters
        return component
    }
}
