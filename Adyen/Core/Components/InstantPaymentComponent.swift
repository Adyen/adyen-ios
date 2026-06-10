//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles payment methods that don't need any payment detail to be filled.
@MainActor
package final class InstantPaymentComponent: PaymentComponent {

    /// The context object for this component.
    package let context: AdyenContext

    /// The ready to submit payment data.
    package let paymentData: PaymentComponentData

    /// The payment method.
    package let paymentMethod: PaymentMethod

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// Initializes a new instance of `InstantPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - paymentData: The ready to submit payment data.
    ///   - context: The context object for this component.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        paymentData: PaymentComponentData
    ) {
        self.paymentMethod = paymentMethod
        self.paymentData = paymentData
        self.context = context
    }

    /// Initializes a new instance of `InstantPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - order: The partial order for this payment.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        order: PartialPaymentOrder?
    ) {
        self.paymentMethod = paymentMethod
        self.context = context

        let details = InstantPaymentDetails(type: paymentMethod.type)
        self.paymentData = PaymentComponentData(
            paymentMethodDetails: details,
            amount: context.amount,
            order: order
        )
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    package func submit() {
        submit(data: paymentData)
    }
}

/// Describes a payment details that contains nothing but the payment method type name.
public struct InstantPaymentDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?

    /// The payment method type name.
    public let type: PaymentMethodType

    /// Initializes an `EmptyPaymentDetails`.
    ///
    /// - Parameter type: The payment method type name.
    public init(type: PaymentMethodType) {
        self.type = type
    }

}
