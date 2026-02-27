//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Factory for creating BLIK payment components.
///
/// This factory creates `BLIKComponent` instances configured with the
/// provided BLIK payment method and component configuration.
package struct BLIKComponentFactory: PaymentComponentFactory {
    package typealias Configuration = BLIKComponentConfiguration
    package typealias Method = BLIKPaymentMethod
    package typealias Component = BLIKComponent
    
    package init() {}
    
    /// Creates a BLIK payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured BLIK component.
    package func create(
        with paymentMethod: BLIKPaymentMethod,
        context: AdyenContext,
        configuration: BLIKComponentConfiguration,
        publicKey: PublicKeyFetchingProgramFlow
    ) -> BLIKComponent {
        BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }
    
    package func defaultConfiguration() -> BLIKComponentConfiguration {
        BLIKComponentConfiguration()
    }
}
