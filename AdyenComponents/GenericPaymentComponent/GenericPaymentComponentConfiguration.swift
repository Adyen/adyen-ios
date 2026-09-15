//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for the Generic Payment Component.
///
/// Used for payment methods that don't need any payment detail to be filled in
/// (e.g. iDEAL, PayPal, Alipay, OXXO, Multibanco).
public struct GenericPaymentComponentConfiguration: CheckoutComponentConfiguration {

    /// `GenericPaymentComponent` is used for many different payment method types dynamically,
    /// so this value is not tied to a specific `PaymentMethodType`. It is only used as a fallback
    /// key when no explicit per-payment-method-type configuration has been registered.
    package var componentType: CheckoutComponentType = .payment(.other(""))

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    package var showsSubmitButton: Bool = true

    /// The theming to apply to the component's UI.
    package var theme: CheckoutTheme = .default

    /// The localization parameters, leave it nil to use the default parameters.
    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// Initializes a new instance of `GenericPaymentComponentConfiguration`.
    public init() {}
}
