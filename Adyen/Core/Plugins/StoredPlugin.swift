//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class StoredPlugin: Plugin {

    // MARK: - Plugin
    
    override func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
        completionHandler = completion
        navigationController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private var completionHandler: Completion<[PaymentDetail]>?
    
    private lazy var alertController: UIAlertController = {
        let title = ADYLocalizedString("oneClick.confirmationAlert.title", paymentMethod.name)
        let message = paymentMethod.displayName
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionTitle = ADYLocalizedString("cancelButton")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        alertController.addAction(payAction)
        
        return alertController
    }()
    
    private lazy var payAction: UIAlertAction = {
        let amount = paymentSession.payment.amount
        let actionTitle = appearance.checkoutButtonAttributes.title(forAmount: amount.value, currencyCode: amount.currencyCode)
        let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
            self.completionHandler?(self.paymentMethod.details)
        }
        return action
    }()
}
