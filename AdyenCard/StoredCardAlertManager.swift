//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class StoredCardAlertManager: NSObject, UITextFieldDelegate {
    
    internal var completionHandler: Completion<Result<CardDetails, Error>>?
    
    internal init(paymentMethod: StoredCardPaymentMethod, publicKey: String, amount: Payment.Amount?) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self.amount = amount
    }
    
    private let paymentMethod: StoredCardPaymentMethod
    private let publicKey: String
    private let amount: Payment.Amount?
    
    // MARK: - Alert Controller
    
    internal private(set) lazy var alertController: UIAlertController = {
        let title = ADYLocalizedString("adyen.card.stored.title")
        let message = ADYLocalizedString("adyen.card.stored.message", paymentMethod.displayInformation.title)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = ADYLocalizedString("adyen.card.cvcItem.placeholder")
            textField.accessibilityLabel = ADYLocalizedString("adyen.card.cvcItem.title")
            textField.delegate = self
        })
        
        let cancelActionTitle = ADYLocalizedString("adyen.cancelButton")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel) { _ in
            self.completionHandler?(.failure(ComponentError.cancelled))
        }
        alertController.addAction(cancelAction)
        
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
    private lazy var submitAction: UIAlertAction = {
        let actionTitle = ADYLocalizedSubmitButtonTitle(with: amount)
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
        let card = CardEncryptor.Card(number: nil, securityCode: securityCode, expiryMonth: nil, expiryYear: nil)
        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey)
        let details = CardDetails(paymentMethod: paymentMethod, encryptedSecurityCode: encryptedCard.securityCode ?? "")
        completionHandler?(.success(details))
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
                submitAction.isEnabled = false
            }
            return true
        }
        
        let newCharacters = CharacterSet(charactersIn: string)
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: newCharacters)
        if isNumber {
            submitAction.isEnabled = true
            return true
        }
        
        return false
    }
    
}
