//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any component that provides partial payments.
@_spi(AdyenInternal)
public protocol PartialPaymentComponent: PaymentComponent {

    /// The delegate that handles partial payments.
    var partialPaymentDelegate: PartialPaymentDelegate? { get set }

    /// The delegate that handles shopper confirmation UI when the balance of the partial payment is sufficient to pay.
    var readyToSubmitComponentDelegate: ReadyToSubmitPaymentComponentDelegate? { get set }
}
