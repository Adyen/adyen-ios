//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

protocol CheckoutPaymentFieldDelegate: class {
    func paymentFieldChangedValidity(_ valid: Bool)
    func paymentFieldDidDetectCard(type: CardType)
    func paymentFieldDidUpdateActive(field: UITextField)
}

class CardPaymentFieldManager: NSObject, UITextFieldDelegate {
    
    // MARK: - Object Lifecycle
    
    init(numberField: CardNumberField, expirationField: CardExpirationField, cvcField: CardCvcField, acceptedCards: [CardType]) {
        self.numberField = numberField
        self.expirationField = expirationField
        self.cvcField = cvcField
        self.acceptedCards = acceptedCards
        
        super.init()
        
        numberField.delegate = self
        expirationField.delegate = self
        cvcField.delegate = self
        
        numberField.cardTypeDetected = { type in
            self.delegate?.paymentFieldDidDetectCard(type: type)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.darkText
        delegate?.paymentFieldDidUpdateActive(field: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.characters.count > 0 else {
            return
        }
        
        var valid = false
        
        if textField == numberField {
            valid = CardValidator.validate(cardNumber: text, acceptedCardTypes: acceptedCards).isValid
        } else if textField == expirationField {
            valid = CardValidator.validate(expiryDate: text).isValid
        } else if textField == cvcField {
            valid = CardValidator.validate(cvc: text).isValid || !isCvcRequired
        }
        
        textField.textColor = valid ? validTextColor : invalidTextColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let numberOnly = newString.numberOnly()
        let isDeleting = (string.characters.count == 0 && range.length == 1)
        
        if textField == numberField {
            didUpdateNumberFieldCharacters(string: string, numbers: numberOnly)
        } else if textField == expirationField {
            didUpdateExpirationFieldCharacters(string: string, newString: newString, numbers: numberOnly, isDeleting: isDeleting)
        } else if textField == cvcField {
            didUpdateCvcFieldCharacters(string: string, numbers: numberOnly)
        }
        
        updateFieldValidity()
        
        return false
    }
    
    // MARK: - Public
    
    weak var delegate: CheckoutPaymentFieldDelegate?
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
                updateFieldValidity()
            }
        }
    }
    
    // MARK: - Private
    
    private var numberField: CardNumberField
    private var expirationField: CardExpirationField
    private var cvcField: CardCvcField
    private var acceptedCards: [CardType]
    private let validTextColor = UIColor.darkText
    private let invalidTextColor = UIColor.red
    
    private func didUpdateNumberFieldCharacters(string: String, numbers: String) {
        // Since all cards in CardType Enum i.e Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay are not having numbers more than max length of 19 characters. 19 charachters + 4 spaces = 23 :)
        if string.characters.count != 0 && numberField.text?.characters.count == 23 {
            return
        }
        
        let (valid, type, formatted) = CardValidator.validate(cardNumber: numbers, acceptedCardTypes: acceptedCards)
        
        numberField.valid = valid && type != nil
        numberField.card = type
        numberField.text = formatted
    }
    
    private func didUpdateExpirationFieldCharacters(string: String, newString: String, numbers: String, isDeleting: Bool) {
        // When Expiry is added properly like this 11/20 and if you press any number then it makes expiry field invalid even nothing displayed on UI
        if string.characters.count != 0 && expirationField.text?.characters.count == 7 {
            return
        }
        
        let (valid, formatted) = CardValidator.validate(expiryDate: newString, separator: isDeleting ? nil : "/")
        
        expirationField.valid = valid
        
        if numbers.characters.count <= 4 {
            expirationField.text = formatted
        }
        
        // We have done all validations now make next cvv field first responder
        if string.characters.count != 0 && expirationField.text?.characters.count == 7 {
            cvcField.becomeFirstResponder()
        }
    }
    
    private func didUpdateCvcFieldCharacters(string: String, numbers: String) {
        cvcField.valid = !isCvcRequired || CardValidator.validate(cvc: numbers).isValid
        
        if numbers.characters.count <= 4 {
            cvcField.text = numbers
            
            if string.characters.count != 0 && cvcField.text?.characters.count == 4 {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private func updateFieldValidity() {
        let valid = (numberField.valid && expirationField.valid && cvcField.valid)
        delegate?.paymentFieldChangedValidity(valid)
    }
    
}
