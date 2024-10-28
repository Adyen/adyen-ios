//
// Copyright (c) 2024 Adyen N.V.
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

    /// The flow types for UPI component.
    internal enum UPIFlowType: Int {
        case upiApps = 0
        case qrCode = 1
    }

    private enum ViewIdentifier {
        static let instructionsItem = "instructionsLabelItem"
        static let upiFlowSelectionItem = "upiFlowSelectionSegmentedControlItem"
        static let continueButtonItem = "continueButton"
        static let errorItem = "errorItem"
        static let generateQRCodeButtonItem = "generateQRCodeButton"
        static let generateQRCodeContainerItem = "generateQRCodeLabelContainerItem"
        static let virtualPaymentAddressInputItem = "virtualPaymentAddressInputItem"
        static let qrCodeGenerationImageItem = "qrCodeGenerationImageItem"
    }

    internal enum Constants {
        internal static let upiCollect = "upi_collect"
        internal static let upiQRCode = "upi_qr"
        internal static let upiIntent = "upi_intent"
        internal static let vpaFlowIdentifier = "UPI/VPA"
        internal static let noAppsVpaSegmentTitle = "VPA"
        
        internal static let qrCodeIcon = "qrcode"
    }

    /// Configuration for UPI Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { upiPaymentMethod }

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The viewController for the component.
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

    internal private(set) var selectedUPIFlow: UPIFlowType = .upiApps

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
        
        if upiAppsList.isEmpty {
            self.currentSelectedItemIdentifier = Constants.vpaFlowIdentifier
        }
    }

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Items

    /// The upi based payment instructions label item.
    internal lazy var instructionsLabelItem: FormLabelItem = {
        let item = FormLabelItem(
            text: localizedString(
                .upiModeSelection,
                configuration.localizationParameters
            ),
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.instructionsItem
        )
        return item
    }()

    /// The upi selection segment control item to choose the upi flow.
    internal lazy var upiFlowSelectionItem: FormSegmentedControlItem = {
        let item = FormSegmentedControlItem(
            items: [
                firstSegmentTitle,
                localizedString(
                    .UPISecondTabTitle,
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

    /// The  virtual payment address text input item.
    internal lazy var vpaInputItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        item.title = localizedString(
            .UPICollectFieldLabel,
            configuration.localizationParameters
        )
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(
            .UPIVpaValidationMessage,
            configuration.localizationParameters
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.virtualPaymentAddressInputItem
        )
        return item
    }()

    /// The UPI app list item.
    internal lazy var upiAppsList: [SelectableFormItem] = {
        guard let apps = upiPaymentMethod.apps, !apps.isEmpty else { return [] }
        
        var upiAppslist = apps.map { selectableFormItem(from: $0) }
        upiAppslist.append(vpaSelectionItem)
        return upiAppslist
    }()

    /// The UPI enter UPI/VPA list item.
    internal lazy var vpaSelectionItem: SelectableFormItem = {
        let selectableItem = SelectableFormItem(
            title: localizedString(
                .UPICollectDropdownLabel,
                configuration.localizationParameters
            ),
            imageUrl: nil,
            isSelected: false,
            style: .init(title: configuration.style.textField.title),
            identifier: Constants.vpaFlowIdentifier
        )
        selectableItem.selectionHandler = { [weak self, weak selectableItem] in
            guard let self, let selectableItem else { return }
            self.handleSelection(
                identifier: selectableItem.identifier,
                showVpaInputItem: true
            )
        }
        return selectableItem
    }()

    /// The QRCode generation message item.
    internal lazy var qrCodeGenerationLabelContainerItem: FormItem = {
        let item = FormLabelItem(
            text: localizedString(
                .UPIQrcodeGenerationMessage,
                configuration.localizationParameters
            ),
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .center
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.generateQRCodeContainerItem
        )
        
        return item.padding().padding()
    }()

    /// The QRCode generation message view.
    internal lazy var qrCodeGenerationImageItem: FormImageItem = {
        let imageView = FormImageItem(name: Constants.qrCodeIcon)
        imageView.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.qrCodeGenerationImageItem
        )
        imageView.isHidden.wrappedValue = true
        return imageView
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
        let errorMessage = localizedString(LocalizationKey.UPIErrorNoAppSelected, configuration.localizationParameters)
        let item = FormErrorItem(message: errorMessage, iconName: "error")
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
            style: .init(title: configuration.style.textField.title),
            identifier: app.identifier
        )
        selectableItem.selectionHandler = { [weak self, weak selectableItem] in
            guard let self, let selectableItem else { return }
            self.handleSelection(
                identifier: selectableItem.identifier,
                showVpaInputItem: false
            )
        }
        return selectableItem
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(instructionsLabelItem.padding())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(upiFlowSelectionItem.padding())
        formViewController.append(errorItem)
        formViewController.append(qrCodeGenerationImageItem)
        qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(qrCodeGenerationLabelContainerItem)

        upiAppsList.forEach { formViewController.append($0) }
        // If apps get returned we hide the vpa input field until the vpa selection item is selected
        vpaInputItem.isVisible = upiAppsList.isEmpty
        
        formViewController.append(vpaInputItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(continueButton)

        return formViewController
    }()
}

// MARK: - Event Handling

extension UPIComponent {
    
    private func handleSelection(identifier: String?, showVpaInputItem: Bool) {
        self.currentSelectedItemIdentifier = identifier
        self.updateSelection()
        self.vpaInputItem.isHidden.wrappedValue = !showVpaInputItem
        if showVpaInputItem {
            self.focusVpaInput()
        }
    }
    
    private func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        guard canSubmit() else {
            showError()
            return
        }
        
        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit()
    }

    private func didChangeSegmentedControlIndex(_ index: Int) {
        AdyenAssertion.assert(message: "UPI flow type is out of range", condition: UPIFlowType(rawValue: index) == nil)
        selectedUPIFlow = UPIFlowType(rawValue: index) ?? .upiApps
        
        updateInterface()
    }
}

