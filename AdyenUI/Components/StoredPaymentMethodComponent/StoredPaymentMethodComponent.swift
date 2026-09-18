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
/// The component submits directly, so it renders nothing but a payment button. Drop-in owns its
/// own confirmation UI and ignores this view controller.
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

    /// Initializes new instance of `StoredPaymentMethodComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored payment method.
    ///   - context: The context object.
    ///   - theme: The theme to apply to the payment button.
    ///   - showsSubmitButton: Determines whether the payment button is displayed. Defaults to `true`.
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

    /// Created on demand, so that building the component to check availability does not build UI.
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
