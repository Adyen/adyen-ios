//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package extension CheckoutError {

    /// Maps any `Error` to a `CheckoutError`.
    ///
    /// `AdyenCheckout` is the boundary module that imports all internal SDK modules,
    /// making it the single place where every internal error type can be exhaustively mapped.
    ///
    /// - If `error` is already a `CheckoutError`, it is returned as-is.
    /// - Known SDK error types are mapped to their corresponding ``Code``.
    /// - All other errors use `fallback` as the code (defaults to ``Code/unknown``).
    /// - Parameter fallback: The code to use when no specific mapping is found.
    static func map(_ error: Error, fallback: Code = .unknown) -> CheckoutError {
        if let checkoutError = error as? CheckoutError { return checkoutError }
        switch error {
        // Adyen
        case ComponentError.cancelled:
            return CheckoutError(code: .cancelled, message: nil, underlyingError: error)
        default:
            return CheckoutError(code: fallback, message: error.localizedDescription, underlyingError: error)
        }
    }
}
