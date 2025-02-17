//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides PayTo flows for PayTo component.
public final class PayToComponent: PaymentComponent,
    PresentableComponent {

    private enum ViewIdentifier {
        static let flowSelectionTitleLabelItem = "flowSelectionTitleLabel"
        static let flowSelectionItem = "flowSelectionSegmentedControl"
        static let phoneNumberItem = "phoneNumberItem"
        static let continueButtonItem = "continueButton"
        static let identifierPickerItem = "identifierPicker"
        static let firstNameInputItem = "firstNameTextfield"
        static let lastNameInputItem = "lastNameTextfield"
        static let emailInputItem = "emailTextfield"
        static let abnInputItem = "abnTextfield"
        static let organizationIDInputItem = "organizationIDTextfield"
    }

    private enum AccountIdentifiers: String, CustomStringConvertible, CaseIterable {
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
    
    private var payToExtensions: [PhoneExtension] {
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
    internal lazy var flowSelectionTitleLabelItem: FormLabelItem = {
        // TODO: Add translation
        let item = FormLabelItem(
            text: localizedString(LocalizationKey(key: "How would you like to use Payto?"), configuration.localizationParameters),
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.flowSelectionTitleLabelItem
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
        return item
    }()
    
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(
            phoneNumber: nil,
            selectableValues: payToExtensions,
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
    internal lazy var identifierPickerItem: FormStringPickerItem = {
        let selectableValues = AccountIdentifiers.allCases.map { accountIdentifier in
            FormStringPickerElement(identifier: accountIdentifier.rawValue, title: accountIdentifier.description)
        }

        AdyenAssertion.assert(message: "selectableValues should be greater than 0", condition: selectableValues.count <= 0)

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
        return item
    }()

    /// The  account holder email text input item.
    internal lazy var emailInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add translation
        item.title = localizedString(LocalizationKey(key: "Email"), configuration.localizationParameters)
        item.placeholder = localizedString(LocalizationKey(key: "Email"), configuration.localizationParameters)
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
        item.placeholder = localizedString(LocalizationKey(key: "ABN"), configuration.localizationParameters)
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
        item.placeholder = localizedString(LocalizationKey(key: "Organization ID"), configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.organizationIDInputItem
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
        
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))

        formViewController.append(flowSelectionTitleLabelItem.padding())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))

        formViewController.append(flowSelectionItem.padding())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))

        formViewController.append(identifierPickerItem.padding())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))

        formViewController.append(phoneNumberItem)

        appendItemsTo(formVC: formViewController)

        if configuration.showsSubmitButton {
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(continueButtonItem)
        }

        return formViewController
    }()

    // MARK: - Private

    private func appendItemsTo(formVC: FormViewController) {
        dynamicContent(formVC)
        staticContent(formVC)
    }

    private func staticContent(_ formVC: FormViewController) {
        formVC.append(firstNameInputItem)
        formVC.append(lastNameInputItem)
    }

    private func dynamicContent(_ formVC: FormViewController) {
        // TODO: Add bussiness logic to show/hide these
        formVC.append(emailInputItem)
        formVC.append(abnInputItem)
        formVC.append(organizationIDInputItem)
    }
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

extension PayToComponent {

    private func didSelectContinueButton() {
        // TODO: Implement
    }

}
