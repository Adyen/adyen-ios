//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSDirectDebitItemsFactoryProtocol {
    func createHolderNameItem() -> FormTextInputItem
    func createNumberItem() -> FormTextInputItem
    func createSortCodeItem() -> FormTextInputItem
    func createEmailItem() -> FormTextInputItem
    func createContinueButton() -> FormButtonItem
    func createAmountTermsToggle() -> FormToggleItem
    func createLegalTermsToggle() -> FormToggleItem
}

internal struct BACSDirectDebitItemsFactory: BACSDirectDebitItemsFactoryProtocol {

    private enum Content {
        // TODO: - Fill with content
    }

    // MARK: - Properties

    private let styleProvider: FormComponentStyle
    private let scope: Any

    // MARK: - Initializers

    internal init(styleProvider: FormComponentStyle, scope: Any) {
        self.styleProvider = styleProvider
        self.scope = scope
    }

    // MARK: - BACSDirectDebitItemsFactoryProtocol

    internal func createHolderNameItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        textItem.title = "Bank account holder name"
        textItem.placeholder = "Bank account placeholder"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .words

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "holderNameItem")
        textItem.identifier = identifier
        return textItem
    }

    internal func createNumberItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        textItem.title = "Bank account number"
        textItem.placeholder = "Bank account number"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "accountNumberItem")
        textItem.identifier = identifier
        return textItem
    }

    internal func createSortCodeItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        textItem.title = "Sort code"
        textItem.placeholder = "Sort code"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "sortCodeItem")
        textItem.identifier = identifier
        return textItem
    }

    internal func createEmailItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        // TODO: - Replace with localized version
        textItem.title = "Email"
        textItem.placeholder = "Email"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "emailItem")
        textItem.identifier = identifier
        return textItem
    }

    internal func createContinueButton() -> FormButtonItem {
        let buttonItem = FormButtonItem(style: styleProvider.mainButtonItem)

        // TODO: - Replace with localized version
        buttonItem.title = "Continue"

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "continueButtonItem")
        buttonItem.identifier = identifier
        return buttonItem
    }

    internal func createAmountTermsToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        // TODO: - Replace with localized version
        toggleItem.title = "I agree that 20 will be deducted from my bank account"

        // TODO: - Set up identifier
        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "amountTermsToggleItem")
        toggleItem.identifier = identifier
        return toggleItem
    }

    internal func createLegalTermsToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        // TODO: - Replace with localized version
        toggleItem.title = "I confirm the account is in my name and I am the only signatory required  to authorize the Direct Debit on this account."

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "legalTermsToggleItem")
        toggleItem.identifier = identifier
        return toggleItem
    }
}
