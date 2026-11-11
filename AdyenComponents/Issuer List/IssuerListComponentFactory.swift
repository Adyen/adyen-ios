//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Factory for creating issuer list payment components.
///
/// This factory creates `IssuerListComponent` instances configured with the
/// provided issuer list payment method and component configuration.
@MainActor
package struct IssuerListComponentFactory: PaymentComponentFactory {
    package typealias Configuration = IssuerListConfiguration
    package typealias Method = IssuerListPaymentMethod
    package typealias Component = IssuerListComponent

    package init() {}

    /// Creates an issuer list payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured issuer list component.
    package func create(
        with paymentMethod: IssuerListPaymentMethod,
        context: AdyenContext,
        configuration: IssuerListConfiguration,
        callbacks _: Never?
    ) -> IssuerListComponent {
        IssuerListComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }

    package func defaultConfiguration() -> IssuerListConfiguration {
        IssuerListConfiguration()
    }

    package func isAvailable(
        for _: Method,
        configuration _: Configuration
    ) -> Bool {
        true
    }
}
