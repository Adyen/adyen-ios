//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
final class StoredCardComponent: PaymentComponent, PaymentAware, PresentableComponent, Localizable {
    
    /// The context object for this component.
    let context: AdyenContext
    
    /// The card payment method.
    var paymentMethod: PaymentMethod { storedCardPaymentMethod }
    
    /// The delegate of the component.
    weak var delegate: PaymentComponentDelegate?
    
    var localizationParameters: LocalizationParameters?
    
    var requiresModalPresentation: Bool = false
    
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    init(storedCardPaymentMethod: StoredCardPaymentMethod,
         context: AdyenContext) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.context = context
    }
    
    var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    lazy var storedCardAlertManager: StoredCardAlertManager = {
        Analytics.sendEvent(
            component: paymentMethod.type.rawValue,
            flavor: _isDropIn ? .dropin : .components,
            context: context.apiContext
        )
        sendTelemetryEvent()
        
        let manager = StoredCardAlertManager(paymentMethod: storedCardPaymentMethod,
                                             context: context,
                                             amount: payment?.amount)
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(paymentMethodDetails: details,
                                                       amount: self.payment?.amount,
                                                       order: self.order))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
}

/// :nodoc:
extension StoredCardComponent: TrackableComponent {}
