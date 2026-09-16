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

    /// Whether stored payment methods are hidden from the payment method list.
    package var hideStoredPaymentMethods: Bool = false

    /// Whether Drop-in starts with the most recently stored payment method.
    package var startWithLastStoredPaymentMethod: Bool = true

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
}
