//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
final class StoredCardComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// :nodoc:
    let apiContext: APIContext
    
    /// The card payment method.
    var paymentMethod: PaymentMethod { storedCardPaymentMethod }
    
    /// The delegate of the component.
    weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    var requiresModalPresentation: Bool = false
    
    /// :nodoc:
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    /// :nodoc:
    init(storedCardPaymentMethod: StoredCardPaymentMethod,
         apiContext: APIContext) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.apiContext = apiContext
    }
    
    /// :nodoc:
    var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    /// :nodoc:
    lazy var storedCardAlertManager: StoredCardAlertManager = {
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
            guard let self = self else { return }
            
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
