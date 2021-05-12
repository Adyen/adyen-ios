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

    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .zeroRemainingAmount:
            return "There is no remaining amount to be paid."
        }
    }
}

/// Any component that provides partial payments.
public protocol PartialPaymentComponent: AnyObject {

    /// The delegate that handles partial payments.
    var partialPaymentDelegate: PartialPaymentDelegate? { get set }

    /// The delegate that handles shopper confirmation UI when the balance of the partial payment is sufficient to pay.
    var readyToSubmitComponentDelegate: ReadyToSubmitPaymentComponentDelegate? { get set }
}
