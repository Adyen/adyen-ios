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

    /// The flow types for UPI component.
    internal enum UPIFlowType: Int {
        case vpa = 0
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
        static let virtualPaymentAddress = "Virtual Payment Address"
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
                configuration: Configuration = .init()) {
        self.upiPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Items

    /// The upi based payment instructions label item.
    internal lazy var instructionsLabelItem: FormLabelItem = {
        let item = FormLabelItem(text: localizedString(.upiModeSelection, configuration.localizationParameters),
                                 style: configuration.style.footnoteLabel)
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.instructionsItem)
        return item
    }()

    /// The upi selection segment control item to choose the upi flow.
    internal lazy var upiFlowSelectionItem: FormSegmentedControlItem = {
        let item = FormSegmentedControlItem(items: ["VPA", "QR code"], style: configuration.style.segmentedControlStyle,
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
        item.title = Constants.virtualPaymentAddress
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(.UPIVpaValidationMessage, configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.virtualPaymentAddressInputItem)
        return item
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
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
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
        formViewController.append(virtualPaymentAddressItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(continueButton)

        return formViewController
    }()

    internal func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        switch UPIFlowType(rawValue: currentSelectedIndex) {
        case .vpa:
            let details = UPIComponentDetails(type: Constants.upiCollect,
                                              virtualPaymentAddress: virtualPaymentAddressItem.value)
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
        case .vpa:
            virtualPaymentAddressItem.isVisible = true
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
            qrCodeGenerationImageItem.isHidden.wrappedValue = true
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                    postfix: ViewIdentifier.continueButtonItem)
            continueButton.title = localizedString(.continueTitle, configuration.localizationParameters)
        case .qrCode:
            virtualPaymentAddressItem.isVisible = false
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = false
            qrCodeGenerationImageItem.isHidden.wrappedValue = false
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                    postfix: ViewIdentifier.generateQRCodeButtonItem)
            continueButton.title = localizedString(.QRCodeGenerateQRCode, configuration.localizationParameters)
        default:
            AdyenAssertion.assert(message: "UPI flow type is out of range", condition: currentSelectedIndex > 1)
        }
    }

}

@_spi(AdyenInternal)
extension UPIComponent: AdyenObserver {}
