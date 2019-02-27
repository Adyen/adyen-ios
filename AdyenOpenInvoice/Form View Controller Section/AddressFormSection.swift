//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class AddressFormSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    enum AddressType {
        case delivery, billing
    }
    
    var address: OpenInvoiceAddress?
    
    init(address: OpenInvoiceAddress?, type: AddressType, countrySelectItems: [PaymentDetail.SelectItem], textFieldDelegate: FormTextFieldDelegate) {
        self.type = type
        self.address = address
        self.countrySelectItems = countrySelectItems
        self.textFieldDelegate = textFieldDelegate
        super.init()
        
        let localizedStringKey = type == .billing ? "openInvoice.billingAddressSection.title" : "openInvoice.shippingAddressSection.title"
        title = ADYLocalizedString(localizedStringKey)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(visibility: PaymentDetail.Configuration.FieldVisibility) {
        switch visibility {
        case .editable:
            isEditable = true
            addFormElement(streetField)
            addFormElement(houseNumberField)
            addFormElement(cityField)
            addFormElement(postalCodeField)
            addFormElement(countrySelectField)
            fillFields()
        case .readOnly:
            addFormElement(staticAddress)
            setAttributedStaticAddress()
        default: break
        }
    }
    
    func filledAddress() -> OpenInvoiceAddress? {
        if isEditable {
            address?.street = streetField.text
            address?.houseNumber = houseNumberField.text
            address?.city = cityField.text
            address?.postalCode = postalCodeField.text
            address?.country = countrySelectItems.filter({ $0.name == countrySelectField.selectedValue }).first?.identifier
        }
        return address
    }
    
    // MARK: - Private
    
    private var isEditable = false
    private var type: AddressType
    private var countrySelectItems: [PaymentDetail.SelectItem]
    private weak var textFieldDelegate: FormTextFieldDelegate?
    
    private lazy var staticAddress = FormLabel()
    
    private lazy var streetField: FormTextField = {
        let streetField = FormTextField()
        streetField.delegate = textFieldDelegate
        streetField.validator = OpenInvoiceNameValidator()
        streetField.title = ADYLocalizedString("openInvoice.streetField.title")
        streetField.placeholder = ADYLocalizedString("openInvoice.streetField.placeholder")
        streetField.accessibilityIdentifier = "street-field"
        streetField.autocapitalizationType = .words
        streetField.nextResponderInChain = houseNumberField
        
        return streetField
    }()
    
    private lazy var houseNumberField: FormTextField = {
        let houseNumberField = FormTextField()
        houseNumberField.delegate = textFieldDelegate
        houseNumberField.validator = OpenInvoiceNameValidator()
        houseNumberField.title = ADYLocalizedString("openInvoice.houseNumberField.title")
        houseNumberField.placeholder = ADYLocalizedString("openInvoice.houseNumberField.placeholder")
        houseNumberField.accessibilityIdentifier = "house-number-field"
        houseNumberField.autocapitalizationType = .words
        houseNumberField.nextResponderInChain = cityField
        
        return houseNumberField
    }()
    
    private lazy var cityField: FormTextField = {
        let cityField = FormTextField()
        cityField.delegate = textFieldDelegate
        cityField.validator = OpenInvoiceNameValidator()
        cityField.title = ADYLocalizedString("openInvoice.cityField.title")
        cityField.placeholder = ADYLocalizedString("openInvoice.cityField.placeholder")
        cityField.accessibilityIdentifier = "city-field"
        cityField.autocapitalizationType = .words
        cityField.nextResponderInChain = postalCodeField
        
        return cityField
    }()
    
    private lazy var postalCodeField: FormTextField = {
        let postalCodeField = FormTextField()
        postalCodeField.delegate = textFieldDelegate
        postalCodeField.validator = OpenInvoiceNameValidator()
        postalCodeField.title = ADYLocalizedString("openInvoice.postalCodeField.title")
        postalCodeField.placeholder = ADYLocalizedString("openInvoice.postalCodeField.placeholder")
        postalCodeField.accessibilityIdentifier = "postal-code-field"
        postalCodeField.autocapitalizationType = .words
        postalCodeField.nextResponderInChain = countrySelectField
        
        return postalCodeField
    }()
    
    private lazy var countrySelectField: FormSelectField = {
        let values = countrySelectItems.map({ $0.name })
        
        let selectField = FormSelectField(values: values)
        selectField.title = ADYLocalizedString("openInvoice.countryField.title")
        selectField.accessibilityIdentifier = "country-field"
        selectField.isEnabled = false
        
        return selectField
    }()
    
    private func setAttributedStaticAddress() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let attributedString = NSMutableAttributedString(string: address?.formatted() ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        staticAddress.attributedTitle = attributedString
    }
    
    private func fillFields() {
        if let address = address {
            streetField.text = address.street
            houseNumberField.text = address.houseNumber
            cityField.text = address.city
            postalCodeField.text = address.postalCode
            countrySelectField.selectedValue = countrySelectItems.filter({ $0.identifier == address.country }).first?.name
        }
    }
}