// MARK: - Private

private extension UPIComponent {
    
    var firstSegmentTitle: String {
        guard let apps = upiPaymentMethod.apps, !apps.isEmpty else {
            return Constants.noAppsVpaSegmentTitle
        }
        
        return localizedString(
            .UPIFirstTabTitle,
            configuration.localizationParameters
        )
    }
    
    func updateSelection() {
        upiAppsList.forEach { $0.isSelected = false }
        
        if let currentSelectedItemIdentifier {
            upiAppsList.first(where: { $0.identifier == currentSelectedItemIdentifier })?.isSelected = true
        }
        
        hideError()
    }
    
    func updateInterface() {
        switch selectedUPIFlow {
        case .upiApps:
            upiAppsList.forEach { $0.isHidden.wrappedValue = false }
            vpaInputItem.isVisible = currentSelectedItemIdentifier == Constants.vpaFlowIdentifier
            
            qrCodeGenerationLabelContainerItem.isVisible = false
            qrCodeGenerationImageItem.isVisible = false
            
            continueButton.title = localizedString(.continueTitle, configuration.localizationParameters)
            
            focusVpaInput()

        case .qrCode:
            upiAppsList.forEach { $0.isHidden.wrappedValue = true }
            vpaInputItem.isVisible = false
            
            qrCodeGenerationLabelContainerItem.isVisible = true
            qrCodeGenerationImageItem.isVisible = true
            
            continueButton.title = localizedString(.QRCodeGenerateQRCode, configuration.localizationParameters)
        }
        
        hideError()
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
        case .upiApps:
            if currentSelectedItemIdentifier == Constants.vpaFlowIdentifier {
                return vpaInputItem.isValid()
            } else {
                return currentSelectedItemIdentifier != nil
            }
        case .qrCode:
            return true
        }
    }
    
    func submit() {
        switch selectedUPIFlow {
        case .upiApps:
            let details: UPIComponentDetails
            let flowType = currentSelectedItemIdentifier == Constants.vpaFlowIdentifier ? Constants.upiCollect : Constants.upiIntent
            if flowType == Constants.upiCollect {
                details = UPIComponentDetails(
                    type: flowType,
                    virtualPaymentAddress: vpaInputItem.value,
                    appId: nil
                )
            } else {
                details = UPIComponentDetails(
                    type: flowType,
                    virtualPaymentAddress: nil,
                    appId: currentSelectedItemIdentifier
                )
            }
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))

        case .qrCode:
            let details = UPIComponentDetails(type: Constants.upiQRCode)
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        }
    }
}

@_spi(AdyenInternal)
extension UPIComponent: AdyenObserver {}
