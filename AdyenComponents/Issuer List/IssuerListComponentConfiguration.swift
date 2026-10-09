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

/// Configuration for Issuer List type components.
package struct IssuerListComponentConfiguration: CheckoutComponentConfiguration {

    /// `IssuerListComponentConfiguration` is shared across every issuer-based payment method
    /// (iDEAL, EPS, Dotpay and others), so this value is not tied to a specific `PaymentMethodType`.
    /// It is only used as a fallback key when no explicit per-payment-method-type configuration
    /// has been registered.
    package var componentType: CheckoutComponentType = .payment(.other(""))

    package var showsSubmitButton: Bool = true

    /// The UI style of the component.
    package var style: ListComponentStyle

    /// The theming to apply to the component's UI.
    package var theme: CheckoutTheme = .default

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    package init(
        style: ListComponentStyle = .init(),
        theme: CheckoutTheme = .default,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.theme = theme
        self.localizationParameters = localizationParameters
    }
}
