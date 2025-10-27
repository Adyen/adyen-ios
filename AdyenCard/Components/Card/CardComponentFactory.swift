//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

// TODO: Since stored card component may be changed, maybe we won't need this generic option
/// Factory for creating card payment components.
///
/// This factory is generic over any payment method that conforms to `AnyCardPaymentMethod`,
/// allowing it to handle regular cards, stored cards, and BCMC payments.
package struct CardComponentFactory<CardMethod: AnyCardPaymentMethod>: PaymentComponentFactory {
    
    package typealias Method = CardMethod
    package typealias Configuration = CardComponent.Configuration
    package typealias Component = CardComponent
    
    package init() {}
    
    /// Creates a card payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured card component.
    package func create(
        with paymentMethod: CardMethod,
        context: AdyenContext,
        configuration: CardComponent.Configuration
    ) -> CardComponent {
        CardComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }
    
    package func defaultConfiguration() -> CardComponent.Configuration {
        CardComponent.Configuration()
    }
}
