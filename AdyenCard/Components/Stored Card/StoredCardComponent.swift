//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// A component that provides a form for stored card payments.
@MainActor
package final class StoredCardComponent: StoredPaymentComponent, Localizable {

    // MARK: - Properties

    package let context: AdyenContext
    package var paymentMethod: PaymentMethod {
        storedCardPaymentMethod
    }

    package weak var delegate: PaymentComponentDelegate?
    package var localizationParameters: LocalizationParameters?

    private let storedCardPaymentMethod: StoredCardPaymentMethod
    private let theme: CheckoutTheme

    // MARK: - Initializers

    package init(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        theme: CheckoutTheme
    ) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
        self.theme = theme
    }

    private lazy var viewModel: StoredCardInputViewModel = {
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
        viewModel.cardDetailsCompletionHandler = makeCompletionHandler()
        return viewModel
    }()

    package lazy var viewController: UIViewController = {
        sendInitialAnalytics()
        return StoredCardInputViewController(viewModel: viewModel)
    }()

    package func submit() {
        Task { await viewModel.submit() }
    }

    // MARK: - Private

    private func makeCompletionHandler() -> (Result<CardDetails, Error>) -> Void {
        { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case let .success(details):
                    self.submit(data: PaymentComponentData(
                        paymentMethodDetails: details,
                        amount: self.context.amount,
                        order: self.order
                    ))
                case let .failure(error):
                    self.delegate?.didFail(with: error, from: self)
                }
            }
        }
    }
}

extension StoredCardComponent: TrackableComponent {}
