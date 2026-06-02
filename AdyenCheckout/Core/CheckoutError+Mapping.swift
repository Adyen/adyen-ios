//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package extension CheckoutError {

    /// Creates a ``CheckoutError`` from any `Error`.
    ///
    /// `AdyenCheckout` is the boundary module that imports all internal SDK modules,
    /// making it the single place where every internal error type can be exhaustively converted.
    ///
    /// - If `error` is already a `CheckoutError`, `self` is set to it directly.
    /// - Known SDK error types are mapped to their corresponding ``Code``.
    /// - All other errors use `fallback` as the code (defaults to ``Code/unknown``).
    /// - Parameter error: The error to convert.
    /// - Parameter fallback: The code to use when no specific mapping is found.
    init(error: Error, fallback: Code = .unknown) {
        if let checkoutError = error as? CheckoutError {
            self = checkoutError
            return
        }
        switch error {
        // Adyen
        case ComponentError.cancelled:
            self = .init(code: .cancelled, message: nil, underlyingError: error)
        default:
            self = .init(code: fallback, message: error.localizedDescription, underlyingError: error)
        }
    }
}
