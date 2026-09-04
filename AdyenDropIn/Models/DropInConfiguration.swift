//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for Drop-in behavior.
public struct DropInConfiguration: CheckoutConfigurable {

    /// Skipping the payment method list for one regular payment method is the v6 default behavior.
    internal let allowsSkippingPaymentList = true

    package var theme: CheckoutTheme = .default
    package var localizationProvider: (any CheckoutLocalizationProvider)?

    // TODO: Remove this legacy adapter when Drop-in consumers use CheckoutLocalizationProvider directly.
    package var resolvedLocalizationParameters: LocalizationParameters? {
        guard let localizationProvider else { return nil }
        return LocalizationParameters().withProvider(localizationProvider)
    }

    package var paymentMethodsList: PaymentMethodListConfiguration {
        var configuration = PaymentMethodListConfiguration()
        configuration.allowDisablingStoredPaymentMethods = allowRemovingStoredPaymentMethods
        return configuration
    }

    /// Whether stored payment methods are hidden from the payment method list.
    package var hideStoredPaymentMethods: Bool = false

    /// Whether Drop-in starts with the most recently stored payment method.
    package var startWithLastStoredPaymentMethod: Bool = true

    /// Whether stored payment methods can be removed in the Advanced flow.
    ///
    /// The removal option is available only when an Advanced Checkout removal handler is also registered.
    /// Session Checkout ignores this setting and uses the session response instead.
    package var allowRemovingStoredPaymentMethods: Bool = false

    /// Creates a Drop-in configuration with default behavior.
    public init() {}

    /// Sets whether stored payment methods are hidden from the payment method list.
    ///
    /// This setting does not affect the preselected stored payment method screen.
    /// - Parameter hideStoredPaymentMethods: Whether to hide stored payment methods from the list.
    /// - Returns: A modified copy of the configuration.
    public func hideStoredPaymentMethods(_ hideStoredPaymentMethods: Bool) -> Self {
        var copy = self
        copy.hideStoredPaymentMethods = hideStoredPaymentMethods
        return copy
    }

    /// Sets whether Drop-in starts with the most recently stored payment method.
    /// - Parameter startWithLastStoredPaymentMethod: Whether to start with the stored payment method.
    /// - Returns: A modified copy of the configuration.
    public func startWithLastStoredPaymentMethod(_ startWithLastStoredPaymentMethod: Bool) -> Self {
        var copy = self
        copy.startWithLastStoredPaymentMethod = startWithLastStoredPaymentMethod
        return copy
    }

    // TODO: Advanced flow only, but added for demo app for now.
    /// Sets whether stored payment methods can be removed in the Advanced flow.
    ///
    /// Session Checkout ignores this setting. Enabling it does not expose removal unless an Advanced Checkout
    /// removal handler is registered before Drop-in is created.
    /// - Parameter allowRemovingStoredPaymentMethods: Whether to allow stored payment method removal.
    /// - Returns: A modified copy of the configuration.
    public func allowRemovingStoredPaymentMethods(_ allowRemovingStoredPaymentMethods: Bool) -> Self {
        var copy = self
        copy.allowRemovingStoredPaymentMethods = allowRemovingStoredPaymentMethods
        return copy
    }
}
