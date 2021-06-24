//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The delegate that handles shopper confirmation UI when the balance of the gift card is sufficient to pay.
/// :nodoc:
public protocol ReadyToSubmitPaymentComponentDelegate: AnyObject {

    /// Called when the payment component is ready to submit shopper details,
    /// and the delegate needs to show a confirmation screen to the shopper.
    /// - Parameters:
    ///   - component: The `InstantPaymentComponent`
    ///   - order: The partial payment order if any.
    func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?)
}
