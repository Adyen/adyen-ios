//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
internal protocol AnyFormBuilder: Localizable {

    /// :nodoc:
    func build(_ firstNameField: FirstNameElement) -> FormTextInputItem

    /// :nodoc:
    func build(_ lastNameField: LastNameElement) -> FormTextInputItem

    /// :nodoc:
    func build(_ emailField: EmailElement) -> FormTextInputItem

    /// :nodoc:
    func build(_ phoneField: PhoneElement) -> FormPhoneNumberItem
}

/// :nodoc:
internal struct BaseFormBuilder: AnyFormBuilder {

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal func build(_ firstNameField: FirstNameElement) -> FormTextInputItem {
        let nameItem = FormTextInputItem(style: firstNameField.style)
        nameItem.title = ADYLocalizedString("First Name", localizationParameters)
        nameItem.placeholder = ADYLocalizedString("First Name", localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        nameItem.validationFailureMessage = ADYLocalizedString("Please enter first name with maximum 50 characters", localizationParameters)
        nameItem.autocapitalizationType = .words
        nameItem.identifier = firstNameField.identifier
        return nameItem
    }

    /// :nodoc:
    internal func build(_ lastNameField: LastNameElement) -> FormTextInputItem {
        let nameItem = FormTextInputItem(style: lastNameField.style)
        nameItem.title = ADYLocalizedString("Last Name", localizationParameters)
        nameItem.placeholder = ADYLocalizedString("Last Name", localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        nameItem.validationFailureMessage = ADYLocalizedString("Please enter last name with maximum 50 characters", localizationParameters)
        nameItem.keyboardType = .emailAddress
        nameItem.identifier = lastNameField.identifier
        return nameItem
    }

    /// :nodoc:
    internal func build(_ emailField: EmailElement) -> FormTextInputItem {
        let nameItem = FormTextInputItem(style: emailField.style)
        nameItem.title = ADYLocalizedString("adyen.emailItem.title", localizationParameters)
        nameItem.placeholder = ADYLocalizedString("j.smith@domain.com", localizationParameters)
        nameItem.validator = EmailValidator()
        nameItem.validationFailureMessage = ADYLocalizedString("adyen.emailItem.invalid", localizationParameters)
        nameItem.keyboardType = .emailAddress
        nameItem.identifier = emailField.identifier
        return nameItem
    }

    /// :nodoc:
    internal func build(_ phoneField: PhoneElement) -> FormPhoneNumberItem {
        let item = FormPhoneNumberItem(selectableValues: phoneField.phoneExtensions,
                                       style: phoneField.style,
                                       localizationParameters: localizationParameters)
        item.identifier = phoneField.identifier
        return item
    }

}
