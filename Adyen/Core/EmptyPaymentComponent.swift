//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that don't need any payment detail to be filled.
/// :nodoc:
public final class EmptyPaymentComponent: PaymentComponent {

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        let details = EmptyPaymentDetails(type: paymentMethod.type)
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount))
    }
}
