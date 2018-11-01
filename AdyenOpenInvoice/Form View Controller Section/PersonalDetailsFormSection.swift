//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class PersonalDetailsSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    var personalDetails: OpenInvoicePersonalDetails?
    
    init(personalDetails: OpenInvoicePersonalDetails?, genderSelectItems: [PaymentDetail.SelectItem]?, textFieldDelegate: FormTextFieldDelegate) {
        self.personalDetails = personalDetails
        self.textFieldDelegate = textFieldDelegate
        self.genderSelectItems = genderSelectItems
        super.init()
        
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
    
    func setupNormalFlow() {
        addFormElement(firstNameField)
        addFormElement(lastNameField)
        
        if genderSelectItems != nil {
            addFormElement(genderField)
        }
        
        addFormElement(dateOfBirthField)
        addFormElement(telephoneField)
    }
    
    func filledPersonalDetails() -> OpenInvoicePersonalDetails? {
        personalDetails?.telephoneNumber = telephoneField.text
        
        if isSSNFlow {
            personalDetails?.shopperEmail = emailField.text
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            personalDetails?.firstName = firstNameField.text
            personalDetails?.lastName = lastNameField.text
            personalDetails?.gender = genderSelectItems?.filter({ $0.name == genderField.selectedValue }).first?.identifier
            personalDetails?.dateOfBirth = dateFormatter.string(from: dateOfBirthField.date)
        }
        
        return personalDetails
    }
    
    // MARK: - Private
    
    private weak var textFieldDelegate: FormTextFieldDelegate?
    
    private var genderSelectItems: [PaymentDetail.SelectItem]?
    private var isSSNFlow = false
    
    private lazy var staticPersonalDetails = FormLabel()
    
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
        let values = genderSelectItems?.map({ $0.name })
        let selectField = FormSelectField(values: values ?? [])
        selectField.title = ADYLocalizedString("openInvoice.genderField")
        
        return selectField
    }()
    
    private lazy var dateOfBirthField: FormDateField = {
        let dateField = FormDateField()
        dateField.title = ADYLocalizedString("openInvoice.dateOfBirthField")
        
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
