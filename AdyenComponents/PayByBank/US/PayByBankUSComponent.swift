//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import UIKit

/// A component that handles a Pay by Bank US payment.
@MainActor
package final class PayByBankUSComponent: PresentablePaymentComponent {

    /// The context object for this component.
    package let context: AdyenContext

    /// The payment method object for this component.
    package let paymentMethod: PaymentMethod

    /// The ready to submit payment data.
    package var paymentData: PaymentComponentData {
        let details = InstantPaymentDetails(type: paymentMethod.type)

        return PaymentComponentData(
            paymentMethodDetails: details,
            order: order
        )
    }

    /// Component's configuration
    package var configuration: Configuration

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    package var viewController: UIViewController {
        confirmationViewController
    }
    
    private lazy var confirmationViewController: ConfirmationViewController = {

        let logoUrlProvider = LogoURLProvider(environment: context.apiContext.environment)
     
        return .init(model: .init(
            title: paymentMethod.name,
            headerImageUrl: logoUrlProvider.logoURL(withName: paymentMethod.type.rawValue),
            supportedBankLogoNames: PayByBankUSPaymentMethod.logoNames,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters,
            logoUrlProvider: logoUrlProvider,
            continueHandler: { [weak self] in
                self?.performSubmit()
            }
        ))
    }()

    // MARK: - Initializers

    /// Initializes the Pay by Bank US component.
    ///
    /// - Parameter paymentMethod: The Pay by Bank US payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    package init(
        paymentMethod: PayByBankUSPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    // MARK: - PaymentInitiable

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    package func performSubmit() {
        submit(data: paymentData)
    }
}

extension PayByBankUSComponent: TrackableComponent {}

extension PayByBankUSComponent: LoadingComponent {
    package func stopLoading() {
        confirmationViewController.submitButton.showsActivityIndicator = false
    }
}
