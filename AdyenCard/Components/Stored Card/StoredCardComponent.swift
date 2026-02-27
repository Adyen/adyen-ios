//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

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
    private let publicKey: PublicKeyFetchingProgramFlow

    package init(
        storedCardPaymentMethod: StoredCardPaymentMethod,
        context: AdyenContext,
        publicKey: PublicKeyFetchingProgramFlow
    ) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
        self.publicKey = publicKey
    }
    
    package var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        sendInitialAnalytics()
        sendDidLoadEvent()
        
        let manager = StoredCardAlertManager(
            paymentMethod: storedCardPaymentMethod,
            context: context,
            publicKey: publicKey,
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
