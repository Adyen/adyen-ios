//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Factory for creating Generic payment components.
///
/// This factory creates `GenericPaymentComponent` instances configured with the
/// provided generic payment method and component configuration.
@MainActor
package struct GenericPaymentComponentFactory: PaymentComponentFactory {
    package typealias Configuration = BasicComponentConfiguration
    package typealias Method = GenericPaymentMethod
    package typealias Component = GenericPaymentComponent

    package init() {}

    /// Creates a Generic payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured Generic payment component.
    package func create(
        with paymentMethod: GenericPaymentMethod,
        context: AdyenContext,
        configuration: BasicComponentConfiguration
    ) -> GenericPaymentComponent {
        GenericPaymentComponent(
            paymentMethod: paymentMethod,
            context: context,
            order: nil,
            configuration: configuration
        )
    }

    package func defaultConfiguration() -> BasicComponentConfiguration {
        BasicComponentConfiguration()
    }
}
