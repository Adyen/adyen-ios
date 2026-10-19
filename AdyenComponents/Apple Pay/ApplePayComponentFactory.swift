//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Factory for creating Apple Pay payment components.
///
/// Apple Pay has no usable default configuration because it requires merchant-specific
/// fields (merchant identifier, payment request). Integrators must supply a configuration
/// via the `CheckoutConfiguration` DSL.
@MainActor
package struct ApplePayComponentFactory: PaymentComponentFactory {
    package typealias Configuration = ApplePayConfiguration
    package typealias Method = ApplePayPaymentMethod
    package typealias Component = ApplePayComponent

    package init() {}

    /// Returns `false` if the device or wallet can't make the payment.
    ///
    /// Doesn't create the authorization controller or send analytics.
    package func isAvailable(
        for paymentMethod: ApplePayPaymentMethod,
        configuration: ApplePayConfiguration
    ) -> Bool {
        (try? ApplePayComponent.validatedSupportedNetworks(
            for: paymentMethod,
            configuration: configuration
        )) != nil
    }

    package func create(
        with paymentMethod: ApplePayPaymentMethod,
        context: AdyenContext,
        configuration: ApplePayConfiguration
    ) throws -> ApplePayComponent {
        try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }

    /// - Throws: `ApplePayComponent.Error.missingConfiguration` if no Apple Pay configuration was provided.
    package func defaultConfiguration() throws -> ApplePayConfiguration {
        throw ApplePayComponent.Error.missingConfiguration
    }
}
