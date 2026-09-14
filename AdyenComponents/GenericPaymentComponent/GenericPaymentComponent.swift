//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// A component that handles payment methods that don't need any payment detail to be filled.
@MainActor
package final class GenericPaymentComponent: PaymentComponent {

    package lazy var viewController: UIViewController = {
        let paymentButtonViewController = PaymentButtonViewController(
            amount: context.amount,
            localizationParameters: localizationParameters,
            theme: theme
        )
        paymentButtonViewController.title = paymentMethod.displayInformation(using: localizationParameters).title
        paymentButtonViewController.onSubmit = { [weak self] in
            self?.performSubmit()
        }
        return paymentButtonViewController
    }()

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

    /// The UI theme used to style the payment button.
    package let theme: CheckoutTheme

    /// The localization parameters.
    package let localizationParameters: LocalizationParameters?

    /// Initializes a new instance of `GenericPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - paymentData: The ready to submit payment data.
    ///   - context: The context object for this component.
    ///   - theme: The UI theme used to style the payment button.
    ///   - localizationParameters: The localization parameters.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        paymentData: PaymentComponentData,
        theme: CheckoutTheme = .default,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.paymentMethod = paymentMethod
        self.paymentData = paymentData
        self.context = context
        self.theme = theme
        self.localizationParameters = localizationParameters
    }

    /// Initializes a new instance of `GenericPaymentComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - order: The partial order for this payment.
    ///   - theme: The UI theme used to style the payment button.
    ///   - localizationParameters: The localization parameters.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        order: PartialPaymentOrder?,
        theme: CheckoutTheme = .default,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.theme = theme
        self.localizationParameters = localizationParameters

        let details = GenericPaymentDetails(type: paymentMethod.type)
        self.paymentData = PaymentComponentData(
            paymentMethodDetails: details,
            order: order
        )
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    package func performSubmit() {
        submit(data: paymentData)
    }
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
