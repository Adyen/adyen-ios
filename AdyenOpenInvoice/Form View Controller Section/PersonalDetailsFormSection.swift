//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class PersonalDetailsSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    var personalDetails: OpenInvoicePersonalDetails?
    
    init(personalDetails: OpenInvoicePersonalDetails?, genderSelectItems: [PaymentDetail.SelectItem]?, requiresDateOfBirth: Bool, textFieldDelegate: FormTextFieldDelegate) {
        self.personalDetails = personalDetails
        self.textFieldDelegate = textFieldDelegate
        self.genderSelectItems = genderSelectItems
        self.requiresDateOfBirth = requiresDateOfBirth
        super.init()
        
        let values = genderSelectItems?.map({ $0.name })
        localizedGenderValues = values?.map({ ADYLocalizedString("openInvoice.gender.\($0.lowercased())", $0) })
        
        title = ADYLocalizedString("openInvoice.personalDetailsSection.title")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSSNFlow() {
        isSSNFlow = true
        addFormElement(staticPersonalDetails)
        addFormElement(telephoneField)
        addFormElement(emailField)
        
        staticPersonalDetails.text = personalDetails?.fullName()
        telephoneField.text = personalDetails?.telephoneNumber
        emailField.text = personalDetails?.shopperEmail
    }
    
    func setupNormalFlow(shouldShowSSNField: Bool) {
        addFormElement(firstNameField)
        addFormElement(lastNameField)
        
        if genderSelectItems != nil {
            addFormElement(genderField)
        }
        
        if requiresDateOfBirth {
            addFormElement(dateOfBirthField)
        }
        
        addFormElement(telephoneField)
        addFormElement(emailField)
        
        if shouldShowSSNField {
            addFormElement(socialSecurityNumberField)
        }
        
        telephoneField.text = personalDetails?.telephoneNumber
        emailField.text = personalDetails?.shopperEmail
    }
    
    func filledPersonalDetails() -> OpenInvoicePersonalDetails? {
        personalDetails?.telephoneNumber = telephoneField.text
        personalDetails?.shopperEmail = emailField.text
        
        if isSSNFlow == false {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            personalDetails?.socialSecurityNumber = socialSecurityNumberField.text
            personalDetails?.firstName = firstNameField.text
            personalDetails?.lastName = lastNameField.text
            personalDetails?.dateOfBirth = dateFormatter.string(from: dateOfBirthField.date)
            
            if let selected = genderField.selectedValue, let index = localizedGenderValues?.firstIndex(of: selected) {
                personalDetails?.gender = genderSelectItems?[index].identifier
            }
        }
        
        return personalDetails
    }
    
    // MARK: - Private
    
    private weak var textFieldDelegate: FormTextFieldDelegate?
    
    private var genderSelectItems: [PaymentDetail.SelectItem]?
    private var isSSNFlow = false
    private var localizedGenderValues: [String]?
    private var requiresDateOfBirth: Bool
    
    private lazy var staticPersonalDetails = FormLabel()
    
    private lazy var socialSecurityNumberField: FormTextField = {
        let ssnField = FormTextField()
        ssnField.validator = OpenInvoiceNameValidator()
        ssnField.title = ADYLocalizedString("openInvoice.ssnSection.title")
        ssnField.placeholder = ADYLocalizedString("openInvoice.ssnSection.title")
        ssnField.accessibilityIdentifier = "social-security-number-field"
        ssnField.keyboardType = .numberPad
        ssnField.delegate = textFieldDelegate
        ssnField.clearButtonMode = .never
        return ssnField
    }()
    
    private lazy var firstNameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = textFieldDelegate
        nameField.validator = OpenInvoiceNameValidator()
        nameField.title = ADYLocalizedString("openInvoice.firstNameField.title")
        nameField.placeholder = ADYLocalizedString("openInvoice.firstNameField.placeholder")
        nameField.accessibilityIdentifier = "first-name-field"
        nameField.autocapitalizationType = .words
        nameField.nextResponderInChain = lastNameField
        
        return nameField
    }()
    
    private lazy var lastNameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = textFieldDelegate
        nameField.validator = OpenInvoiceNameValidator()
        nameField.title = ADYLocalizedString("openInvoice.lastNameField.title")
        nameField.placeholder = ADYLocalizedString("openInvoice.lastNameField.placeholder")
        nameField.accessibilityIdentifier = "last-name-field"
        nameField.autocapitalizationType = .words
        nameField.nextResponderInChain = genderField
        
        return nameField
    }()
    
    private lazy var genderField: FormSelectField = {
        let selectField = FormSelectField(values: localizedGenderValues ?? [])
        selectField.title = ADYLocalizedString("openInvoice.genderField")
        selectField.accessibilityIdentifier = "gender-field"
        
        return selectField
    }()
    
    private lazy var dateOfBirthField: FormDateField = {
        let dateField = FormDateField()
        dateField.title = ADYLocalizedString("openInvoice.dateOfBirthField")
        dateField.accessibilityIdentifier = "date-field"
        
        return dateField
    }()
    
    private lazy var telephoneField: FormTextField = {
        let phoneField = FormTextField()
        phoneField.delegate = textFieldDelegate
        phoneField.validator = OpenInvoiceTelephoneNumberValidator()
        phoneField.title = ADYLocalizedString("openInvoice.telephoneNumber.title")
        phoneField.placeholder = ADYLocalizedString("openInvoice.telephoneNumber.placeholder")
        phoneField.accessibilityIdentifier = "telephone-number-field"
        phoneField.keyboardType = .phonePad
        
        if isSSNFlow {
            phoneField.nextResponderInChain = emailField
        }
        
        return phoneField
    }()
    
    private lazy var emailField: FormTextField = {
        let emailField = FormTextField()
        emailField.delegate = textFieldDelegate
        emailField.validator = OpenInvoiceEmailValidator()
        emailField.title = ADYLocalizedString("openInvoice.email.title")
        emailField.placeholder = ADYLocalizedString("openInvoice.email.placeholder")
        emailField.accessibilityIdentifier = "email-field"
        emailField.keyboardType = .emailAddress
        
        return emailField
    }()
    
}
