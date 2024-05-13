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
        static let generateQRCodeButtonItem = "generateQRCodeButton"
        static let generateQRCodeContainerItem = "generateQRCodeLabelContainerItem"
        static let virtualPaymentAddressInputItem = "virtualPaymentAddressInputItem"
        static let qrCodeGenerationImageItem = "qrCodeGenerationImageItem"
    }

    private enum Constants {
        static let upiCollect = "upi_collect"
        static let upiQRCode = "upi_qr"
        static let upiIntent = "upi_intent"
    }

    /// Configuration for UPI Component.
    public typealias Configuration = BasicComponentConfiguration

    /// UPI App's configuration.
    public var upiAppsconfiguration: UPIAppsConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { upiPaymentMethod }

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    private var selectedUPIAppId: String = "UPI/VPA"

    /// The viewController for the component.
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    /// This indicates that `viewController` expected to be presented modally,
    public var requiresModalPresentation: Bool = true

    /// Component's configuration
    public var configuration: Configuration

    private let upiPaymentMethod: UPIPaymentMethod

    internal var currentSelectedIndex: Int = 0

    /// Initializes the UPI  component.
    ///
    /// - Parameter paymentMethod: The UPI payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: UPIPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init(),
                upiAppsconfiguration: UPIAppsConfiguration = .init()) {
        self.upiPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.upiAppsconfiguration = upiAppsconfiguration
    }

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Items

    /// The upi based payment instructions label item.
    internal lazy var instructionsLabelItem: FormLabelItem = {
        // TODO: Add localisation
        let item = FormLabelItem(text: "How would you like to use UPI?",
                                 style: configuration.style.footnoteLabel)
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.instructionsItem)
        return item
    }()

    /// The upi selection segment control item to choose the upi flow.
    internal lazy var upiFlowSelectionItem: FormSegmentedControlItem = {
        // TODO: Add localisation
        let item = FormSegmentedControlItem(items: ["Pay by any UPI app", "Other UPI options"],
                                            style: configuration.style.segmentedControlStyle,
                                            identifier: ViewIdentifierBuilder.build(
                                                scopeInstance: self,
                                                postfix: ViewIdentifier.upiFlowSelectionItem
                                            ))
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.upiFlowSelectionItem)
        item.selectionHandler = { [weak self] changedIndex in
            self?.didChangeSegmentedControlIndex(changedIndex)
        }
        return item
    }()

    /// The  virtual payment address text input item.
    internal lazy var virtualPaymentAddressItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        // TODO: Add localised string
        item.title = "Enter UPI ID / VPA"
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(.UPIVpaValidationMessage, configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.virtualPaymentAddressInputItem)
        return item
    }()

    /// The UPI app list item.
    internal lazy var upiAppsList: [ListItem] = {
        var upiAppslist = [ListItem]()
        _ = upiPaymentMethod.apps.map { app -> ListItem in
            let logoUrl = LogoURLProvider.logoURL(
                withName: app.identifier,
                environment: context.apiContext.environment,
                size: .small
            )
            let listItem = ListItem(
                title: app.name,
                icon: .init(url: logoUrl),
                style: upiAppsconfiguration.style.listItem,
                isSelectable: true
            )
            listItem.identifier = ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: listItem.title
            )
            listItem.selectionHandler = { [weak self, weak listItem] in
                guard let self, let listItem else { return }
                selectedUPIAppId = app.identifier
                print("selectedUPIAppId", selectedUPIAppId)
                // TODO: update checkmark of listItem
                listItem.isSelected = !listItem.isSelected
            }
            upiAppslist.append(listItem)
            return listItem
        }
        upiAppslist.append(vpaItem)
        return upiAppslist
    }()

    /// The UPI enter UPI/VPA list item.
    internal lazy var vpaItem: ListItem = {
        let listItem = ListItem(
            title: "Enter UPI ID",
            icon: ListItem.Icon(image: UIImage(named: "upiLogo") ?? UIImage()),
            style: upiAppsconfiguration.style.listItem,
            isSelectable: true
        )
        listItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: listItem.title
        )
        listItem.selectionHandler = { [weak self, weak listItem] in
            guard let self, let listItem else { return }
            selectedUPIAppId = "UPI/VPA"
            virtualPaymentAddressItem.isHidden.wrappedValue = !virtualPaymentAddressItem.isHidden.wrappedValue
        }
        return listItem
    }()

    /// The QRCode generation message item.
    internal lazy var qrCodeGenerationLabelContainerItem: FormContainerItem = {
        let item = FormLabelItem(text: localizedString(.UPIQrcodeGenerationMessage, configuration.localizationParameters),
                                 style: configuration.style.footnoteLabel)
        item.style.textAlignment = .center
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.generateQRCodeContainerItem)
        return FormContainerItem(content: item.addingDefaultMargins())
    }()

    /// The QRCode generation message view.
    internal lazy var qrCodeGenerationImageItem: FormImageItem = {
        let imageView = FormImageItem(name: "qrcode")
        imageView.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                           postfix: ViewIdentifier.qrCodeGenerationImageItem)
        imageView.isHidden.wrappedValue = true
        return imageView
    }()

    /// The continue button item.
    internal lazy var continueButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.continueButtonItem)
        item.title = localizedString(.continueTitle, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
        return item
    }()

    // MARK: - Private

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            style: self.configuration.style,
            localizationParameters: self.configuration.localizationParameters
        )
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(instructionsLabelItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(upiFlowSelectionItem.addingDefaultMargins())
        formViewController.append(qrCodeGenerationImageItem)
        qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(qrCodeGenerationLabelContainerItem)

        if !upiPaymentMethod.apps.isEmpty {
            for item in upiAppsList {
                formViewController.append(item)
            }
            formViewController.append(virtualPaymentAddressItem)
            virtualPaymentAddressItem.isHidden.wrappedValue = true
        } else {
            formViewController.append(virtualPaymentAddressItem)
        }
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(continueButton)

        return formViewController
    }()

    internal func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        switch UPIFlowType(rawValue: currentSelectedIndex) {
        case .upiApps:
            let flowType = selectedUPIAppId == "UPI/VPA" ? Constants.upiCollect : Constants.upiIntent
            let details = UPIComponentDetails(type: flowType,
                                              virtualPaymentAddress: virtualPaymentAddressItem.value,
                                              selectedUPIAppId: selectedUPIAppId)

            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        case .qrCode:
            let details = UPIComponentDetails(type: Constants.upiQRCode)
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        default:
            AdyenAssertion.assert(message: "UPI flow type is out of range", condition: currentSelectedIndex > 1)
        }
    }

    internal func didChangeSegmentedControlIndex(_ changedIndex: Int) {
        currentSelectedIndex = changedIndex

        switch UPIFlowType(rawValue: currentSelectedIndex) {
        case .upiApps:
            changeUPIAppsListVisiblity(shouldHide: false)
            virtualPaymentAddressItem.isVisible = false
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
            qrCodeGenerationImageItem.isHidden.wrappedValue = true
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                    postfix: ViewIdentifier.continueButtonItem)
            continueButton.title = localizedString(.continueTitle, configuration.localizationParameters)

        case .qrCode:
            changeUPIAppsListVisiblity(shouldHide: true)
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = false
            qrCodeGenerationImageItem.isHidden.wrappedValue = false
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                    postfix: ViewIdentifier.generateQRCodeButtonItem)
            continueButton.title = localizedString(.QRCodeGenerateQRCode, configuration.localizationParameters)
        default:
            AdyenAssertion.assert(message: "UPI flow type is out of range", condition: currentSelectedIndex > 1)
        }
    }

    private func changeUPIAppsListVisiblity(shouldHide isHidden: Bool = false) {
        if isHidden {
            if !upiPaymentMethod.apps.isEmpty {
                for app in upiAppsList {
                    app.isHidden.wrappedValue = true
                }
            }
        } else {
            if !upiPaymentMethod.apps.isEmpty {
                for app in upiAppsList {
                    app.isHidden.wrappedValue = false
                }
            }
        }
    }

}

@_spi(AdyenInternal)
extension UPIComponent: AdyenObserver {}

extension UPIComponent {

    /// Configuration for Issuer List type components.
    public struct UPIAppsConfiguration: AnyBasicComponentConfiguration {

        /// The UI style of the component.
        public var style: ListComponentStyle

        public var localizationParameters: LocalizationParameters?

        /// Initializes the configuration for Issuer list type components.
        /// - Parameters:
        ///   - style: The UI style of the component.
        ///   - localizationParameters: Localization parameters.
        public init(style: ListComponentStyle = .init(),
                    localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}
