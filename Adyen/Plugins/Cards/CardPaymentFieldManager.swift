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

class CardPaymentFieldManager: NSObject {
    weak var delegate: CheckoutPaymentFieldDelegate?
    var valid = false
    
    fileprivate var numberField: CardNumberField
    fileprivate var expirationField: CardExpirationField
    fileprivate var cvcField: CardCvcField
    fileprivate var acceptedCards: [CardType]
    
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
}

extension CardPaymentFieldManager: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == numberField {
            textField.textColor = UIColor.darkText
        }
        
        delegate?.paymentFieldDidUpdateActive(field: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == numberField && textField.text != nil {
            let (_, _, valid) = CardValidator.validate(card: textField.text!, acceptedCards: acceptedCards)
            textField.textColor = valid ? UIColor.darkText : UIColor.red
        } else if textField == expirationField && textField.text != nil {
            let (_, valid, _, _) = CardValidator.validate(expiryDate: textField.text!, split: true)
            textField.textColor = valid ? UIColor.darkText : UIColor.red
        }
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
            didUpdateCvcFieldCharacters(string: string, newString: newString, numbers: numberOnly)
        }
        
        valid = (numberField.valid && expirationField.valid && cvcField.valid)
        delegate?.paymentFieldChangedValidity(valid)
        
        return false
    }
    
    private func didUpdateNumberFieldCharacters(string: String, numbers: String) {
        // Since all cards in CardType Enum i.e Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay are not having numbers more than max length of 19 characters. 19 charachters + 4 spaces = 23 :)
        if string.characters.count != 0 && numberField.text?.characters.count == 23 {
            return
        }
        
        let (type, formatted, valid) = CardValidator.validate(card: numbers, acceptedCards: acceptedCards)
        
        numberField.valid = valid && type != .unknown
        numberField.card = type
        numberField.text = formatted
    }
    
    private func didUpdateExpirationFieldCharacters(string: String, newString: String, numbers: String, isDeleting: Bool) {
        // When Expiry is added properly like this 11/20 and if you press any number then it makes expiry field invalid even nothing displayed on UI
        if string.characters.count != 0 && expirationField.text?.characters.count == 7 {
            return
        }
        
        let (formatted, valid, _, _) = CardValidator.validate(expiryDate: newString, split: !isDeleting)
        
        expirationField.valid = valid
        
        if numbers.characters.count <= 4 {
            expirationField.text = formatted
        }
        
        // We have done all validations now make next cvv field first responder
        if string.characters.count != 0 && expirationField.text?.characters.count == 7 {
            cvcField.becomeFirstResponder()
        }
    }
    
    private func didUpdateCvcFieldCharacters(string: String, newString: String, numbers: String) {
        cvcField.valid = (numbers.characters.count >= 3)
        
        if newString.characters.count <= 4 {
            cvcField.text = newString
            
            if string.characters.count != 0 && cvcField.text?.characters.count == 4 {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}
