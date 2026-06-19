//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenSession)
    import AdyenSession
#endif

// MARK: - Session-driven component configuration

/// Forwards session-provided installment options to the card component's delegate `didSet`.
/// The concrete `Session` object is the data source; `CheckoutCore` acts as a transparent
/// forwarder so the existing in-component override mechanism continues to work in v6.
extension CheckoutCore: InstallmentConfigurationAware {

    package var installmentConfiguration: InstallmentConfiguration? {
        (session as? InstallmentConfigurationAware)?.installmentConfiguration
    }
}

/// Forwards whether the session requires the "save payment method" field to be shown.
/// Covers `CardComponent`, `ACHDirectDebitComponent`, and `CashAppPayComponent`, all of which
/// read this value from their delegate in a `didSet` block.
extension CheckoutCore: StorePaymentMethodFieldAware {

    package var showStorePaymentMethodField: Bool? {
        (session as? StorePaymentMethodFieldAware)?.showStorePaymentMethodField
    }
}
