//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation

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
        case let instantPaymentMethod as InstantPaymentMethod:
            return InstantPaymentComponent(
                paymentMethod: instantPaymentMethod,
                context: context,
                order: nil
            )
        default:
            break
        }
        
        // TODO: for gift card, throw correct error code
        throw CheckoutError(code: .paymentMethodFailure, message: "Payment method \(paymentMethod.type.rawValue) is not supported.")
    }
    
    /// Builds stored payment components.
    @MainActor
    internal static func build(
        for storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) -> PaymentComponent {
        switch storedPaymentMethod {

        #if canImport(AdyenCard)
            case let storedCard as StoredCardPaymentMethod:
                return createStoredCardComponent(
                    storedPaymentMethod: storedCard,
                    configuration: configuration,
                    context: context
                )
        #endif

        default:
            return createStoredPaymentMethodComponent(
                storedPaymentMethod: storedPaymentMethod,
                configuration: configuration,
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

        var componentConfiguration = try configuration.configuration(
            for: paymentMethod,
            defaultValue: factory.defaultConfiguration()
        )

        componentConfiguration.showsSubmitButton = configuration.showsSubmitButton
        componentConfiguration.theme = configuration.theme
        componentConfiguration.localizationParameters = configuration.resolvedCheckoutLocalizationParameters(
            mergingExistingParameters: componentConfiguration.localizationParameters
        )

        return try factory.create(
            with: paymentMethod,
            context: context,
            configuration: componentConfiguration
        )
    }

    @MainActor
    private static func createStoredCardComponent(
        storedPaymentMethod: StoredCardPaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) -> PaymentComponent {
        var component = StoredCardComponent(
            storedCardPaymentMethod: storedPaymentMethod,
            context: context,
            theme: configuration.theme
        )
        component.localizationParameters = configuration.resolvedCheckoutLocalizationParameters()

        return component
    }

    @MainActor
    private static func createStoredPaymentMethodComponent(
        storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext
    ) -> PaymentComponent {
        var component = StoredPaymentMethodComponent(
            paymentMethod: storedPaymentMethod,
            context: context
        )
        component.localizationParameters = configuration.resolvedCheckoutLocalizationParameters()

        return component
    }
}
