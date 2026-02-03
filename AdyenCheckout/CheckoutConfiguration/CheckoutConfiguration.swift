//
// Copyright (c) Adyen N.V.
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
/// It supports both default and advanced flows out of the box, allowing you to:
/// - Override default behavior with callbacks such as `onSubmit`, `onAdditionalDetails`, `onComplete`, and `onError`.
/// - Customize individual components (e.g., card, Apple Pay) by supplying specific `CheckoutComponentConfiguration` instances.
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
    package var configurations: [CheckoutConfigurationType: CheckoutComponentConfiguration]
    
    package var onSubmit: SubmitHandler?
    
    package var onAdditionalDetails: AdditionalDetailsHandler?
    
    package var onError: CheckoutErrorHandler?
    
    package var onComplete: CheckoutSuccessHandler?
    
    package let context: AdyenContext
    
    package var theme: AdyenTheme

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
        amount: Amount,
        clientKey: String,
        analyticsConfiguration: AnalyticsConfiguration = .init(),
        @CheckoutConfigurationBuilder content: () -> CheckoutConfigurable
    ) throws {
        let apiContext = try APIContext(environment: environment, clientKey: clientKey)
        
        let context = AdyenContext(
            apiContext: apiContext,
            payment: nil,
            amount: amount,
            analyticsConfiguration: analyticsConfiguration
        )
        
        var configDictionary: [CheckoutConfigurationType: CheckoutComponentConfiguration] = [:]
        let content = content()
        let configArray = (content as? CompositeCheckoutConfiguration)?.configurations ?? []
        
        for configuration in configArray {
            if let configuration = configuration as? CheckoutComponentConfiguration {
                configDictionary[configuration.configurationType] = configuration
            }
        }
        let configurations = configDictionary
        
        self.init(context: context, configurations: configurations)
    }
    
    internal init(
        context: AdyenContext,
        configurations: [CheckoutConfigurationType: CheckoutComponentConfiguration] = [:],
        theme: AdyenTheme = .default
    ) {
        self.context = context
        self.configurations = configurations
        self.theme = theme
    }
    
    internal func configuration<T: CheckoutComponentConfiguration>(for paymentMethod: PaymentMethod, defaultValue: @autoclosure () -> T) -> T {
        if let config = configurations[.payment(paymentMethod.type)] as? T {
            return config
        }
        return defaultValue()
    }
    
    // TODO: same for action
    
}

extension CheckoutConfiguration {
    
    public func showsSubmitButton(_ showsSubmitButton: Bool) -> Self {
        var copy = self
        copy.showsSubmitButton = showsSubmitButton
        return copy
    }

    /// Sets the theme for the checkout configuration.
    ///
    /// Use `AdyenTheme` builder methods to customize colors, attributes, and elements:
    ///
    /// - Parameter theme: The AdyenTheme to apply to the checkout configuration.
    /// - Returns: A modified CheckoutConfiguration with the specified theme.
    public func theme(_ theme: AdyenTheme) -> Self {
        var copy = self
        copy.theme = theme
        return copy
    }
}
