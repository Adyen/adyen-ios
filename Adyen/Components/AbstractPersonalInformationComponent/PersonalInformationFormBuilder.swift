//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
internal protocol AnyPersonalInformationFormBuilder: Localizable {

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
internal class PersonalInformationFormBuilder: AnyPersonalInformationFormBuilder {

    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal func build(_ firstNameField: FirstNameElement) -> FormTextInputItem {
        let item = FormTextInputItem(style: firstNameField.style)
        item.title = ADYLocalizedString("adyen.firstName", localizationParameters)
        item.placeholder = ADYLocalizedString("adyen.firstName", localizationParameters)
        item.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        item.validationFailureMessage = nil
        item.autocapitalizationType = .words
        item.identifier = firstNameField.identifier
        return item
    }

    /// :nodoc:
    internal func build(_ lastNameField: LastNameElement) -> FormTextInputItem {
        let item = FormTextInputItem(style: lastNameField.style)
        item.title = ADYLocalizedString("adyen.lastName", localizationParameters)
        item.placeholder = ADYLocalizedString("adyen.lastName", localizationParameters)
        item.validator = LengthValidator(minimumLength: 1, maximumLength: 50)
        item.validationFailureMessage = nil
        item.keyboardType = .emailAddress
        item.identifier = lastNameField.identifier
        return item
    }

    /// :nodoc:
    internal func build(_ emailField: EmailElement) -> FormTextInputItem {
        let item = FormTextInputItem(style: emailField.style)
        item.title = ADYLocalizedString("adyen.emailItem.title", localizationParameters)
        item.placeholder = ADYLocalizedString("adyen.emailItem.placeHolder", localizationParameters)
        item.validator = EmailValidator()
        item.validationFailureMessage = ADYLocalizedString("adyen.emailItem.invalid", localizationParameters)
        item.keyboardType = .emailAddress
        item.identifier = emailField.identifier
        return item
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
