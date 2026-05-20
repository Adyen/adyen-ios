//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides a upi flows for UPI component.
public final class UPIComponent: PaymentComponent,
    PresentableComponent,
    PaymentAware,
    LoadingComponent {

    // MARK: - Constants

    private enum ViewIdentifier {
        static let instructionsItem = "instructionsLabelItem"
        static let upiFlowSelectionItem = "upiFlowSelectionSegmentedControlItem"
        static let appsListTitleItem = "appsListTitleItem"
        static let continueButtonItem = "continueButton"
        static let errorItem = "errorItem"
        static let vpaInputTitleItem = "vpaInputTitleItem"
        static let virtualPaymentAddressInputItem = "virtualPaymentAddressInputItem"
    }

    internal enum Images {
        internal static let errorIcon = "error"
    }

    // MARK: - Properties

    /// Configuration for UPI Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod {
        upiPaymentMethod
    }

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The view controller for the component.
    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )

    /// This indicates that `viewController` expected to be presented modally,
    public var requiresModalPresentation: Bool = true

    /// Component's configuration
    public var configuration: Configuration

    private let upiPaymentMethod: UPIPaymentMethod

    internal private(set) var currentSelectedItemIdentifier: String?

    internal let urlSchemeChecker: URLSchemeChecking

    internal private(set) lazy var installedUPIApps: [Issuer] = {
        upiApps.filter { isAppInstalled(scheme: $0.appIdentifier?.scheme) }
    }()

    /// If no UPI apps are installed, shows all apps from the payment method response.
    internal private(set) lazy var availableUPIApps: [Issuer] = {
        installedUPIApps.isEmpty ? upiApps : installedUPIApps
    }()

    /// Represents the selected UPI (Unified Payments Interface) flow for the payment component.
    /// Determines the specific UPI transaction process to follow.
    @AdyenObservable(.upiIntent) public private(set) var selectedUPIFlow: UPIFlowType

    // MARK: - Initialization

    /// Initializes the UPI  component.
    ///
    /// - Parameter paymentMethod: The UPI payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: UPIPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.upiPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.urlSchemeChecker = DefaultURLSchemeChecker()

        selectedUPIFlow = upiAppsList.isEmpty ? .upiCollect : .upiIntent
    }

    /// Internal initializer for testing purposes.
    internal init(
        paymentMethod: UPIPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init(),
        urlSchemeChecker: URLSchemeChecking
    ) {
        self.upiPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.urlSchemeChecker = urlSchemeChecker

        selectedUPIFlow = upiAppsList.isEmpty ? .upiCollect : .upiIntent
    }

    // MARK: - LoadingComponent

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Form Items

    /// The upi based payment instructions label item.
    internal lazy var modeInstructionsLabelItem: FormLabelItem = {
        let item = FormLabelItem(
            text: localizedString(
                .upiModeSelection,
                configuration.localizationParameters
            ),
            style: configuration.style.footnoteLabel
        )
        item.style.color = .Adyen.componentLabel
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.instructionsItem
        )
        return item
    }()

    /// The UPI selection segmented control item to choose the upi flow.
    internal lazy var upiFlowSelectionItem: FormSegmentedControlItem = {
        let item = FormSegmentedControlItem(
            items: [
                firstSegmentTitle,
                localizedString(
                    .upiModeEnterUpiId,
                    configuration.localizationParameters
                )
            ],
            style: configuration.style.segmentedControlStyle,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: ViewIdentifier.upiFlowSelectionItem
            )
        )
        item.selectionHandler = { [weak self] in
            self?.didChangeSegmentedControlIndex($0)
        }
        return item
    }()

    /// The  collect UPI instructions label item.
    internal lazy var collectInstructionsLabelItem: FormContainerItem<FormLabelItem> = {
        let item = FormLabelItem(
            text: localizedString(
                .upiCollectInstruction,
                configuration.localizationParameters
            ),
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.vpaInputTitleItem
        )
        return item.padding()
    }()

    /// The  virtual payment address text input item (collect).
    internal lazy var vpaInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        item.title = localizedString(
            .upiCollectFieldLabel,
            configuration.localizationParameters
        )
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(
            .upiCollectFieldInvalidIdError,
            configuration.localizationParameters
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.virtualPaymentAddressInputItem
        )
        return item
    }()

    /// The  intent UPI instructions label item.
    internal lazy var intentInstructionsLabelItem: FormContainerItem<FormLabelItem> = {
        let item = FormLabelItem(
            text: localizedString(
                .upiIntentInstruction,
                configuration.localizationParameters
            ),
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.vpaInputTitleItem
        )
        return item.padding()
    }()

    /// The UPI apps list title item.
    internal lazy var appsListTitleItem: FormContainerItem<FormLabelItem> = {
        let titleKey: LocalizationKey = installedUPIApps.isEmpty
            ? .upiIntentAppsTitle
            : .upiIntentAppsTitleOnDevice

        let title = localizedString(titleKey, configuration.localizationParameters)
        let item = FormLabelItem(
            text: title,
            style: configuration.style.sectionHeader
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.appsListTitleItem
        )
        return item.padding()
    }()

    /// The UPI apps list item.
    internal lazy var upiAppsList: [SelectableFormItem] = {
        availableUPIApps.map { selectableFormItem(from: $0) }
    }()

    /// The continue button item.
    internal lazy var continueButton: FormButtonItem = {
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

    internal lazy var errorItem: FormErrorItem = {
        let errorMessage = localizedString(LocalizationKey.upiErrorNoAppSelected, configuration.localizationParameters)
        let item = FormErrorItem(message: errorMessage, iconName: Images.errorIcon)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.errorItem
        )
        item.isHidden.wrappedValue = true
        return item
    }()

    // MARK: - Private

    private func selectableFormItem(from app: Issuer) -> SelectableFormItem {
        let logoUrl = LogoURLProvider.logoURL(
            withName: "upi/\(app.identifier)",
            environment: context.apiContext.environment,
            size: .small
        )
        let selectableItem = SelectableFormItem(
            title: app.name,
            imageUrl: logoUrl,
            isSelected: false,
            isSeparatorViewShown: true,
            style: .init(title: configuration.style.textField.title),
            identifier: app.identifier
        )
        selectableItem.selectionHandler = { [weak self, weak selectableItem] in
            guard let self, let selectableItem else { return }
            self.handleSelection(item: selectableItem)
        }
        return selectableItem
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.delegate = self
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))

        if !upiAppsList.isEmpty {
            formViewController.append(modeInstructionsLabelItem.padding())
            formViewController.append(FormSpacerItem(numberOfSpaces: 1))
            formViewController.append(upiFlowSelectionItem.padding())
            formViewController.append(FormSpacerItem(numberOfSpaces: 1))
            formViewController.append(intentInstructionsLabelItem)
            formViewController.append(appsListTitleItem)
            formViewController.append(errorItem)
            upiAppsList.forEach { formViewController.append($0) }
        }

        collectInstructionsLabelItem.isVisible = upiAppsList.isEmpty
        vpaInputItem.isVisible = upiAppsList.isEmpty
        formViewController.append(collectInstructionsLabelItem)
        formViewController.append(vpaInputItem)

        if configuration.showsSubmitButton {
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(continueButton)
        }
        formViewController.append(FormSpacerItem(numberOfSpaces: 4))

        return formViewController
    }()
}

