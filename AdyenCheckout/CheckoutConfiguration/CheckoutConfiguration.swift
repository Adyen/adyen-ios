//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

/// A configuration container for customizing the behavior of Drop-in and individual components.
///
/// `CheckoutConfiguration` is the central entry point for defining custom behavior in your integration.
/// It customizes component behavior by allowing you to:
/// - Supply component-specific `CheckoutComponentConfiguration` instances.
/// - Control presentation options such as whether to show the default submit button.
///
/// You can add component configurations using a Swift DSL, enabling a declarative setup of your integration.
///
/// For example:
/// ```swift
/// let configuration = try CheckoutConfiguration(
///     environment: .test,
///     amount: Amount(value: 1000, currencyCode: "USD"),
///     clientKey: "<client-key>"
/// ) {
///     CardComponentConfiguration()
///     ApplePayComponentConfiguration()
/// }
/// ```
///
public struct CheckoutConfiguration {
    
    package var showsSubmitButton: Bool = true
    
    // TODO: how we store configurations may change
    package var configurations: [CheckoutComponentType: CheckoutComponentConfiguration]
    
    package var localizationProvider: (any CheckoutLocalizationProvider)?
    package var theme: CheckoutTheme

    package let amount: Amount?

    package let apiContext: APIContext

    package let analyticsApiContext: APIContext?

    package let analyticsConfiguration: AnalyticsConfiguration

    /// Creates a CheckoutConfiguration instance.
    /// - Parameters:
    ///   - environment: The environment to retrieve internal resources from.
    ///   - amount: Payment amount.
    ///   - clientKey: The client key that corresponds to the web service user you will use for initiating the payment.
    ///   - content: Configuration builder to provide the desired configuration instances.
    ///   See https://docs.adyen.com/user-management/client-side-authentication for more information.
    /// - Throws: `ClientKeyError.invalidClientKey` if the client key is invalid.
    public init(
        environment: Environment,
        amount: Amount?,
        clientKey: String,
        analyticsConfiguration: AnalyticsConfiguration = .init(),
        @CheckoutConfigurationBuilder content: () throws -> CheckoutConfigurable
    ) throws {
        let apiContext = try APIContext(environment: environment, clientKey: clientKey)
        let analyticsApiContext = Self.createAnalyticsAPIContext(apiContext: apiContext)

        var configDictionary: [CheckoutComponentType: CheckoutComponentConfiguration] = [:]
        let content = try content()
        let configArray = (content as? CompositeCheckoutConfiguration)?.configurations ?? []
        
        for configuration in configArray {
            if let configuration = configuration as? CheckoutComponentConfiguration {
                configDictionary[configuration.componentType] = configuration
            }
        }
        let configurations = configDictionary

        self.init(
            apiContext: apiContext,
            amount: amount,
            analyticsApiContext: analyticsApiContext,
            analyticsConfiguration: analyticsConfiguration,
            configurations: configurations
        )
    }
    
    internal init(
        apiContext: APIContext,
        amount: Amount?,
        analyticsApiContext: APIContext?,
        analyticsConfiguration: AnalyticsConfiguration,
        configurations: [CheckoutComponentType: CheckoutComponentConfiguration] = [:],
        localizationProvider: (any CheckoutLocalizationProvider)? = nil,
        theme: CheckoutTheme = .default
    ) {
        self.analyticsConfiguration = analyticsConfiguration
        self.analyticsApiContext = analyticsApiContext
        self.amount = amount
        self.apiContext = apiContext
        self.configurations = configurations
        self.localizationProvider = localizationProvider
        self.theme = theme
    }
    
    internal func configuration<T: CheckoutComponentConfiguration>(
        for paymentMethod: PaymentMethod,
        defaultValue: @autoclosure () throws -> T
    ) throws -> T {
        if let config = configurations[.payment(paymentMethod.type)] as? T {
            return config
        }
        return try defaultValue()
    }
    
    internal func configuration<T: CheckoutComponentConfiguration>(for actionType: ActionComponentType, defaultValue: @autoclosure () -> T) -> T {
        if let config = configurations[.action(actionType)] as? T {
            return config
        }
        return defaultValue()
    }
    
    internal func configuration<T: CheckoutComponentConfiguration>(for actionType: ActionComponentType) -> T? {
        configurations[.action(actionType)] as? T
    }

    /// Resolves runtime localization parameters from the checkout-wide provider only.
    ///
    /// Checkout flows do not define component-level localization-provider precedence.
    /// Merchants configure provider-based overrides exclusively through
    /// `CheckoutConfiguration.localizationProvider(...)`.
    internal func resolvedCheckoutLocalizationParameters(
        mergingExistingParameters base: LocalizationParameters? = nil
    ) -> LocalizationParameters? {
        guard let localizationProvider else {
            return base
        }

        return (base ?? LocalizationParameters()).withProvider(localizationProvider)
    }

    // TODO: Robert: Make public to private.
    // This public is not needed, but it currently supports providing
    // analyticsAPIContext in the Integration Examples.
    public static func createAnalyticsAPIContext(
        apiContext: APIContext
    ) -> APIContext? {
        guard
            let analyticsEnvironment = (apiContext.environment as? Environment)?.toAnalyticsEnvironment(),
            let analyticsApiContext = try? APIContext(
                environment: analyticsEnvironment,
                clientKey: apiContext.clientKey
            )
        else {
            AdyenAssertion.assertionFailure(
                message: "APIClient for Analytics couldn't be created. Ensure the used environment is of type `Environment`"
            )
            return nil
        }

        return analyticsApiContext
    }
}

extension CheckoutConfiguration {
    
    public func showsSubmitButton(_ showsSubmitButton: Bool) -> Self {
        var copy = self
        copy.showsSubmitButton = showsSubmitButton
        return copy
    }

    /// Sets a custom localization provider for programmatic string overrides.
    ///
    /// The provider is called for each string the SDK renders. Return a non-`nil` value
    /// to override the default, or return `nil` to let the SDK's standard localization
    /// fallback chain handle the key (app bundle → SDK bundle → English).
    ///
    /// In checkout flows, this is the only merchant-facing provider override. Checkout
    /// resolves it into internal runtime localization parameters before constructing
    /// payment and action components.
    ///
    /// - Note: To add support for a *completely new language*, place a `.strings` or
    ///   `.xcstrings` file with `adyen.*` keys in your app bundle instead of using this provider.
    public func localizationProvider(_ localizationProvider: any CheckoutLocalizationProvider) -> Self {
        var copy = self
        copy.localizationProvider = localizationProvider
        return copy
    }

    /// Sets the theme for the checkout configuration.
    ///
    /// Use `CheckoutTheme` builder methods to customize colors, attributes, and elements:
    ///
    /// - Parameter theme: The CheckoutTheme to apply to the checkout configuration.
    /// - Returns: A modified CheckoutConfiguration with the specified theme.
    public func theme(_ theme: CheckoutTheme) -> Self {
        var copy = self
        copy.theme = theme
        return copy
    }
}
