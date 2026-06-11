//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An error that occurred during the use of a component.
package enum ComponentError: Error, LocalizedError {

    /// Indicates the component was cancelled by the user.
    case cancelled

    /// Indicates the payment method is not supported by the SDK.
    case paymentMethodNotSupported

    package var errorDescription: String? {
        switch self {
        case .cancelled:
            return String(localized: "Payment was cancelled by the user.")
        case .paymentMethodNotSupported:
            return String(localized: "The payment method is not supported.")
        }
    }
}
