//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif

internal enum CheckoutComponentBuilder {
    
    internal static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration
    ) -> PaymentComponent {
        
        // Assembly layer
        switch paymentMethod {
            
        // components module
        #if canImport(AdyenComponents)
            case let blikPaymentMethod as BLIKPaymentMethod:
                return createComponent(
                    using: BLIKComponentFactory(),
                    paymentMethod: blikPaymentMethod,
                    configuration: configuration
                )
            
            case let achPaymentMethod as ACHDirectDebitPaymentMethod:
                return createComponent(
                    using: ACHDirectDebitComponentFactory(),
                    paymentMethod: achPaymentMethod,
                    configuration: configuration
                )
        #endif
            
        // card module
        #if canImport(AdyenCard)
            case let cardPaymentMethod as CardPaymentMethod:
                return createComponent(
                    using: CardComponentFactory(),
                    paymentMethod: cardPaymentMethod,
                    configuration: configuration
                )
                // TODO: add other card methods like stored or write a generic one.
            
        #endif
        default:
            break
        }
        
        // TODO: create real checkout errors
        // TODO: for gift card, throw correct error code
        fatalError()
    }
    
    /// Builds stored payment components.
    internal static func build(
        for storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration
    ) -> PaymentComponent {
        
        // TODO: stored components requires no configuration
        // (when new localization is implemented, see if this needs to updated
        
        switch storedPaymentMethod {
            
        #if canImport(AdyenCard)
            case let storedCard as StoredCardPaymentMethod:
                StoredCardComponent(
                    storedCardPaymentMethod: storedCard,
                    context: configuration.context
                )
        #endif
            
        default:
            StoredPaymentMethodComponent(
                paymentMethod: storedPaymentMethod,
                context: configuration.context
            )
        }
    }

    /// Creates a component using the provided factory for standard payment methods.
    ///
    /// This works for all components whose configurations conform to
    /// `CheckoutComponentConfiguration`.
    ///
    /// - Parameters:
    ///   - factory: The factory to use for component creation.
    ///   - paymentMethod: The payment method to create a component for.
    ///   - configuration: The checkout configuration.
    /// - Returns: A configured payment component.
    private static func createComponent<Factory: PaymentComponentFactory>(
        using factory: Factory,
        paymentMethod: Factory.Method,
        configuration: CheckoutConfiguration
    ) -> PaymentComponent where Factory.Configuration: CheckoutComponentConfiguration {
        
        var componentConfiguration = configuration.configuration(
            for: paymentMethod,
            defaultValue: factory.defaultConfiguration()
        )
        
        componentConfiguration.showsSubmitButton = configuration.showsSubmitButton
        componentConfiguration.theme = configuration.theme
        
        return factory.create(
            with: paymentMethod,
            context: configuration.context,
            configuration: componentConfiguration
        )
    }
}
