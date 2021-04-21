//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for stored card payments.
internal final class StoredCardComponent: PaymentComponent, PresentableComponent, Localizable {
    
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
    internal init(storedCardPaymentMethod: StoredCardPaymentMethod) {
        self.storedCardPaymentMethod = storedCardPaymentMethod
    }
    
    /// :nodoc:
    internal var viewController: UIViewController {
        storedCardAlertManager.alertController
    }
    
    /// :nodoc:
    internal lazy var storedCardAlertManager: StoredCardAlertManager = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        var manager: StoredCardAlertManager
        
        if let clientKey = clientKey {
            manager = createStoredCardAlertManager(withClientKey: clientKey)
        } else if let publicKey = CardPublicKeyProvider.cachedCardPublicKey {
            manager = createStoredCardAlertManager(withClientKey: publicKey)
        } else {
            fatalError("Either card public key or client key must to be configure.")
        }
        
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(paymentMethodDetails: details))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
    
    private func createStoredCardAlertManager(withClientKey clientKey: String) -> StoredCardAlertManager {
        StoredCardAlertManager(paymentMethod: storedCardPaymentMethod,
                               clientKey: clientKey,
                               environment: environment,
                               amount: payment?.amount)
    }
    
    private func createStoredCardAlertManager(withPublicKey publicKey: String) -> StoredCardAlertManager {
        StoredCardAlertManager(paymentMethod: storedCardPaymentMethod,
                               publicKey: publicKey,
                               amount: payment?.amount)
    }
}
