//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol PayToItemsProviding {
    
    func createFlowSelectionTitleItem() -> FormLabelItem
    func createFlowSelectionItem() -> FormSegmentedControlItem
    func createPayIdFlowTitleItem() -> FormContainerItem<FormLabelItem>
    func createPhoneNumberItem() -> FormPhoneNumberItem
    func createFirstNameInputItem() -> FormTextInputItem
    func createLastNameInputItem() -> FormTextInputItem
    func createIdentifierPickerItem() -> FormStringPickerItem
    func createEmailInputItem() -> FormTextInputItem
    func createAbnInputItem() -> FormTextInputItem
    func createOrganizationIdInputItem() -> FormTextInputItem
    func createBsbInstructionTitleItem() -> FormContainerItem<FormLabelItem>
    func createAccountNumberInputItem() -> FormTextInputItem
    func createBsbInputItem() -> FormTextInputItem
    
    func createContinueButtonItem() -> FormButtonItem
}

internal class PayToItemsProvider: PayToItemsProviding {
    
    private enum ViewIdentifier {
        static let flowSelectionTitleItem = "flowSelectionTitleLabel"
        static let flowSelectionItem = "flowSelectionSegmentedControl"
        static let payIdFlowTitleItem = "payIdFlowTitleTitleLabel"
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
        static let phone = #"^[0-9]{1,29}$"#
        static let abn = #"^((\d{9})|(\d{11}))$"#
        static let organizationId = #"^[!-@\[-~][ -@\[-~]{0,254}[!-@\[-~]$"#
        static let bsb = #"^\d{6}$"#
        static let accountNumber = #"^[ -~]{1,28}$"#
    }
    
    private enum Constants {
        static let bsbDigitLength = 6
    }
    
    private var payToPhoneCodes: [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .payTo)
        return PhoneExtensionsRepository.get(with: query)
    }
    
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
    
    /// The payment flow selection title  label item.
    internal func createFlowSelectionTitleItem() -> FormLabelItem {
        let item = FormLabelItem(
            text: localizedString(.paytoModeSelection, localizationParameters),
            style: style.textField.text
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.flowSelectionTitleItem
        )
        return item
    }

    /// The segment control item to choose the payTo flow.
    internal func createFlowSelectionItem() -> FormSegmentedControlItem {
        FormSegmentedControlItem(
            items: ["PayID", "BSB"],
            style: style.segmentedControlStyle,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: scope,
                postfix: ViewIdentifier.flowSelectionItem
            )
        )
    }

    /// The payid flow title label item.
    internal func createPayIdFlowTitleItem() -> FormContainerItem<FormLabelItem> {
        let item = FormLabelItem(
            text: localizedString(.paytoPayidDescription, localizationParameters),
            style: style.textField.text
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.payIdFlowTitleItem
        )
        return item.padding()
    }

    /// The  phone number form text item.
    internal func createPhoneNumberItem() -> FormPhoneNumberItem {
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
        item.validator = RegularExpressionValidator(regularExpression: ValidationRegex.phone)
        item.title = localizedString(.paytoPayidPhoneHint, localizationParameters)
        item.placeholder = localizedString(.mobileNumber, localizationParameters)
        return item
    }

    /// The  account holder firstname text input item.
    internal func createFirstNameInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.paytoLabelFirstName, localizationParameters)
        item.placeholder = localizedString(.paytoLabelFirstName, localizationParameters)
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(.paytoFirstNameInvalid, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.firstNameInputItem
        )
        return item
    }

    /// The  account holder lastname text input item.
    internal func createLastNameInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.paytoLabelLastName, localizationParameters)
        item.placeholder = localizedString(.paytoLabelLastName, localizationParameters)
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(.paytoLastNameInvalid, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.lastNameInputItem
        )
        return item
    }

    /// The identifier picker item.
    internal func createIdentifierPickerItem() -> FormStringPickerItem {
        let selectableValues = PayToPayIdentifier.allCases.map { identifier in
            FormStringPickerElement(
                identifier: identifier.rawValue,
                title: localizedString(identifier.localizedKey, localizationParameters)
            )
        }

        AdyenAssertion.assert(message: "selectableValues should be greater than 0", condition: selectableValues.isEmpty)

        let item = PayToIdentifierItem(
            preselectedStringValue: selectableValues[0],
            selectableStringValues: selectableValues,
            style: style.textField
        )
        item.title = localizedString(.paytoPayidLabelIdentifier, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.identifierPickerItem
        )
        
        return item
    }

    /// The  account holder email text input item.
    internal func createEmailInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.emailItemTitle, localizationParameters)
        item.placeholder = localizedString(.emailItemPlaceHolder, localizationParameters)
        item.validator = EmailValidator()
        item.validationFailureMessage = localizedString(.paytoPayidEmailInvalid, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.emailInputItem
        )
        return item
    }

    /// The  account holder abn text input item.
    internal func createAbnInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(LocalizationKey(key: "ABN"), localizationParameters)
        item.placeholder = localizedString(.paytoPayidAbnHint, localizationParameters)
        item.formatter = NumericFormatter()
        item.validator = RegularExpressionValidator(regularExpression: ValidationRegex.abn)
        item.validationFailureMessage = localizedString(.paytoPayidAbnInvalid, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.abnInputItem
        )
        return item
    }

    /// The  account holder organization ID text input item.
    internal func createOrganizationIdInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.paytoPayidLabelOrgid, localizationParameters)
        item.placeholder = localizedString(.paytoPayidOrgidHint, localizationParameters)
        item.validator = RegularExpressionValidator(
            regularExpression: ValidationRegex.organizationId,
            minimumLength: 2
        )
        item.validationFailureMessage = localizedString(.paytoPayidOrgidInvalid, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.organizationIDInputItem
        )
        return item
    }

    /// The  payment instructions label item.
    internal func createBsbInstructionTitleItem() -> FormContainerItem<FormLabelItem> {
        let item = FormLabelItem(
            text: localizedString(
                .paytoBsbDescription,
                localizationParameters
            ),
            style: style.textField.text
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.paymentInstructionTitleItem
        )
        return item.padding()
    }

    /// The  bank account number text input item.
    internal func createAccountNumberInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        item.placeholder = localizedString(.bacsBankAccountNumberFieldTitle, localizationParameters)
        item.validator = RegularExpressionValidator(regularExpression: ValidationRegex.accountNumber)
        item.validationFailureMessage = localizedString(.paytoBsbBankAccountNumberInvalid, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.accountNumberInputItem
        )
        return item
    }

    /// The  bank state branch input item.
    internal func createBsbInputItem() -> FormTextInputItem {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.paytoBsbBankStateBranchHint, localizationParameters)
        item.placeholder = localizedString(.paytoBsbBankStateBranchHint, localizationParameters)
        item.validator = RegularExpressionValidator(
            regularExpression: ValidationRegex.bsb,
            minimumLength: Constants.bsbDigitLength,
            maximumLength: Constants.bsbDigitLength
        )
        item.validationFailureMessage = localizedString(.paytoBsbBankStateBranchInvalid, localizationParameters)
        item.formatter = NumericFormatter()
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.bankStateBranchInputItem
        )
        return item
    }
    
    /// The continue button item.
    internal func createContinueButtonItem() -> FormButtonItem {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: scope,
            postfix: ViewIdentifier.continueButtonItem
        )
        item.title = localizedString(.continueTitle, localizationParameters)
        return item
    }
    
}
