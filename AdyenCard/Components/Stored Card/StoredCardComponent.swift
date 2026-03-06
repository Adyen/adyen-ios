//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
@_spi(AdyenInternal) import AdyenUI

/// A component that provides a form for stored card payments.
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
    
    package init(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext
    ) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
    }
    
    package lazy var viewController: UIViewController = {
        let viewModel = StoredCardInputViewModel(
            theme: AdyenTheme(),
            storedCardPaymentMethod: storedCardPaymentMethod,
            apiContext: context.apiContext,
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

        viewModel.otherPaymentOptionsHandler = { [weak self] in
            // TODO: Robert: StoredView: Inform the router to navigation to the payment list.
            self?.viewController.dismiss(animated: true)
        }

        // TODO: Robert: This doesn't seem to a right place to trigger initialAnalytics(). As this is a lazy var. Maybe this could be moved elsewhere? - I don't know where.
        self.sendInitialAnalytics()

        // TODO: Robert: StoredView: 🐞 Whose responsibility is it to maintain the navigation stack i think it should not be this component at all.
        return UINavigationController(
            rootViewController: StoredCardInputViewController(viewModel: viewModel)
        )
    }()

    // TODO: Robert: StoredView: Delete the storedCard Alert Manager
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        sendInitialAnalytics()
        sendDidLoadEvent()
        
        let manager = StoredCardAlertManager(
            paymentMethod: storedCardPaymentMethod,
            context: context,
            amount: context.amount
        )
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] in
            self?.receivedCardDetailsResultToProcessPayment(result: $0)
        }
        
        return manager
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
