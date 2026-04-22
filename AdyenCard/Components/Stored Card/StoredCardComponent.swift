//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
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

    private let theme: CheckoutTheme

    package init(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        theme: CheckoutTheme
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
            localizationParameters: localizationParameters,
            cardBrand: storedCardPaymentMethod.brand
        )

        viewModel.cardDetailsCompletionHandler = { [weak self] in
            self?.onReceivedCardDetailsResultToProcessPayment(result: $0)
        }

        viewModel.closeHandler = { [weak self] in
            self?.viewController.dismiss(animated: true)
        }

        self.sendInitialAnalytics()

        return StoredCardInputViewController(viewModel: viewModel)
    }()

    private func onReceivedCardDetailsResultToProcessPayment(result: Result<CardDetails, Error>) {
        switch result {
        case let .success(details):
            submit(
                data: PaymentComponentData(
                    paymentMethodDetails: details,
                    amount: context.amount,
                    order: order
                )
            )
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        }
    }
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
