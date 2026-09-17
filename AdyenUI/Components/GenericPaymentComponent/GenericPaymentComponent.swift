//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that handles payment methods that don't need any payment detail to be filled.
@MainActor
package final class GenericPaymentComponent: PaymentComponent, LoadingComponent {

    package lazy var viewController: UIViewController = paymentButtonViewController

    /// The context object for this component.
    package let context: AdyenContext

    /// The ready to submit payment data.
    package let paymentData: PaymentComponentData

    /// The payment method.
    package let paymentMethod: PaymentMethod

    package let type: PaymentComponentType = .generic

    package let paymentMethodBehavior: SDKData.PaymentMethodBehavior = .genericComponent

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// Configuration for Generic Payment Component.
    package typealias Configuration = BasicComponentConfiguration

    /// Component's configuration
    package var configuration: Configuration

    /// Initializes a new instance of `GenericPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - paymentData: The ready to submit payment data.
    ///   - context: The context object for this component.
    ///   - configuration: The configuration for the component.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        paymentData: PaymentComponentData,
        configuration: Configuration = .init()
    ) {
        self.paymentMethod = paymentMethod
        self.paymentData = paymentData
        self.context = context
        self.configuration = configuration
    }

    /// Initializes a new instance of `GenericPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - order: The partial order for this payment.
    ///   - configuration: The configuration for the component.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        order: PartialPaymentOrder?,
        configuration: Configuration = .init()
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration

        let details = GenericPaymentDetails(type: paymentMethod.type)
        self.paymentData = PaymentComponentData(
            paymentMethodDetails: details,
            order: order
        )
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    package func performSubmit() {
        paymentButtonViewController.startLoading()
        submit(data: paymentData)
    }

    package func stopLoading() {
        paymentButtonViewController.stopLoading()
    }

    // MARK: - Private

    private lazy var paymentButtonViewController: PaymentButtonViewController = {
        let paymentButtonViewController = PaymentButtonViewController(
            amount: context.amount,
            localizationParameters: configuration.localizationParameters,
            theme: configuration.theme,
            showsSubmitButton: configuration.showsSubmitButton
        )
        paymentButtonViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        paymentButtonViewController.onSubmit = { [weak self] in
            self?.performSubmit()
        }
        return paymentButtonViewController
    }()
}

/// Describes a payment details that contains nothing but the payment method type name.
public struct GenericPaymentDetails: PaymentMethodDetails {
    
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
