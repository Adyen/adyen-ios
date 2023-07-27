//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles payment methods that don't need any payment detail to be filled.
public final class InstantPaymentComponent: PaymentComponent {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The ready to submit payment data.
    public let paymentData: PaymentComponentData

    /// The payment method.
    public let paymentMethod: PaymentMethod

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// Initializes a new instance of `InstantPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - paymentData: The ready to submit payment data.
    ///   - context: The context object for this component.
    public init(paymentMethod: PaymentMethod,
                context: AdyenContext,
                paymentData: PaymentComponentData) {
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
    public init(paymentMethod: PaymentMethod,
                context: AdyenContext,
                order: PartialPaymentOrder?) {
        self.paymentMethod = paymentMethod
        self.context = context

        let details = InstantPaymentDetails(type: paymentMethod.type)
        self.paymentData = PaymentComponentData(paymentMethodDetails: details,
                                                amount: context.payment?.amount,
                                                order: order)
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        sendTelemetryEvent()
        submit(data: paymentData)
    }
}

@_spi(AdyenInternal)
extension InstantPaymentComponent: TrackableComponent {}

/// Describes a payment details that contains nothing but the payment method type name.
public struct InstantPaymentDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The payment method type name.
    public let type: PaymentMethodType

    /// Initializes an `EmptyPaymentDetails`.
    ///
    /// - Parameter type: The payment method type name.
    public init(type: PaymentMethodType) {
        self.type = type
    }

}
