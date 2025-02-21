//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides PayTo flows for PayTo component.
public final class PayToComponent: PaymentComponent,
    PresentableComponent, AdyenObserver {

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
    
    /// The payment options for PayTo component.
    /// PayId contains 4 inner selection options.
    private enum PaymentOption {
        
        /// Pay with PayId options (mobile, email etc)
        case payID(PayIDIdentifier)
        
        /// Pay with BSB
        case BSB
    }

    private enum PayIDIdentifier: String, CustomStringConvertible, CaseIterable {
        case phone
        case email
        case abn
        case organizationID

        // TODO: Add translation
        public var description: String {
            switch self {
            case .phone:
                return "Phone"
            case .email:
                return "Email"
            case .abn:
                return "ABN"
            case .organizationID:
                return "Organization ID"
            }
        }

    }

    /// Configuration for PayTo Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// Component's configuration
    public var configuration: Configuration

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { payToPaymentMethod }

    private let payToPaymentMethod: PayToPaymentMethod
    
    /// The viewController for the component.
    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )
    
    /// This indicates that `viewController` expected to be presented modally,
    public var requiresModalPresentation: Bool = true
    
    // MARK: Component specific
    
    /// Currently selected PayId identifier
    private var selectedIdentifier: PayIDIdentifier = .phone

    /// Represents the selected payTo flow for the payment component.
    /// Determines the specific payTo transaction process to follow.
    private lazy var selectedPaymentOption: PaymentOption = .payID(selectedIdentifier) {
        didSet {
            UIView.performWithoutAnimation {
                updateInterface()
            }
            
        }
    }
    
    private lazy var payIdDynamicItems: [FormItem] = [
        identifierPickerItem,
        phoneNumberItem,
        emailInputItem,
        abnInputItem,
        organizationIDInputItem
    ]
    
    private lazy var bsbDynamicItems: [FormItem] = [
        paymentInstructionTitleItem,
        accountNumberInputItem,
        bankStateBranchInputItem
    ]

    private var payToPhoneCodes: [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .payTo)
        return PhoneExtensionsRepository.get(with: query)
    }

    /// Initializes the PayTo  component.
    ///
    /// - Parameter paymentMethod: The PayTo payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: PayToPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.payToPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    /// The payment flow selection title  label item.
    internal lazy var flowSelectionTitleItem: FormLabelItem = {
        // TODO: Add translation
        let item = FormLabelItem(
            text: localizedString(LocalizationKey(key: "How would you like to use Payto?"), configuration.localizationParameters),
            style: configuration.style.textField.title
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.flowSelectionTitleItem
        )
        return item
    }()

    /// The segment control item to choose the payTo flow.
    internal lazy var flowSelectionItem: FormSegmentedControlItem = {
        // TODO: Add translation
        let item = FormSegmentedControlItem(
            items: ["PayID", "BSB"],
            style: configuration.style.segmentedControlStyle,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: ViewIdentifier.flowSelectionItem
            )
        )
        item.selectionHandler = { [weak self] in
            self?.didChangeSegment($0)
        }
        return item
    }()
    
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(
            phoneNumber: nil,
            selectableValues: payToPhoneCodes,
            style: configuration.style.textField,
            localizationParameters: configuration.localizationParameters,
            presenter: .init(self)
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.phoneNumberItem
        )
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Phone"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Mobile number"), configuration.localizationParameters)
        return item
    }()

    /// The continue button item.
    internal lazy var continueButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.continueButtonItem
        )
        item.title = localizedString(.continueTitle, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
        return item
    }()

    /// The  account holder firstname text input item.
    internal lazy var firstNameInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Account holder first name"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Account holder first name"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.firstNameInputItem
        )
        return item
    }()

    /// The  account holder lastname text input item.
    internal lazy var lastNameInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Account holder last name"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Account holder last name"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.lastNameInputItem
        )
        return item
    }()

    /// The identifier picker item.
    internal lazy var identifierPickerItem: FormContainerItem<FormStringPickerItem> = {
        let selectableValues = PayIDIdentifier.allCases.map { payIDIdentifier in
            FormStringPickerElement(
                identifier: payIDIdentifier.rawValue,
                title: payIDIdentifier.description
            )
        }

        AdyenAssertion.assert(message: "selectableValues should be greater than 0", condition: selectableValues.isEmpty)

        let item = FormStringPickerItem(
            preselectedStringValue: selectableValues[0],
            selectableStringValues: selectableValues,
            style: configuration.style.textField
        )
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Identifier"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.identifierPickerItem
        )
        // we return a container item to prevent the picker from becoming firstResponder
        return item.padding(.zero)
    }()

    /// The  account holder email text input item.
    internal lazy var emailInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(.emailItemTitle, configuration.localizationParameters)
        item.placeholder = localizedString(.emailItemPlaceHolder, configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.emailInputItem
        )
        return item
    }()

    /// The  account holder abn text input item.
    internal lazy var abnInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "ABN"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Australian Business Number"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.abnInputItem
        )
        return item
    }()

    /// The  account holder organization ID text input item.
    internal lazy var organizationIDInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Organization ID"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Organization ID number"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.organizationIDInputItem
        )
        return item
    }()

    /// The  payment instructions label item.
    internal lazy var paymentInstructionTitleItem: FormContainerItem<FormLabelItem> = {
        // TODO: Add translation
        let item = FormLabelItem(
            text: localizedString(LocalizationKey(key: "Enter the bank account number and the Bank State Branch that is connected to your account to continue"), configuration.localizationParameters),
            style: configuration.style.textField.title
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.paymentInstructionTitleItem
        )
        return item.padding()
    }()

    /// The  bank account number text input item.
    internal lazy var accountNumberInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(.bacsBankAccountNumberFieldTitle, configuration.localizationParameters)
        item.placeholder = localizedString(.bacsBankAccountNumberFieldTitle, configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.accountNumberInputItem
        )
        return item
    }()

    /// The  bank state branch input item.
    internal lazy var bankStateBranchInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Bank state branch"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Bank State Branch"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.bankStateBranchInputItem
        )
        return item
    }()

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.delegate = self
        
        addTopItems(to: formViewController)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        
        addDynamicItems(to: formViewController)
        addBottomItems(to: formViewController)

        // continue button last
        if configuration.showsSubmitButton {
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(continueButtonItem)
        }
        
        observe(identifierPickerItem.content.publisher) { [weak self] newValue in
            self?.updatePayIdIdentifier(newValue.element.identifier)
        }
        
        updateInterface()

        return formViewController
    }()

    // MARK: - Private
}

