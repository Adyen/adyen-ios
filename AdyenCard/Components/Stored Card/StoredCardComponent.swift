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

        viewModel.cardDetailsCompletionHandler = { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case let .success(details):
                    self.submit(
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

        self.sendInitialAnalytics()

        return StoredCardInputViewController(viewModel: viewModel)
    }()

    // TODO: - Implement submit logic in  StoredCardComponent
    public func submit() {
//        let data = PaymentComponentData(
//            paymentMethodDetails: details,
//            amount: context.amount,
//            order: order
//            )
//        submit(data: data)
    }

    public func validate() -> Bool {
        true
    }
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
