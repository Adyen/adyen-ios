//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates a partial payment related errors.
public enum PartialPaymentError: LocalizedError {

    /// Indicates that there is zero remaining amount to be paid.
    case zeroRemainingAmount

    /// Indicates that the order data is missing where its required.
    case missingOrderData

    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .zeroRemainingAmount:
            return "There is no remaining amount to be paid."
        case .missingOrderData:
            return "Order data is missing"
        }
    }
}

/// Any component that provides partial payments.
/// :nodoc:
public protocol PartialPaymentComponent: PaymentComponent {

    /// The delegate that handles partial payments.
    /// :nodoc:
    var partialPaymentDelegate: PartialPaymentDelegate? { get set }

    /// The delegate that handles shopper confirmation UI when the balance of the partial payment is sufficient to pay.
    /// :nodoc:
    var readyToSubmitComponentDelegate: ReadyToSubmitPaymentComponentDelegate? { get set }
}
