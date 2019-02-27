//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class StoredCardPlugin: CardPlugin {
    
    internal override var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .present
    }
    
    internal override func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let alertManager = AlertManager(paymentSession: paymentSession, paymentMethod: paymentMethod, appearance: appearance)
        alertManager.completionHandler = completion
        self.alertManager = alertManager
        
        return alertManager.alertController
    }
    
    internal func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void) {
        alertManager = nil
        
        completion()
    }
    
    private var alertManager: AlertManager?
    
}

extension StoredCardPlugin {
    
    private final class AlertManager: NSObject, UITextFieldDelegate {
        
        internal var completionHandler: Completion<[PaymentDetail]>?
        
        internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod, appearance: Appearance) {
            self.paymentSession = paymentSession
            self.paymentMethod = paymentMethod
            self.appearance = appearance
        }
        
        private let paymentSession: PaymentSession
        private let paymentMethod: PaymentMethod
        private let appearance: Appearance
        
        // MARK: - Alert Controller
        
        internal private(set) lazy var alertController: UIAlertController = {
            let title = ADYLocalizedString("creditCard.oneClickVerification.title")
            let message = ADYLocalizedString("creditCard.oneClickVerification.message", paymentMethod.displayName)
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { textField in
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
                textField.placeholder = ADYLocalizedString("creditCard.cvcField.placeholder")
                textField.accessibilityLabel = ADYLocalizedString("creditCard.cvcField.title")
                textField.delegate = self
            })
            
            let cancelActionTitle = ADYLocalizedString("cancelButton")
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            alertController.addAction(payAction)
            
            return alertController
        }()
        
        private lazy var payAction: UIAlertAction = {
            let amount = paymentSession.payment.amount(for: paymentMethod)
            let actionTitle = appearance.checkoutButtonAttributes.title(for: amount)
            let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
                self.submit()
            }
            action.isEnabled = false
            return action
        }()
        
        private func submit() {
            guard let textField = alertController.textFields?.first, let securityCode = textField.text else {
                return
            }
            
            submit(securityCode: securityCode)
        }
        
        private func submit(securityCode: String) {
            guard
                let publicKey = paymentSession.publicKey,
                let generationDate = paymentSession.generationDate
            else {
                return
            }
            
            let card = CardEncryptor.Card(number: nil, securityCode: securityCode, expiryMonth: nil, expiryYear: nil)
            let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)
            
            var details = paymentMethod.details
            details.encryptedSecurityCode?.value = encryptedCard.securityCode
            completionHandler?(details)
        }
        
        // MARK: - UITextFieldDelegate
        
        internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textFieldText = textField.text else {
                return false
            }
            
            let newString = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            let maxCharactersCount = 4
            if newString.count > maxCharactersCount {
                return false
            }
            
            let isDeleting = (string.count == 0 && range.length == 1)
            if isDeleting {
                let shouldDisable = newString.count == 0
                if shouldDisable {
                    payAction.isEnabled = false
                }
                return true
            }
            
            let newCharacters = CharacterSet(charactersIn: string)
            let isNumber = CharacterSet.decimalDigits.isSuperset(of: newCharacters)
            if isNumber {
                payAction.isEnabled = true
                return true
            }
            
            return false
        }
        
    }
    
}
