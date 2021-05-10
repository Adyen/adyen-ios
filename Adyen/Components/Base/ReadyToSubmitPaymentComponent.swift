//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment component for which payment data is ready to be submitted.
/// :nodoc:
public final class ReadyToSubmitPaymentComponent: PaymentComponent {

    /// The ready to submit payment data.
    public let paymentData: PaymentComponentData

    /// The payment method that triggered the paymant.
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// Initializes the `ReadyToSubmitPaymentComponent` object.
    ///
    /// - Parameter paymentData: The ready to submit payment data.
    /// - Parameter paymentMethod: The payment method that triggered the paymant.
    public init(paymentData: PaymentComponentData, paymentMethod: PaymentMethod) {
        self.paymentData = paymentData
        self.paymentMethod = paymentMethod
    }
}
