//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class SEPADirectDebitFormViewController: FormViewController {
    
    internal weak var delegate: SEPADirectDebitFormViewControllerDelegate?
    
    internal var formattedAmount: String? {
        didSet {
            var title = ""
            if let formattedAmount = formattedAmount {
                title = ADYLocalizedString("payButton.formatted", formattedAmount)
            }
            
            payButton.setTitle(title, for: .normal)
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.addArrangedSubview(ibanField)
        formView.addArrangedSubview(nameField)
        formView.addArrangedSubview(consentButton)
        footerView = payButton
    }
    
    private lazy var ibanField: FormTextField = {
        let ibanField = FormTextField(textFieldClass: IBANTextField.self)
        ibanField.title = ADYLocalizedString("sepaDirectDebit.ibanField.title")
        ibanField.placeholder = ADYLocalizedString("sepaDirectDebit.ibanField.placeholder")
        ibanField.autocapitalizationType = .allCharacters
        ibanField.autocorrectionType = .no
        ibanField.accessibilityIdentifier = "iban-field"
        ibanField.addTarget(self, action: #selector(updateValidity), for: .editingChanged)
        
        return ibanField
    }()
    
    private lazy var nameField: FormTextField = {
        let nameField = FormTextField()
        nameField.title = ADYLocalizedString("sepaDirectDebit.nameField.title")
        nameField.placeholder = ADYLocalizedString("sepaDirectDebit.nameField.placeholder")
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .no
        nameField.accessibilityIdentifier = "name-field"
        nameField.addTarget(self, action: #selector(updateValidity), for: .editingChanged)
        
        return nameField
    }()
    
    private lazy var consentButton: FormCheckmarkButton = {
        let consentButton = FormCheckmarkButton()
        consentButton.title = ADYLocalizedString("sepaDirectDebit.consentButton")
        consentButton.accessibilityIdentifier = "consent-button"
        consentButton.tintColor = AppearanceConfiguration.shared.tintColor
        consentButton.addTarget(self, action: #selector(updateValidity), for: .touchUpInside)
        
        return consentButton
    }()
    
    private lazy var payButton: UIButton = {
        let payButtonType = AppearanceConfiguration.shared.checkoutButtonType
        
        let payButton = payButtonType.init()
        payButton.isEnabled = false
        payButton.tintColor = AppearanceConfiguration.shared.tintColor
        payButton.accessibilityIdentifier = "pay-button"
        payButton.addTarget(self, action: #selector(didSelect(payButton:)), for: .touchUpInside)
        
        return payButton
    }()
    
    @objc private func didSelect(payButton: UIControl) {
        guard
            let iban = ibanField.text,
            let name = nameField.text
        else {
            return
        }
        
        delegate?.formViewController(self, didSubmitWithIBAN: iban, name: name)
    }
    
    // MARK: - Validation
    
    private var isValid: Bool {
        guard consentButton.isSelected else {
            return false
        }
        
        guard let iban = ibanField.text, IBANValidator.isValid(iban) else {
            return false
        }
        
        guard let name = nameField.text, name.characters.count > 0 else {
            return false
        }
        
        return true
    }
    
    @objc private func updateValidity() {
        payButton.isEnabled = isValid
    }
    
    // MARK: - Loading
    
    internal var isLoading = false {
        didSet {
            if isLoading {
                setEditing(false, animated: true)
            }
            
            payButton.showsActivityIndicator = isLoading
        }
    }
    
}
