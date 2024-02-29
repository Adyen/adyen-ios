//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintComponent: PaymentComponent {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { twintPaymentMethod }

    private let twintPaymentMethod: TwintPaymentMethod

    public var requiresModalPresentation: Bool = true

    /// The ready to submit payment data.
    public let paymentData: PaymentComponentData

    /// Configuration for Twint Component.
    public typealias Configuration = BasicComponentConfiguration

    /// Component's configuration
    public var configuration: Configuration

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    // List of installed Twint apps on the device
    private let installedApps: [TWAppConfiguration] = []

    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: TwintPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.twintPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration

        let details = TwintDetails(type: twintPaymentMethod,
                                   subType: "sdk")
        self.paymentData = PaymentComponentData(paymentMethodDetails: details,
                                                amount: context.payment?.amount,
                                                order: nil)
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        submit(data: paymentData)
    }
}
