//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
@_spi(AdyenInternal) import AdyenUI
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

/// A component that provides a form for stored card payments.
@MainActor
package final class StoredCardComponent: StoredPaymentComponent, Localizable {

    /// The context object for this component.
    package let context: AdyenContext

    /// The card payment method.
    package var paymentMethod: PaymentMethod {
        storedCardPaymentMethod
    }

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    package var localizationParameters: LocalizationParameters?

    private let storedCardPaymentMethod: StoredCardPaymentMethod
    private let theme: AdyenTheme

    package init(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        theme: AdyenTheme
    ) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
        self.theme = theme
    }

    package lazy var viewController: UIViewController = {
        let viewModel = StoredCardInputViewModel(
            theme: theme,
            storedCardPaymentMethod: storedCardPaymentMethod,
            apiContext: context.apiContext,
            publicKey: context.publicKey,
            amount: context.amount,
            analyticsProvider: context.analyticsProvider,
            localizationParameters: localizationParameters
        )

        viewModel.cardDetailsCompletionHandler = { [weak self] in
            self?.receivedCardDetailsResultToProcessPayment(result: $0)
        }

        viewModel.closeHandler = { [weak self] in
            self?.viewController.dismiss(animated: true)
        }

        // TODO: Robert: This doesn't seem to a right place to trigger initialAnalytics(). As this is a lazy var. Maybe this could be moved elsewhere? - I don't know where as of yet.
        self.sendInitialAnalytics()

        let storedCardInputController = StoredCardInputViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: storedCardInputController)
    }()

    private func receivedCardDetailsResultToProcessPayment(result: Result<CardDetails, Error>) {
        switch result {
        case let .success(details):
            submit(data: PaymentComponentData(
                paymentMethodDetails: details,
                amount: context.amount,
                order: order
            ))
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        }
    }
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
