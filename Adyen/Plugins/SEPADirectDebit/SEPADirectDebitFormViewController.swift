//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class SEPADirectDebitFormViewController: FormViewController {
    
    private let appearanceConfiguration: AppearanceConfiguration
    
    internal init(appearanceConfiguration: AppearanceConfiguration) {
        self.appearanceConfiguration = appearanceConfiguration
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal weak var delegate: SEPADirectDebitFormViewControllerDelegate?
    
    internal var formattedAmount: String? {
        didSet {
            if let formattedAmount = formattedAmount {
                payButton.title = ADYLocalizedString("payButton.formatted", formattedAmount)
            } else {
                payButton.title = nil
            }
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
        ibanField.addTarget(self, action: #selector(revalidate), for: .editingChanged)
        
        return ibanField
    }()
    
    private lazy var nameField: FormTextField = {
        let nameField = FormTextField()
        nameField.title = ADYLocalizedString("sepaDirectDebit.nameField.title")
        nameField.placeholder = ADYLocalizedString("sepaDirectDebit.nameField.placeholder")
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .no
        nameField.accessibilityIdentifier = "name-field"
        nameField.addTarget(self, action: #selector(revalidate), for: .editingChanged)
        
        return nameField
    }()
    
    private lazy var consentButton: FormCheckmarkButton = {
        let consentButton = FormCheckmarkButton()
        consentButton.title = ADYLocalizedString("sepaDirectDebit.consentButton")
        consentButton.accessibilityIdentifier = "consent-button"
        consentButton.tintColor = self.appearanceConfiguration.tintColor
        consentButton.addTarget(self, action: #selector(revalidate), for: .touchUpInside)
        
        return consentButton
    }()
    
    private lazy var payButton: CheckoutButton = {
        let payButton = CheckoutButton()
        payButton.isEnabled = false
        payButton.tintColor = self.appearanceConfiguration.tintColor
        payButton.accessibilityIdentifier = "pay-button"
        payButton.addTarget(self, action: #selector(didSelect(payButton:)), for: .touchUpInside)
        
        return payButton
    }()
    
    @objc private func didSelect(payButton: CheckoutButton) {
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
    
    @objc private func revalidate() {
        payButton.isEnabled = isValid
    }
    
    // MARK: - Loading
    
    internal var isLoading = false {
        didSet {
            if isLoading {
                setEditing(false, animated: true)
            }
            
            payButton.isLoading = isLoading
        }
    }
    
}