@_spi(AdyenInternal)
extension PayToComponent: ViewControllerDelegate {}

@_spi(AdyenInternal)
extension PayToComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension PayToComponent: ViewControllerPresenter {
    
    public func presentViewController(_ viewController: UIViewController, animated: Bool) {
        self.viewController.presentViewController(viewController, animated: animated)
    }
    
    public func dismissViewController(animated: Bool) {
        self.viewController.dismissViewController(animated: animated)
    }
}

// MARK: - Event Handling

private extension PayToComponent {

    func didSelectContinueButton() {
        // TODO: Implement
    }
    
    func updatePayIdIdentifier(_ newValue: String) {
        guard let newIdentifier = PayIDIdentifier(rawValue: newValue) else { return }
        selectedIdentifier = newIdentifier
        selectedPaymentOption = .payID(selectedIdentifier)
    }

    func didChangeSegment(_ index: Int) {
        
        formViewController.view.endEditing(true)
        switch index {
        case 0:
            selectedPaymentOption = .payID(selectedIdentifier)
        case 1:
            selectedPaymentOption = .BSB
        default:
            AdyenAssertion.assertionFailure(message: "Segment index out of range")
        }
    }

}

// MARK: - Private

private extension PayToComponent {
    
    func addTopItems(to formViewController: FormViewController) {
        let topItems: [FormItem] = [
            flowSelectionTitleItem.padding(),
            flowSelectionItem.padding()
        ]
        
        add(topItems, to: formViewController, spacing: 1)
    }
    
    func addDynamicItems(to formViewController: FormViewController) {
        add(
            payIdDynamicItems,
            to: formViewController,
            isHidden: true
        )
        
        formViewController.append(paymentInstructionTitleItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(accountNumberInputItem)
        formViewController.append(bankStateBranchInputItem)
        bsbDynamicItems.forEach { $0.isHidden.wrappedValue = true }
    }

    func addBottomItems(to formViewController: FormViewController) {
        let bottomItems: [FormItem] = [
            firstNameInputItem,
            lastNameInputItem
        ]
        
        add(bottomItems, to: formViewController)
    }

    func add(
        _ items: [FormItem],
        to formViewController: FormViewController,
        spacing: Int = 0,
        isHidden: Bool = false
    ) {
        items.forEach {
            if spacing > 0 {
                formViewController.append(FormSpacerItem(numberOfSpaces: spacing))
            }
            formViewController.append($0)
            $0.isHidden.wrappedValue = isHidden
        }
    }
    
    func updateInterface() {
        switch selectedPaymentOption {
        case let .payID(identifier):
            resetPayIdItemsVisibility()
            
            switch identifier {
            case .phone:
                phoneNumberItem.isHidden.wrappedValue = false
            case .email:
                emailInputItem.isHidden.wrappedValue = false
            case .abn:
                abnInputItem.isHidden.wrappedValue = false
            case .organizationID:
                organizationIDInputItem.isHidden.wrappedValue = false
            }
        case .BSB:
            payIdDynamicItems.forEach { $0.isHidden.wrappedValue = true }
            bsbDynamicItems.forEach { $0.isHidden.wrappedValue = false }
        }
    }
    
    func resetPayIdItemsVisibility() {
        let payIdItemsToHide: [FormItem] = [
            phoneNumberItem,
            emailInputItem,
            abnInputItem,
            organizationIDInputItem
        ]
        payIdItemsToHide.forEach { $0.isHidden.wrappedValue = true }
        bsbDynamicItems.forEach { $0.isHidden.wrappedValue = true }
        
        identifierPickerItem.isHidden.wrappedValue = false
    }
}