// MARK: - Event Handling

extension UPIComponent {

    private func handleSelection(item: SelectableFormItem?) {
        self.currentSelectedItemIdentifier = item?.identifier
        self.updateSelection()

        let selectedUPIApp = availableUPIApps.first { $0.identifier == item?.identifier }
        sendUPIIntentAppSelectionEvent(for: selectedUPIApp)
    }

    private func didSelectContinueButton() {
        guard validate() else { return }

        guard canSubmit() else {
            showError()
            return
        }

        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submitPayment()
    }

    private func didChangeSegmentedControlIndex(_ index: Int) {
        AdyenAssertion.assert(message: "UPI flow type is out of range", condition: UPIFlowType(rawValue: index) == nil)
        selectedUPIFlow = UPIFlowType(rawValue: index) ?? .upiIntent

        updateInterface()
    }
}

// MARK: - UPI App Detection

internal extension UPIComponent {

    func isAppInstalled(scheme: String?) -> Bool {
        guard let scheme else { return false }
        return urlSchemeChecker.canOpen(scheme: scheme)
    }

    var upiApps: [Issuer] {
        upiPaymentMethod.apps ?? []
    }
}

// MARK: - Analytics

private extension UPIComponent {

    func sendDisplayedEventForCurrentFlow() {
        switch selectedUPIFlow {
        case .upiIntent, .upiApps:
            sendUPIIntentDisplayedEvent()
        case .upiCollect:
            sendUPICollectDisplayedEvent()
        default:
            break
        }
    }

