//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
extension GiftCardComponent: TrackableComponent {
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }
}

extension GiftCardComponent {

    /// Indicates Gift card related errors.
    public enum Error: LocalizedError {

        /// Indicates that the balance check failed for some reason.
        case balanceCheckFailure

        /// Indicates the payment object passed to the `GiftCardComponent` is nil or invalid.
        case invalidPayment

        /// Indicates that the `partialPaymentDelegate` is nil.
        case missingPartialPaymentDelegate

        /// Indicates that card details encryption failed.
        case cardEncryptionFailed

        /// Indicates any other error
        case otherError(Swift.Error)

        /// :nodoc:
        public var errorDescription: String? {
            switch self {
            case .balanceCheckFailure:
                return "Due to a network issue we couldn’t retrieve the balance. Please try again."
            case .invalidPayment:
                return "For gift card flow to work, you need to provide the Payment object to the component."
            case .missingPartialPaymentDelegate:
                return "Please provide a `PartialPaymentDelegate` object"
            case .cardEncryptionFailed:
                return "Card details encryption failed."
            case let .otherError(error):
                return error.localizedDescription
            }
        }
    }
}
