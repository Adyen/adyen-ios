//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

protocol CheckoutPaymentFieldDelegate: AnyObject {
    func paymentFieldChangedValidity(_ valid: Bool)
    func paymentFieldDidDetectCard(type: CardType?)
}

class CardPaymentFieldManager: NSObject, UITextFieldDelegate {
    
    // MARK: - Object Lifecycle
    
    init(holderNameField: CardHolderNameField, numberField: CardNumberField, expirationField: CardExpirationField, cvcField: CardCvcField, acceptedCards: [CardType]) {
        self.holderNameField = holderNameField
        self.numberField = numberField
        self.expirationField = expirationField
        self.cvcField = cvcField
        self.acceptedCards = acceptedCards
        
        super.init()
        
        numberField.delegate = self
        expirationField.delegate = self
        cvcField.delegate = self
        holderNameField.delegate = self
        
        numberField.cardTypeDetected = { type in
            self.delegate?.paymentFieldDidDetectCard(type: type)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = validTextColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.count > 0 else {
            return
        }
        
        var valid = false
        
        if textField == numberField {
            valid = CardValidator.validate(cardNumber: text, acceptedCardTypes: acceptedCards).isValid
        } else if textField == expirationField {
            valid = CardValidator.validate(expiryDate: text).isValid
        } else if textField == cvcField {
            valid = CardValidator.validate(cvc: text).isValid || !isCvcRequired
        } else if textField == holderNameField {
            valid = !text.isEmpty || !isHolderNameRequired
        }
        
        textField.textColor = valid ? validTextColor : invalidTextColor
        if !valid {
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == numberField {
            updateCardNumberText(newString)
        } else if textField == expirationField {
            let isDeleting = (string.count == 0 && range.length == 1)
            updateExpirationText(newString, isDeleting: isDeleting)
        } else if textField == cvcField {
            updateCvcFieldText(newString)
        } else if textField == holderNameField {
            updateHolderFieldText(newString)
        }
        
        checkFieldValidity()
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == numberField {
            numberField.card = nil
        }
        return true
    }
    
    // MARK: - Public
    
    weak var delegate: CheckoutPaymentFieldDelegate?
    
    var validTextColor: UIColor?
    var invalidTextColor: UIColor?
    
    var isHolderNameRequired = true {
        didSet {
            holderNameField.valid = holderNameField.valid || !isHolderNameRequired
            checkFieldValidity()
        }
    }
    
    var isCvcRequired = true {
        didSet {
            if isCvcRequired != oldValue {
                let valid: Bool
                if isCvcRequired {
                    if let text = cvcField.text {
                        valid = CardValidator.validate(cvc: text).isValid
                    } else {
                        valid = false
                    }
                } else {
                    valid = true
                }
                cvcField.valid = valid
                cvcField.textColor = valid ? validTextColor : invalidTextColor
                checkFieldValidity()
            }
        }
    }
    
    /// This method should be used in place of directly setting the text on the textfield.
    /// It makes sure to call the UITextField delegate methods, so the fields are sanitized and validated.
    func set(text: String?, inField textField: UITextField?) {
        guard let textField = textField else {
            return
        }
        
        textField.text = nil
        let replacementString = text ?? ""
        let range = NSRange()
        _ = self.textField(textField, shouldChangeCharactersIn: range, replacementString: replacementString)
        textFieldDidEndEditing(textField)
    }
    
    // MARK: - Private
    
    private var holderNameField: CardHolderNameField
    private var numberField: CardNumberField
    private var expirationField: CardExpirationField
    private var cvcField: CardCvcField
    private var acceptedCards: [CardType]
    
    private func updateCardNumberText(_ newText: String) {
        let maximumNumberOfCharacters = 23
        let (valid, type, formatted) = CardValidator.validate(cardNumber: newText, acceptedCardTypes: acceptedCards)
        
        guard formatted.count <= maximumNumberOfCharacters else {
            return
        }
        
        numberField.valid = valid && type != nil
        numberField.card = type
        numberField.text = formatted
        
        // If we have reached full length, make expiry first responder.
        if numberField.text?.count == maximumNumberOfCharacters {
            expirationField.becomeFirstResponder()
        }
    }
    
    private func updateExpirationText(_ newText: String, isDeleting: Bool) {
        let maximumNumberOfCharacters = 5
        let (valid, formatted) = CardValidator.validate(expiryDate: newText, separator: isDeleting ? nil : "/")
        
        guard formatted.count <= maximumNumberOfCharacters else {
            return
        }
        
        expirationField.valid = valid
        expirationField.text = formatted
        
        // If we have reached full length, make CVC first responder.
        if expirationField.text?.count == maximumNumberOfCharacters {
            cvcField.becomeFirstResponder()
        }
    }
    
    private func updateCvcFieldText(_ newText: String) {
        let maximumNumberOfCharacters = 4
        let (valid, formatted) = CardValidator.validate(cvc: newText)
        
        guard formatted.count <= maximumNumberOfCharacters else {
            return
        }
        
        cvcField.valid = !isCvcRequired || valid
        cvcField.text = formatted
        
        // If we have reached full length, dismiss keyboard.
        if cvcField.text?.count == maximumNumberOfCharacters {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func updateHolderFieldText(_ newText: String) {
        let maximumNumberOfCharacters = 26
        
        holderNameField.valid = !isHolderNameRequired || !newText.isEmpty
        holderNameField.text = newText
        
        // If we have reached full length, make CardNumber first responder.
        if holderNameField.text?.count == maximumNumberOfCharacters {
            numberField.becomeFirstResponder()
        }
    }
    
    private func checkFieldValidity() {
        let valid = (numberField.valid && expirationField.valid && cvcField.valid && holderNameField.valid)
        delegate?.paymentFieldChangedValidity(valid)
    }
}
