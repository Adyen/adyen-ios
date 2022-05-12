//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles payment methods that don't need any payment detail to be filled.
public final class InstantPaymentComponent: PaymentComponent {

    /// The Adyen context.
    public let adyenContext: AdyenContext

    /// The ready to submit payment data.
    public let paymentData: PaymentComponentData?

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: PaymentMethod,
                paymentData: PaymentComponentData?,
                apiContext: APIContext,
                adyenContext: AdyenContext) {
        self.paymentMethod = paymentMethod
        self.paymentData = paymentData
        self.apiContext = apiContext
        self.adyenContext = adyenContext
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        let details = InstantPaymentDetails(type: paymentMethod.type)
        let paymentData = self.paymentData ?? PaymentComponentData(paymentMethodDetails: details, amount: amountToPay, order: order)

        sendTelemetryEvent()
        submit(data: paymentData)
    }
}

/// :nodoc:
extension InstantPaymentComponent: TrackableComponent {}

/// Describes a payment details that contains nothing but the payment method type name.
public struct InstantPaymentDetails: PaymentMethodDetails {

    /// The payment method type name.
    public let type: PaymentMethodType

    /// Initializes an `EmptyPaymentDetails`.
    ///
    /// - Parameter type: The payment method type name.
    public init(type: PaymentMethodType) {
        self.type = type
    }

}
