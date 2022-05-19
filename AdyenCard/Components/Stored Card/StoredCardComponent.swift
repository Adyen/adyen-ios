//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
internal final class StoredCardComponent: PaymentComponent, PresentableComponent, Localizable {
    
    internal let apiContext: APIContext
    
    /// The card payment method.
    internal var paymentMethod: PaymentMethod { storedCardPaymentMethod }
    
    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?
    
    internal var localizationParameters: LocalizationParameters?
    
    internal var requiresModalPresentation: Bool = false
    
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    internal init(storedCardPaymentMethod: StoredCardPaymentMethod,
                  apiContext: APIContext) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.apiContext = apiContext
    }
    
    internal var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        Analytics.sendEvent(
            component: paymentMethod.type.rawValue,
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
                self.submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.amountToPay, order: self.order))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()

}
