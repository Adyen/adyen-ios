//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSItemsFactoryProtocol {
    func createHolderNameItem() -> FormTextInputItem
    func createBankAccountNumberItem() -> FormTextInputItem
    func createSortCodeItem() -> FormTextInputItem
    func createEmailItem() -> FormTextInputItem
    func createContinueButton() -> FormButtonItem
    func createPaymentButton() -> FormButtonItem
    func createAmountConsentToggle(amount: String?) -> FormToggleItem
    func createLegalConsentToggle() -> FormToggleItem
}

internal struct BACSItemsFactory: BACSItemsFactoryProtocol {

    private enum ViewIdentifier {
        static let holderNameItem = "holderNameItem"
        static let bankAccountNumberItem = "bankAccountNumberItem"
        static let sortCodeItem = "sortCodeItem"
        static let emailItem = "emailItem"
        static let continueButtonItem = "continueButtonItem"
        static let paymentButtonItem = "paymentButtonItem"
        static let amountTermsToggleItem = "amountConsentToggleItem"
        static let legalTermsToggleItem = "legalConsentToggleItem"
    }

    // MARK: - Properties

    private let styleProvider: FormComponentStyle
    private let localizationParameters: LocalizationParameters?
    private let scope: String

    // MARK: - Initializers

    internal init(styleProvider: FormComponentStyle,
                  localizationParameters: LocalizationParameters?,
                  scope: String) {
        self.styleProvider = styleProvider
        self.localizationParameters = localizationParameters
        self.scope = scope
    }

    // MARK: - BACSDirectDebitItemsFactoryProtocol

    internal func createHolderNameItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        let localizedTitle = localizedString(.bacsHolderNameFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)

        let localizedFailureMessage = localizedString(.bacsHolderNameFieldInvalidMessage, localizationParameters)
        textItem.validationFailureMessage = localizedFailureMessage

        textItem.autocapitalizationType = .words

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.holderNameItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createBankAccountNumberItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        let localizedTitle = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 8)
        textItem.formatter = NumericFormatter()

        let localizedFailureMessage = localizedString(.bacsBankAccountNumberFieldInvalidMessage, localizationParameters)
        textItem.validationFailureMessage = localizedFailureMessage

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.bankAccountNumberItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createSortCodeItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        let localizedTitle = localizedString(.bacsBankLocationIdFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 6)
        textItem.formatter = NumericFormatter()

        let localizedFailureMessage = localizedString(.bacsBankLocationIdFieldInvalidMessage, localizationParameters)
        textItem.validationFailureMessage = localizedFailureMessage

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.sortCodeItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createEmailItem() -> FormTextInputItem {
        let textItem = FormTextInputItem(style: styleProvider.textField)

        let localizedTitle = localizedString(.emailItemTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = EmailValidator()

        let localizedFailureMessage = localizedString(.emailItemInvalid, localizationParameters)
        textItem.validationFailureMessage = localizedFailureMessage

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .emailAddress

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.emailItem)
        textItem.identifier = identifier
        return textItem
    }

    internal func createContinueButton() -> FormButtonItem {
        let buttonItem = FormButtonItem(style: styleProvider.mainButtonItem)

        let localizedTitle = localizedString(.continueTitle, localizationParameters)
        buttonItem.title = localizedTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.continueButtonItem)
        buttonItem.identifier = identifier
        return buttonItem
    }

    internal func createPaymentButton() -> FormButtonItem {
        let buttonItem = FormButtonItem(style: styleProvider.mainButtonItem)

        let localizedTitle = localizedString(.bacsPaymentButtonTitle, localizationParameters)
        buttonItem.title = localizedTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.paymentButtonItem)
        buttonItem.identifier = identifier
        return buttonItem
    }

    internal func createAmountConsentToggle(amount: String?) -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        let localizedTitle: String?
        if let amount {
            localizedTitle = localizedString(.bacsSpecifiedAmountConsentToggleTitle, localizationParameters, amount)
        } else {
            localizedTitle = localizedString(.bacsAmountConsentToggleTitle, localizationParameters)
        }
        toggleItem.title = localizedTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.amountTermsToggleItem)
        toggleItem.identifier = identifier
        return toggleItem
    }

    internal func createLegalConsentToggle() -> FormToggleItem {
        let toggleItem = FormToggleItem(style: styleProvider.toggle)
        toggleItem.value = false

        let localizedTitle = localizedString(.bacsLegalConsentToggleTitle, localizationParameters)
        toggleItem.title = localizedTitle

        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope,
                                                     postfix: ViewIdentifier.legalTermsToggleItem)
        toggleItem.identifier = identifier
        return toggleItem
    }
}
