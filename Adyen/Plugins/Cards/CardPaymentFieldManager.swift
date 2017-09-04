//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

protocol CheckoutPaymentFieldDelegate: class {
    func paymentFieldChangedValidity(_ valid: Bool)
    func paymentFieldDidDetectCard(type: CardType?)
    func paymentFieldDidUpdateActive(field: UITextField)
}

class CardPaymentFieldManager: NSObject, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        guard let text = textField.text, text.characters.count > 0, textField != installmentTextField else {
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
        if !valid {
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField != installmentTextField else {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == numberField {
            updateCardNumberText(newString)
        } else if textField == expirationField {
            let isDeleting = (string.characters.count == 0 && range.length == 1)
            updateExpirationText(newString, isDeleting: isDeleting)
        } else if textField == cvcField {
            updateCvcFieldText(newString)
        }
        
        checkFieldValidity()
        
        return false
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return installmentValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return installmentValues[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        installmentTextField?.text = installmentValues[row].name
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
                checkFieldValidity()
            }
        }
    }
    
    func enableInstalments(textField: CardInstallmentField, values: [InputSelectItem]) {
        installmentTextField = textField
        installmentValues = values
        installmentTextField?.text = installmentValues[0].name
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
    
    private var numberField: CardNumberField
    private var expirationField: CardExpirationField
    private var cvcField: CardCvcField
    private var acceptedCards: [CardType]
    private let validTextColor = UIColor.darkText
    private let invalidTextColor = UIColor.red
    private var installmentValues: [InputSelectItem] = []
    
    private var installmentTextField: CardInstallmentField? {
        didSet {
            let pickerView = UIPickerView()
            pickerView.delegate = self
            installmentTextField?.delegate = self
            installmentTextField?.inputView = pickerView
        }
    }
    
    private func updateCardNumberText(_ newText: String) {
        let maximumNumberOfCharacters = 23
        let (valid, type, formatted) = CardValidator.validate(cardNumber: newText, acceptedCardTypes: acceptedCards)
        
        guard formatted.characters.count <= maximumNumberOfCharacters else {
            return
        }
        
        numberField.valid = valid && type != nil
        numberField.card = type
        numberField.text = formatted
        
        // If we have reached full length, make expiry first responder.
        if numberField.text?.characters.count == maximumNumberOfCharacters {
            expirationField.becomeFirstResponder()
        }
    }
    
    private func updateExpirationText(_ newText: String, isDeleting: Bool) {
        let maximumNumberOfCharacters = 5
        let (valid, formatted) = CardValidator.validate(expiryDate: newText, separator: isDeleting ? nil : "/")
        
        guard formatted.characters.count <= maximumNumberOfCharacters else {
            return
        }
        
        expirationField.valid = valid
        expirationField.text = formatted
        
        // If we have reached full length, make CVC first responder.
        if expirationField.text?.characters.count == maximumNumberOfCharacters {
            cvcField.becomeFirstResponder()
        }
    }
    
    private func updateCvcFieldText(_ newText: String) {
        let maximumNumberOfCharacters = 4
        let (valid, formatted) = CardValidator.validate(cvc: newText)
        
        guard formatted.characters.count <= maximumNumberOfCharacters else {
            return
        }
        
        cvcField.valid = !isCvcRequired || valid
        cvcField.text = formatted
        
        // If we have reached full length, dismiss keyboard.
        if cvcField.text?.characters.count == maximumNumberOfCharacters {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func checkFieldValidity() {
        let valid = (numberField.valid && expirationField.valid && cvcField.valid)
        delegate?.paymentFieldChangedValidity(valid)
    }
    
}
