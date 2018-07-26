//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class SEPADirectDebitFormViewController: FormViewController {
    internal var completion: Completion<Input>?
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.addFormElement(ibanField)
        formView.addFormElement(nameField)
        formView.addFooterElement(consentLabel)
        
        formView.payButton.addTarget(self, action: #selector(didSelect(payButton:)), for: .touchUpInside)
    }
    
    private lazy var ibanField: FormField = {
        let ibanField = FormField(textFieldClass: IBANTextField.self)
        ibanField.title = ADYLocalizedString("sepaDirectDebit.ibanField.title")
        ibanField.placeholder = ADYLocalizedString("sepaDirectDebit.ibanField.placeholder")
        ibanField.accessibilityIdentifier = "iban-field"
        ibanField.addTarget(self, action: #selector(updateValidity), for: .editingChanged)
        
        if let ibanTextField = ibanField.textField as? IBANTextField {
            ibanTextField.validTextColor = appearance.textAttributes[.foregroundColor] as? UIColor
            ibanTextField.invalidTextColor = appearance.formAttributes.invalidTextColor
        }
        
        return ibanField
    }()
    
    private lazy var nameField: FormField = {
        let nameField = FormField()
        nameField.title = ADYLocalizedString("sepaDirectDebit.nameField.title")
        nameField.placeholder = ADYLocalizedString("sepaDirectDebit.nameField.placeholder")
        nameField.textField.autocapitalizationType = .words
        nameField.textField.autocorrectionType = .no
        nameField.accessibilityIdentifier = "name-field"
        nameField.addTarget(self, action: #selector(updateValidity), for: .editingChanged)
        
        return nameField
    }()
    
    private lazy var consentLabel: UILabel = {
        let text = ADYLocalizedString("sepaDirectDebit.consentButton")
        let attributes = appearance.formAttributes.footerTitleAttributes
        
        let label = UILabel(frame: .zero)
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.accessibilityIdentifier = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    @objc private func didSelect(payButton: UIControl) {
        guard
            let iban = ibanField.text,
            let name = nameField.text
        else {
            return
        }
        
        let input = Input(name: name, iban: iban)
        completion?(input)
    }
    
    // MARK: - Validation
    
    private var isValid: Bool {
        guard let iban = ibanField.text, IBANValidator.isValid(iban) else {
            return false
        }
        
        guard let name = nameField.text, name.count > 0 else {
            return false
        }
        
        return true
    }
    
    @objc private func updateValidity() {
        formView.payButton.isEnabled = isValid
    }
    
    // MARK: - Loading
    
    internal var isLoading = false {
        didSet {
            if isLoading {
                setEditing(false, animated: true)
            }
            
            formView.payButton.showsActivityIndicator = isLoading
        }
    }
    
}

internal extension SEPADirectDebitFormViewController {
    internal struct Input {
        internal let name: String
        
        internal let iban: String
        
    }
    
}
