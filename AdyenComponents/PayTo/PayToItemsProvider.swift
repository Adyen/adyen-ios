//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol PayToItemsProviding {
    
    var flowSelectionTitleItem: FormLabelItem { get }
    var flowSelectionItem: FormSegmentedControlItem { get }
    var phoneNumberItem: FormPhoneNumberItem { get }
    var firstNameInputItem: FormTextInputItem { get }
    var lastNameInputItem: FormTextInputItem { get }
    var identifierPickerItem: FormStringPickerItem { get }
    var emailInputItem: FormTextInputItem { get }
    var abnInputItem: FormTextInputItem { get }
    var organizationIdInputItem: FormTextInputItem { get }
    var bsbInstructionTitleItem: FormContainerItem<FormLabelItem> { get }
    var accountNumberInputItem: FormTextInputItem { get }
    var bsbInputItem: FormTextInputItem { get }
    
    var continueButtonItem: FormButtonItem { get }
}

internal class PayToItemsProvider: PayToItemsProviding {
    
    private enum ViewIdentifier {
        static let flowSelectionTitleItem = "flowSelectionTitleLabel"
        static let flowSelectionItem = "flowSelectionSegmentedControl"
        static let phoneNumberItem = "phoneNumberItem"
        static let continueButtonItem = "continueButton"
        static let identifierPickerItem = "identifierPicker"
        static let firstNameInputItem = "firstNameTextfield"
        static let lastNameInputItem = "lastNameTextfield"
        static let emailInputItem = "emailTextfield"
        static let abnInputItem = "abnTextfield"
        static let organizationIDInputItem = "organizationIDTextfield"
        static let accountNumberInputItem = "accountNumberTextfield"
        static let bankStateBranchInputItem = "bankStateBranchTextfield"
        static let paymentInstructionTitleItem = "paymentInstructionTitleLabel"
    }
    
    private enum ValidationRegex {
        static let phone = #"^\+[0-9]{1,3}-[1-9]{1,1}[0-9]{1,29}$"#
        static let abn = #"^((\d{9})|(\d{11}))$"#
        static let organizationId = #"^[!-@\[-~][ -@\[-~]{0,254}[!-@\[-~]$"#
        static let bsb = #"^\d{6}"#
        static let accountNumber = #"^\[ -~]{1,28}$"#
    }
    
    private var payToPhoneCodes: [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .payTo)
        return PhoneExtensionsRepository.get(with: query)
    }
    
    /// The payment flow selection title  label item.
    internal lazy var flowSelectionTitleItem: FormLabelItem = {
        // TODO: Add translation
        let item = FormLabelItem(
            text: localizedString(LocalizationKey(key: "How would you like to use Payto?"), localizationParameters),
            style: style.textField.text
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.flowSelectionTitleItem
        )
        return item
    }()

    /// The segment control item to choose the payTo flow.
    internal lazy var flowSelectionItem: FormSegmentedControlItem = {
        // TODO: Add translation
        let item = FormSegmentedControlItem(
            items: ["PayID", "BSB"],
            style: style.segmentedControlStyle,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: scope,
                postfix: ViewIdentifier.flowSelectionItem
            )
        )
        return item
    }()
    
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(
            phoneNumber: nil,
            selectableValues: payToPhoneCodes,
            style: style.textField,
            localizationParameters: localizationParameters,
            presenter: presenter
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.phoneNumberItem
        )
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Phone"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Mobile number"), localizationParameters)
        return item
    }()

    /// The  account holder firstname text input item.
    internal lazy var firstNameInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Account holder first name"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Account holder first name"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.firstNameInputItem
        )
        return item
    }()

    /// The  account holder lastname text input item.
    internal lazy var lastNameInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Account holder last name"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Account holder last name"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.lastNameInputItem
        )
        return item
    }()

    /// The identifier picker item.
    internal lazy var identifierPickerItem: FormStringPickerItem = {
        let selectableValues = PayToPayIdentifier.allCases.map { identifier in
            FormStringPickerElement(
                identifier: identifier.rawValue,
                title: identifier.description
            )
        }

        AdyenAssertion.assert(message: "selectableValues should be greater than 0", condition: selectableValues.isEmpty)

        let item = FormStringPickerItem(
            preselectedStringValue: selectableValues[0],
            selectableStringValues: selectableValues,
            style: style.textField
        )
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Identifier"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.identifierPickerItem
        )
        
        return item
    }()

    /// The  account holder email text input item.
    internal lazy var emailInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(.emailItemTitle, localizationParameters)
        item.placeholder = localizedString(.emailItemPlaceHolder, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.emailInputItem
        )
        return item
    }()

    /// The  account holder abn text input item.
    internal lazy var abnInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "ABN"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Australian Business Number"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.abnInputItem
        )
        return item
    }()

    /// The  account holder organization ID text input item.
    internal lazy var organizationIdInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Organization ID"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Organization ID number"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.organizationIDInputItem
        )
        return item
    }()

    /// The  payment instructions label item.
    internal lazy var bsbInstructionTitleItem: FormContainerItem<FormLabelItem> = {
        // TODO: Add translation
        let item = FormLabelItem(
            text: localizedString(
                LocalizationKey(key: "Enter the bank account number and the Bank State Branch that is connected to your account to continue"),
                localizationParameters
            ),
            style: style.textField.text
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.paymentInstructionTitleItem
        )
        return item.padding()
    }()

    /// The  bank account number text input item.
    internal lazy var accountNumberInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        item.placeholder = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.accountNumberInputItem
        )
        return item
    }()

    /// The  bank state branch input item.
    internal lazy var bsbInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Bank state branch"), localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Bank State Branch"), localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.bankStateBranchInputItem
        )
        return item
    }()
    
    /// The continue button item.
    internal lazy var continueButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.continueButtonItem
        )
        item.title = localizedString(.continueTitle, localizationParameters)
        return item
    }()
    
    private let style: FormComponentStyle
    private let localizationParameters: LocalizationParameters?
    private let scope: String
    private let presenter: WeakReferenceViewControllerPresenter
    
    internal init(
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters?,
        scope: String,
        presenter: WeakReferenceViewControllerPresenter
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.scope = scope
        self.presenter = presenter
    }
    
}
