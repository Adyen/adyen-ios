//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that don't need any payment detail to be filled.
/// :nodoc:
public final class InstantPaymentComponent: PaymentComponent {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// The ready to submit payment data.
    public let paymentData: PaymentComponentData?

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: PaymentMethod,
                paymentData: PaymentComponentData?,
                apiContext: APIContext) {
        self.paymentMethod = paymentMethod
        self.paymentData = paymentData
        self.apiContext = apiContext
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        let details = InstantPaymentDetails(type: paymentMethod.type)
        let paymentData = self.paymentData ?? PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order)
        submit(data: paymentData)
    }
}

/// Describes a payment details that contains nothing but the payment method type name.
/// :nodoc:
public struct InstantPaymentDetails: PaymentMethodDetails {

    /// The payment method type name.
    public let type: String

    /// Initializes an `EmptyPaymentDetails`.
    ///
    /// - Parameter type: The payment method type name.
    public init(type: String) {
        self.type = type
    }

}
