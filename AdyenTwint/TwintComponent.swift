//
// Copyright (c) 2017 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import TwintSDK

/// A component that handles a Twint payment.
@MainActor
package final class TwintComponent: PaymentComponent, LoadingComponent {

    package lazy var viewController: UIViewController = paymentButtonViewController

    package let type: PaymentComponentType = .regular

    /// The context object for this component.
    package let context: AdyenContext

    /// The payment method object for this component.
    package let paymentMethod: PaymentMethod

    /// The ready to submit payment data.
    package var paymentData: PaymentComponentData {
        let details = TwintDetails(
            type: paymentMethod,
            subType: "sdk"
        )

        return PaymentComponentData(
            paymentMethodDetails: details,
            order: nil,
            storePaymentMethod: nil
        )
    }

    /// Component's configuration
    package var configuration: TwintComponentConfiguration

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    // MARK: - Initializers

    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    package init(
        paymentMethod: TwintPaymentMethod,
        context: AdyenContext,
        configuration: TwintComponentConfiguration = .init()
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
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

extension TwintComponent: TrackableComponent {}
