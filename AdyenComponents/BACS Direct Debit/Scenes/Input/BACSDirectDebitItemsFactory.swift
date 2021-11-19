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

    private enum Content {
        // TODO: - Fill with content
        static let holderNameItemTitle = "Bank account holder name"
        static let bankAccountNumberItemTitle = "Bank account number"
        static let sortCodeItemTitle = "Sort code"
        static let emailItemTitle = "Email"
        static let continueButtonItemTitle = "Continue"
        static let amountTermsToggleItemTitle = "I agree that 20 will be deducted from my bank account"
        static let legalTermsToggleItemTitle = "I confirm the account is in my name and I am the only signatory required  to authorize the Direct Debit on this account."
    }

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
        textItem.title = Content.holderNameItemTitle
        textItem.placeholder = Content.holderNameItemTitle

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
        textItem.title = Content.bankAccountNumberItemTitle
        textItem.placeholder = Content.bankAccountNumberItemTitle

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
        textItem.title = Content.sortCodeItemTitle
        textItem.placeholder = Content.sortCodeItemTitle

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
        textItem.title = Content.emailItemTitle
        textItem.placeholder = Content.emailItemTitle

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
        buttonItem.title = Content.continueButtonItemTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.continueButtonItem)
        buttonItem.identifier = identifier
        return buttonItem
    }

    internal func createAmountTermsToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        // TODO: - Replace with localized version
        toggleItem.title = Content.amountTermsToggleItemTitle

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
        toggleItem.title = Content.legalTermsToggleItemTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.legalTermsToggleItem)
        toggleItem.identifier = identifier
        return toggleItem
    }
}