    func sendUPIIntentDisplayedEvent() {
        var infoEvent = AnalyticsEventInfo(
            component: UPIFlowType.upiIntent.value,
            type: .displayed
        )
        infoEvent.target = installedUPIApps.isEmpty ? .issuerList : .listDetected
        infoEvent.presentedValues = availableUPIApps.map(\.identifier)
        context.analyticsProvider?.add(info: infoEvent)
    }

    func sendUPIIntentAppSelectionEvent(for issuer: Issuer?) {
        guard let issuer else { return }
        var infoEvent = AnalyticsEventInfo(
            component: UPIFlowType.upiIntent.value,
            type: .selected
        )
        infoEvent.target = installedUPIApps.isEmpty ? .issuerList : .listDetected
        infoEvent.issuer = issuer.identifier
        context.analyticsProvider?.add(info: infoEvent)
    }

    func sendUPICollectDisplayedEvent() {
        let infoEvent = AnalyticsEventInfo(
            component: UPIFlowType.upiCollect.value,
            type: .displayed
        )
        context.analyticsProvider?.add(info: infoEvent)
    }
}

// MARK: - UI State Management

private extension UPIComponent {

    var firstSegmentTitle: String {
        localizedString(
            .upiModePayByAnyUpi,
            configuration.localizationParameters
        )
    }

    func updateSelection() {
        upiAppsList.forEach {
            $0.isSelected = false
            $0.isSeparatorViewShown = true
        }

        if let currentSelectedItemIdentifier {
            upiAppsList.first(where: { $0.identifier == currentSelectedItemIdentifier })?.isSelected = true
        }

        hideError()
    }

    func updateInterface() {
        switch selectedUPIFlow {
        case .upiIntent, .upiApps:
            upiAppsList.forEach { $0.isHidden.wrappedValue = false }
            intentInstructionsLabelItem.isVisible = true
            appsListTitleItem.isVisible = true
            collectInstructionsLabelItem.isVisible = false
            vpaInputItem.isVisible = false
            formViewController.view.endEditing(true)
        case .upiCollect, .qrCode:
            upiAppsList.forEach { $0.isHidden.wrappedValue = true }
            intentInstructionsLabelItem.isVisible = false
            appsListTitleItem.isVisible = false
            collectInstructionsLabelItem.isVisible = true
            vpaInputItem.isVisible = true
            focusVpaInput()
        }

        hideError()
        sendDisplayedEventForCurrentFlow()
    }

    func focusVpaInput() {
        vpaInputItem.focus()
    }

    func showError() {
        errorItem.isHidden.wrappedValue = false
        UIAccessibility.post(
            notification: .announcement,
            argument: "\(localizedString(.errorTitle, configuration.localizationParameters)): \(errorItem.message ?? "")"
        )
    }

    func hideError() {
        errorItem.isHidden.wrappedValue = true
    }

    func canSubmit() -> Bool {
        switch selectedUPIFlow {
        case .upiIntent, .upiApps:
            return currentSelectedItemIdentifier != nil
        case .upiCollect, .qrCode:
            return vpaInputItem.isValid()
        }
    }

    func submitPayment() {
        switch selectedUPIFlow {
        case .upiIntent, .upiApps:
            let details = UPIComponentDetails(
                type: selectedUPIFlow.value,
                virtualPaymentAddress: nil,
                appId: currentSelectedItemIdentifier
            )
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        case .upiCollect, .qrCode:
            let details = UPIComponentDetails(
                type: selectedUPIFlow.value,
                virtualPaymentAddress: vpaInputItem.value,
                appId: nil
            )
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        }
    }
}

@_spi(AdyenInternal)
extension UPIComponent: AdyenObserver {}

// MARK: - SubmitCustomizable

extension UPIComponent: SubmittableComponent {

    public func submit() {
        didSelectContinueButton()
    }

    public func validate() -> Bool {
        formViewController.validate()
    }
}

// MARK: - TrackableComponent

@_spi(AdyenInternal)
extension UPIComponent: TrackableComponent {}

// MARK: - ViewControllerDelegate

@_spi(AdyenInternal)
extension UPIComponent: ViewControllerDelegate {

    public func viewDidLoad(viewController: UIViewController) {
        sendInitialAnalytics()
        sendDidLoadEvent()
    }

    public func viewDidAppear(viewController: UIViewController) {
        updateInterface()
    }
}
