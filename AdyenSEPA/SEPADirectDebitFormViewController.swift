//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class SEPADirectDebitFormViewController: FormViewController {
    
    // MARK: - FormViewController
    
    override func pay() {
        guard let iban = ibanField.validatedValue, let name = nameField.validatedValue else {
            return
        }
        
        super.pay()
        
        let input = Input(name: name, iban: iban)
        completion?(input)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.addFormElement(ibanField)
        formView.addFormElement(nameField)
        formView.addFooterElement(consentLabel)
        
        dynamicTypeController.observeDynamicType(for: consentLabel, withTextAttributes: appearance.formAttributes.footerTitleAttributes, textStyle: .body)
    }
    
    // MARK: - Internal
    
    internal struct Input {
        internal let name: String
        internal let iban: String
    }
    
    internal var completion: Completion<Input>?
    
    // MARK: - Private
    
    private lazy var ibanField: FormTextField = {
        let ibanField = FormTextField()
        ibanField.delegate = self
        ibanField.autocapitalizationType = .allCharacters
        ibanField.title = ADYLocalizedString("sepaDirectDebit.ibanField.title")
        ibanField.placeholder = ADYLocalizedString("sepaDirectDebit.ibanField.placeholder")
        ibanField.accessibilityIdentifier = "iban-field"
        ibanField.nextResponderInChain = nameField
        ibanField.validator = IBANValidator()
        return ibanField
    }()
    
    private lazy var nameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = self
        nameField.title = ADYLocalizedString("sepaDirectDebit.nameField.title")
        nameField.placeholder = ADYLocalizedString("sepaDirectDebit.nameField.placeholder")
        nameField.autocapitalizationType = .words
        nameField.accessibilityIdentifier = "name-field"
        return nameField
    }()
    
    private lazy var consentLabel: UILabel = {
        let text = ADYLocalizedString("sepaDirectDebit.consentLabel")
        let attributes = appearance.formAttributes.footerTitleAttributes
        
        let label = UILabel(frame: .zero)
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.accessibilityIdentifier = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    private let dynamicTypeController = DynamicTypeController()
    
    private func updateValidity() {
        if let name = nameField.validatedValue, name.count > 0, ibanField.validatedValue != nil {
            isValid = true
        } else {
            isValid = false
        }
    }
    
}

extension SEPADirectDebitFormViewController: FormTextFieldDelegate {
    
    func valueChanged(_ formTextField: FormTextField) {
        updateValidity()
    }
    
}
