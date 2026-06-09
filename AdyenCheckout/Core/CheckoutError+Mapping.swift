//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
import Foundation

package extension CheckoutError {

    /// Creates a ``CheckoutError`` from any `Error`.
    ///
    /// `AdyenCheckout` is the boundary module that imports all internal SDK modules,
    /// making it the single place where every internal error type can be exhaustively converted.
    ///
    /// - If `error` is already a `CheckoutError`, `self` is set to it directly.
    /// - Known SDK error types are mapped to their corresponding ``Code``.
    /// - All other errors use `fallback` as the code (defaults to ``Code/generic``).
    /// - Parameter error: The error to convert.
    /// - Parameter fallback: The code to use when no specific mapping is found.
    init(error: Error, fallback: Code = .generic) {
        if let checkoutError = error as? CheckoutError {
            self = checkoutError
            return
        }
        switch error {
        // Adyen
        case is URLError, is APIError:
            self = .init(code: .httpError, message: error.localizedDescription, underlyingError: error)
        // AdyenComponents
        #if canImport(AdyenComponents)
            case ApplePayComponent.Error.userCannotMakePayment,
                 ApplePayComponent.Error.deviceDoesNotSupportApplePay,
                 ApplePayComponent.Error.invalidToken:
                self = .init(code: .paymentMethodFailure, message: error.localizedDescription, underlyingError: error)
            case ApplePayComponent.Error.emptySummaryItems,
                 ApplePayComponent.Error.emptyMerchantIdentifier,
                 ApplePayComponent.Error.negativeGrandTotal,
                 ApplePayComponent.Error.invalidSummaryItem,
                 ApplePayComponent.Error.invalidCountryCode,
                 ApplePayComponent.Error.invalidCurrencyCode,
                 ApplePayComponent.Error.missingConfiguration,
                 ApplePayComponent.Error.invalidPaymentRequest:
                self = .init(code: .invalidConfiguration, message: error.localizedDescription, underlyingError: error)
        #endif
        default:
            self = .init(code: fallback, message: error.localizedDescription, underlyingError: error)
        }
    }
}
