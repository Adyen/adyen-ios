//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSDirectDebitItemsFactoryProtocol {
    func createHolderNameItem() -> FormTextInputItem
    func createBankAccountNumberItem() -> FormTextInputItem
    func createSortCodeItem() -> FormTextInputItem
    func createEmailItem() -> FormTextInputItem
    func createContinueButton() -> FormButtonItem
    func createAmountTermsToggle() -> FormToggleItem
    func createLegalTermsToggle() -> FormToggleItem
}

internal struct BACSDirectDebitItemsFactory: BACSDirectDebitItemsFactoryProtocol {

    private enum ViewIdentifier {
        static let holderNameItem = "holderNameItem"
        static let bankAccountNumberItem = "bankAccountNumberItem"
        static let sortCodeItem = "sortCodeItem"
        static let emailItem = "emailItem"
        static let continueButtonItem = "continueButtonItem"
        static let amountTermsToggleItem = "amountTermsToggleItem"
        static let legalTermsToggleItem = "legalTermsToggleItem"
    }

    // MARK: - Properties

    private let styleProvider: FormComponentStyle
    private let localizationParameters: LocalizationParameters?
    private let scope: Any

    // MARK: - Initializers

    internal init(styleProvider: FormComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  scope: Any) {
        self.styleProvider = styleProvider
        self.localizationParameters = localizationParameters
        self.scope = scope
    }

    // MARK: - BACSDirectDebitItemsFactoryProtocol

    internal func createHolderNameItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        let localizedTitle = localizedString(.bacsHolderNameFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        // TODO: - Set up validator
        textItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .words

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.holderNameItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createBankAccountNumberItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        let localizedTitle = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        // TODO: - Set up validator
        textItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 8)
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.bankAccountNumberItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createSortCodeItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        let localizedTitle = localizedString(.bacsBankLocationIdFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        // TODO: - Set up validator
        textItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 6)
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.sortCodeItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createEmailItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        let localizedText = localizedString(.emailItemTitle, localizationParameters)
        textItem.title = localizedText
        textItem.placeholder = localizedText

        // TODO: - Set up validator
        textItem.validator = EmailValidator()
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .emailAddress

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.emailItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createContinueButton() -> FormButtonItem {
        let buttonItem = FormButtonItem(style: styleProvider.mainButtonItem)

        // TODO: - Replace with localized version
        let localizedText = localizedString(.continueTitle, localizationParameters)
        buttonItem.title = localizedText

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.continueButtonItem)
        buttonItem.identifier = identifier
        return buttonItem
    }

    internal func createAmountTermsToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        // TODO: - Replace with localized version
        let localizedText = localizedString(.bacsAmountTermsToggleTitle, localizationParameters)
        toggleItem.title = localizedText

        // TODO: - Set up identifier
        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.amountTermsToggleItem)
        toggleItem.identifier = identifier
        return toggleItem
    }

    internal func createLegalTermsToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        // TODO: - Replace with localized version
        let localizedText = localizedString(.bacsLegalTermsToggleTitle, localizationParameters)
        toggleItem.title = localizedText

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.legalTermsToggleItem)
        toggleItem.identifier = identifier
        return toggleItem
    }
}
