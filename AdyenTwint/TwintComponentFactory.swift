//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Factory for creating Twint payment components.
///
/// This factory creates `TwintComponent` instances configured with the
/// provided Twint payment method and component configuration.
@MainActor
package struct TwintComponentFactory: PaymentComponentFactory {
    package typealias Configuration = BasicComponentConfiguration
    package typealias Method = TwintPaymentMethod
    package typealias Component = TwintComponent

    package init() {}

    /// Creates a Twint payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured Twint component.
    package func create(
        with paymentMethod: TwintPaymentMethod,
        context: AdyenContext,
        configuration: BasicComponentConfiguration
    ) -> TwintComponent {
        TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }

    package func defaultConfiguration() -> BasicComponentConfiguration {
        BasicComponentConfiguration()
    }

    package func isAvailable(
        for _: Method,
        configuration _: Configuration
    ) -> Bool {
        true
    }
}
