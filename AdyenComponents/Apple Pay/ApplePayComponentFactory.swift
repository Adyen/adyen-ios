//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

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

    package func defaultConfiguration() -> ApplePayConfiguration? {
        nil
    }
}
