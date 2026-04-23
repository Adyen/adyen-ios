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
    
    @MainActor
    internal static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) throws -> PaymentComponent {
        
        // Assembly layer
        switch paymentMethod {
            
        // components module
        #if canImport(AdyenComponents)
            case let blikPaymentMethod as BLIKPaymentMethod:
                return try createComponent(
                    using: BLIKComponentFactory(),
                    paymentMethod: blikPaymentMethod,
                    configuration: configuration,
                    context: context
                )
            case let achPaymentMethod as ACHDirectDebitPaymentMethod:
                return try createComponent(
                    using: ACHDirectDebitComponentFactory(),
                    paymentMethod: achPaymentMethod,
                    configuration: configuration,
                    context: context
                )
            case let applePayPaymentMethod as ApplePayPaymentMethod:
                return try createComponent(
                    using: ApplePayComponentFactory(),
                    paymentMethod: applePayPaymentMethod,
                    configuration: configuration,
                    context: context
                )
        #endif
            
        // card module
        #if canImport(AdyenCard)
            case let cardPaymentMethod as CardPaymentMethod:
                return try createComponent(
                    using: CardComponentFactory(),
                    paymentMethod: cardPaymentMethod,
                    configuration: configuration,
                    context: context
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
    @MainActor
    internal static func build(
        for storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) -> PaymentComponent {
        
        // TODO: stored components requires no configuration
        // (when new localization is implemented, see if this needs to updated
        
        switch storedPaymentMethod {
            
        #if canImport(AdyenCard)
            case let storedCard as StoredCardPaymentMethod:
                StoredCardComponent(
                    storedCardPaymentMethod: storedCard,
                    context: context,
                    theme: configuration.theme
                )
        #endif
            
        default:
            StoredPaymentMethodComponent(
                paymentMethod: storedPaymentMethod,
                context: context
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
    @MainActor
    private static func createComponent<Factory: PaymentComponentFactory>(
        using factory: Factory,
        paymentMethod: Factory.Method,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) throws -> PaymentComponent where Factory.Configuration: CheckoutComponentConfiguration {

        guard var componentConfiguration = configuration.configuration(
            for: paymentMethod,
            defaultValue: factory.defaultConfiguration()
        ) else {
            // No merchant-provided configuration and no usable default — the integrator
            // must provide one for this payment method (e.g., Apple Pay).
            // TODO: turn this error into CheckoutError with a type
            throw UnknownError(
                errorDescription: "Missing required configuration for payment method \(paymentMethod.type.rawValue). "
                    + "Provide a configuration via CheckoutConfiguration to use this payment method."
            )
        }

        componentConfiguration.showsSubmitButton = configuration.showsSubmitButton
        componentConfiguration.theme = configuration.theme

        return try factory.create(
            with: paymentMethod,
            context: context,
            configuration: componentConfiguration
        )
    }
}
