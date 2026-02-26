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
package final class StoredCardComponent: StoredPaymentComponent, PaymentAware, Localizable {

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
        // TODO: Robert: StoredView: Return the correct view from here.
        let useNewView = true
        if useNewView {
            // TODO: Robert: StoredView: Pass the AdyenTheme from Configuration when creating this Component
            let viewModel = StoredCardInputViewModel(theme: AdyenTheme(), component: self, localizationParameters: localizationParameters)
            return StoredCardInputViewController(viewModel: viewModel)
        } else {
            return storedCardAlertManager.alertController
        }
    }()

    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        sendInitialAnalytics()
        sendDidLoadEvent()
        
        let manager = StoredCardAlertManager(
            paymentMethod: storedCardPaymentMethod,
            context: context,
            amount: payment?.amount
        )
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(
                    paymentMethodDetails: details,
                    amount: self.payment?.amount,
                    order: self.order
                ))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
