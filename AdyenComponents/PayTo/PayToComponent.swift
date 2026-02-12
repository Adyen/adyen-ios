//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides PayTo flows for PayTo component.
public final class PayToComponent: PaymentComponent, PresentableComponent, AdyenObserver, PaymentAware, LoadingComponent {

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
    public var paymentMethod: PaymentMethod {
        payToPaymentMethod
    }

    private let payToPaymentMethod: PayToPaymentMethod

    internal lazy var itemsProvider: PayToItemsProviding = {
        PayToItemsProvider(
            style: configuration.style,
            localizationParameters: configuration.localizationParameters,
            scope: String(describing: self),
            presenter: .init(self)
        )
    }()

    /// The viewController for the component.
    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )

    /// This indicates that `viewController` expected to be presented modally,
    public var requiresModalPresentation: Bool = true

    // MARK: Component specific

    /// Currently selected PayId identifier
    private var selectedIdentifier: PayToPayIdentifier = .phone

    /// Represents the selected payTo flow for the payment component.
    /// Determines the specific payTo transaction process to follow.
    internal lazy var selectedPaymentOption: PayToPaymentOption = .payId(selectedIdentifier) {
        didSet {
            UIView.performWithoutAnimation {
                updateInterface()
            }
        }
    }

    /// Items on PayId segment that can be shown/hidden
    private lazy var payIdDynamicItems: [FormItem] = [
        payIdFlowTitleItem,
        identifierPickerItem,
        phoneNumberItem,
        emailInputItem,
        abnInputItem,
        organizationIdInputItem
    ]

    /// Items on BSB segment that can be shown/hidden
    private lazy var bsbDynamicItems: [FormItem] = [
        bsbInstructionTitleItem,
        accountNumberInputItem,
        bsbInputItem
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

    /// The payment flow selection title label item.
    internal lazy var flowSelectionTitleItem: FormLabelItem = {
        itemsProvider.createFlowSelectionTitleItem()
    }()

    /// The segment control item to choose the payTo flow.
    internal lazy var flowSelectionItem: FormSegmentedControlItem = {
        let item = itemsProvider.createFlowSelectionItem()
        item.selectionHandler = { [weak self] in
            self?.didChangeSegment($0)
        }
        return item
    }()

    /// The payId flow title label item.
    internal lazy var payIdFlowTitleItem: FormContainerItem<FormLabelItem> = {
        itemsProvider.createPayIdFlowTitleItem()
    }()

    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        itemsProvider.createPhoneNumberItem()
    }()

    /// The  account holder firstname text input item.
    internal lazy var firstNameInputItem: FormTextInputItem = {
        itemsProvider.createFirstNameInputItem()
    }()

    /// The  account holder lastname text input item.
    internal lazy var lastNameInputItem: FormTextInputItem = {
        itemsProvider.createLastNameInputItem()
    }()

    /// The identifier picker item.
    internal lazy var identifierPickerItem: FormStringPickerItem = {
        itemsProvider.createIdentifierPickerItem()
    }()

    /// The  account holder email text input item.
    internal lazy var emailInputItem: FormTextInputItem = {
        itemsProvider.createEmailInputItem()
    }()

    /// The  account holder abn text input item.
    internal lazy var abnInputItem: FormTextInputItem = {
        itemsProvider.createAbnInputItem()
    }()

    /// The  account holder organization ID text input item.
    internal lazy var organizationIdInputItem: FormTextInputItem = {
        itemsProvider.createOrganizationIdInputItem()
    }()

    /// The  payment instructions label item.
    internal lazy var bsbInstructionTitleItem: FormContainerItem<FormLabelItem> = {
        itemsProvider.createBsbInstructionTitleItem()
    }()

    /// The  bank account number text input item.
    internal lazy var accountNumberInputItem: FormTextInputItem = {
        itemsProvider.createAccountNumberInputItem()
    }()

    /// The  bank state branch input item.
    internal lazy var bsbInputItem: FormTextInputItem = {
        itemsProvider.createBsbInputItem()
    }()

    /// The continue button item.
    internal lazy var continueButtonItem: FormButtonItem = {
        let item = itemsProvider.createContinueButtonItem()
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
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

        observe(identifierPickerItem.publisher) { [weak self] newValue in
            self?.updatePayIdIdentifier(newValue.element.identifier)
        }

        updateInterface()

        return formViewController
    }()

    public func stopLoading() {
        continueButtonItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
}

extension PayToComponent: SubmittableComponent {

    public func submit() {
        didSelectContinueButton()
    }

    public func validate() -> Bool {
        formViewController.validate()
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

private extension PayToComponent {

    func didSelectContinueButton() {
        guard validate() else { return }

        startLoading()

        let details = PayToDetails(
            paymentMethod: payToPaymentMethod,
            accountIdentifier: selectedPaymentIdentifier(),
            shopperName: .init(
                firstName: firstNameInputItem.value,
                lastName: lastNameInputItem.value
            )
        )

        submit(
            data: PaymentComponentData(
                paymentMethodDetails: details,
                amount: payment?.amount,
                order: order
            )
        )
    }

    func startLoading() {
        continueButtonItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }

    func updatePayIdIdentifier(_ newValue: String) {
        guard let newIdentifier = PayToPayIdentifier(rawValue: newValue) else { return }
        selectedIdentifier = newIdentifier
        selectedPaymentOption = .payId(selectedIdentifier)
    }

    func didChangeSegment(_ index: Int) {

        formViewController.view.endEditing(true)
        switch index {
        case 0:
            selectedPaymentOption = .payId(selectedIdentifier)
        case 1:
            selectedPaymentOption = .BSB
        default:
            AdyenAssertion.assertionFailure(message: "Segment index out of range")
        }
    }

    /// The identifier for the payment data based on the
    /// selected payment option (e.g., email, phone number etc.).
    func selectedPaymentIdentifier() -> String {
        switch selectedPaymentOption {
        case let .payId(identifier):
            switch identifier {
            case .phone:
                // Insert hyphen between prefix and number to match PayTo backend format for accountIdentifier (e.g., +61-012345678)
                [phoneNumberItem.prefix, phoneNumberItem.value].joined(separator: "-")
            case .email:
                emailInputItem.value
            case .abn:
                abnInputItem.value
            case .organizationId:
                organizationIdInputItem.value
            }
        case .BSB:
            // bsb payment option requires combining both these values with a "-"
            [bsbInputItem.value, accountNumberInputItem.value].joined(separator: "-")
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

        formViewController.append(bsbInstructionTitleItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(bsbInputItem)
        formViewController.append(accountNumberInputItem)
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
        case let .payId(identifier):
            resetPayIdItemsVisibility()

            switch identifier {
            case .phone:
                phoneNumberItem.isHidden.wrappedValue = false
            case .email:
                emailInputItem.isHidden.wrappedValue = false
            case .abn:
                abnInputItem.isHidden.wrappedValue = false
            case .organizationId:
                organizationIdInputItem.isHidden.wrappedValue = false
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
            organizationIdInputItem
        ]
        payIdItemsToHide.forEach { $0.isHidden.wrappedValue = true }
        bsbDynamicItems.forEach { $0.isHidden.wrappedValue = true }

        identifierPickerItem.isHidden.wrappedValue = false
        payIdFlowTitleItem.isHidden.wrappedValue = false
    }
}
