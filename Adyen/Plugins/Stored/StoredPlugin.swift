//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class StoredPlugin: Plugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
}

extension StoredPlugin: PaymentDetailsPlugin {
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .present
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let title = ADYLocalizedString("oneClick.confirmationAlert.title", paymentMethod.name)
        let message = paymentMethod.displayName
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionTitle = ADYLocalizedString("cancelButton")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let amount = paymentSession.payment.amount(for: paymentMethod)
        let payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        let payAction = UIAlertAction(title: payActionTitle, style: .default) { _ in
            completion(details)
        }
        alertController.addAction(payAction)
        
        return alertController
    }
    
}
