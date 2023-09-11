//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
internal final class StoredCardComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// :nodoc:
    internal let apiContext: APIContext
    
    /// The card payment method.
    internal var paymentMethod: PaymentMethod { storedCardPaymentMethod }
    
    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal var requiresModalPresentation: Bool = false
    
    /// :nodoc:
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    /// :nodoc:
    internal init(storedCardPaymentMethod: StoredCardPaymentMethod,
                  apiContext: APIContext) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.apiContext = apiContext
    }
    
    /// :nodoc:
    internal var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    /// :nodoc:
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        Analytics.sendEvent(
            component: paymentMethod.type,
            flavor: _isDropIn ? .dropin : .components,
            context: apiContext
        )
        
        let manager = StoredCardAlertManager(paymentMethod: storedCardPaymentMethod,
                                             apiContext: apiContext,
                                             amount: payment?.amount)
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.payment?.amount, order: self.order))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()

}
