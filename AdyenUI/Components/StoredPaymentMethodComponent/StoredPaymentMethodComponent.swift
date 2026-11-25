//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that handles stored payment methods that need no payment detail to be filled.
///
/// The component submits directly, so its view controller renders only the payment button.
/// Drop-in embeds this controller below its stored payment method header.
@MainActor
package final class StoredPaymentMethodComponent: StoredPaymentComponent, Localizable, LoadingComponent {

    /// Set before the view controller is accessed, so that the payment button picks it up.
    package var localizationParameters: LocalizationParameters?

    /// The context object for this component.
    package let context: AdyenContext

    /// The stored payment method.
    package var paymentMethod: PaymentMethod {
        storedPaymentMethod
    }

    package let type: PaymentComponentType = .stored
    package let requiresUserInteraction: Bool = false

    package weak var delegate: PaymentComponentDelegate?

    package init(
        paymentMethod: StoredPaymentMethod,
        context: AdyenContext,
        theme: CheckoutTheme = .init(),
        showsSubmitButton: Bool = true
    ) {
        self.storedPaymentMethod = paymentMethod
        self.context = context
        self.theme = theme
        self.showsSubmitButton = showsSubmitButton
    }

    private let storedPaymentMethod: StoredPaymentMethod
    private let theme: CheckoutTheme
    private let showsSubmitButton: Bool
    private var didSendInitialAnalytics = false

    package func performSubmit() {
        sendInitialAnalyticsIfNeeded()
        paymentButtonViewController?.startLoading()
        let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: details,
            order: self.order
        )
        submit(data: data)
    }

    package func stopLoading() {
        paymentButtonViewController?.stopLoading()
    }

    // MARK: - PaymentComponent

    package var viewController: UIViewController {
        makePaymentButtonViewControllerIfNeeded()
    }

    // MARK: - Private

    private var paymentButtonViewController: PaymentButtonViewController?

    private func makePaymentButtonViewControllerIfNeeded() -> PaymentButtonViewController {
        if let paymentButtonViewController {
            return paymentButtonViewController
        }

        let viewController = PaymentButtonViewController(
            amount: context.amount,
            localizationParameters: localizationParameters,
            theme: theme,
            showsSubmitButton: showsSubmitButton
        )
        viewController.title = storedPaymentMethod
            .displayInformation(using: localizationParameters)
            .title
        viewController.onSubmit = { [weak self] in
            self?.performSubmit()
        }
        viewController.delegate = self
        paymentButtonViewController = viewController
        return viewController
    }

    private func sendInitialAnalyticsIfNeeded() {
        guard !didSendInitialAnalytics else { return }
        didSendInitialAnalytics = true
        sendInitialAnalytics()
    }
}

extension StoredPaymentMethodComponent: TrackableComponent {}

extension StoredPaymentMethodComponent: ViewControllerDelegate {

    /// Called when the payment button view controller loads, so the component can report that its UI rendered.
    package func viewDidLoad(viewController: UIViewController) {
        sendInitialAnalyticsIfNeeded()
        sendDidLoadEvent()
    }
}
