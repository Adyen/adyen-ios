//
// Copyright (c) 2022 Adyen N.V.
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

    private enum ViewIdentifier {
        static let instructionsItem = "instructionsLabelItem"
        static let upiFlowSelectionItem = "upiFlowSelectionSegmentedControlItem"
        static let continueButtonItem = "continueButton"
        static let generateQRCodeButtonItem = "generateQRCodeButton"
        static let generateQRCodeContainerItem = "generateQRCodeLabelContainerItem"
    }

    /// Configuration for UPI Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    public var paymentMethod: PaymentMethod { upiPaymentMethod }

    public weak var delegate: PaymentComponentDelegate?

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    public var requiresModalPresentation: Bool = true

    /// Component's configuration
    public var configuration: Configuration

    private let upiPaymentMethod: UPIComponentPaymentMethod

    internal var currentSelectedIndex: Int = 0

    /// Initializes the UPI  component.
    ///
    /// - Parameter paymentMethod: The UPI payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: UPIComponentPaymentMethod,
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
                           postfix: ViewIdentifier.upiFlowSelectionItem))
        item.segmentedControlSelectionHandler = { [weak self] changedIndex in
            self?.didChangeSegmentedControlIndex(changedIndex)
        }
        return item
    }()

    /// The  virtual payment adddress text input  item.
    internal lazy var virtualPaymentAddressItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        item.title = "Virtual Payment Address"
        item.validator = LengthValidator(minimumLength: 1)
        item.validationFailureMessage = localizedString(.UPIVpaValidationMessage, configuration.localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "virtualPaymentAddressItem")
        return item
    }()

    /// The QRCode generation message item.
    internal lazy var qrCodeGenerationLabelContainerItem: FormContainerItem = {
        let item = FormLabelItem(text: localizedString(.UPIQrcodeGenerationMessage, configuration.localizationParameters),
                                 style: configuration.style.footnoteLabel)
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.generateQRCodeContainerItem)
        return FormContainerItem(content: item.addingDefaultMargins())
    }()

    /// The QRCode generation message view.
    private lazy var qrCodeGenerationImageItem: FormImageItem = {
        let imageView = FormImageItem(name: "qrcode")
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
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(instructionsLabelItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(upiFlowSelectionItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(qrCodeGenerationImageItem)
        qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
        formViewController.append(qrCodeGenerationLabelContainerItem)
        formViewController.append(virtualPaymentAddressItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 3))
        formViewController.append(continueButton)

        return formViewController
    }()

    private func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        switch currentSelectedIndex {
        case 0:
            if !virtualPaymentAddressItem.value.isEmpty {
                let details = UPIComponentDetails(type: "upi_collect",
                                                  virtualPaymentAddress: virtualPaymentAddressItem.value)
                submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
            }
        case 1:
            let details = UPIComponentDetails(type: "upi_qr")
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        default:
            break
        }
    }

    private func didChangeSegmentedControlIndex(_ changedIndex: Int) {
        currentSelectedIndex = changedIndex

        switch currentSelectedIndex {
        case 0:
            virtualPaymentAddressItem.isVisible = true
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = true
            qrCodeGenerationImageItem.isHidden.wrappedValue = true
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.continueButtonItem)
            continueButton.title = localizedString(.continueTitle, configuration.localizationParameters)
        case 1:
            virtualPaymentAddressItem.isVisible = false
            qrCodeGenerationLabelContainerItem.isHidden.wrappedValue = false
            qrCodeGenerationImageItem.isHidden.wrappedValue = false
            continueButton.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.generateQRCodeButtonItem)
            continueButton.title = localizedString(.QRCodeGenerateQRCode, configuration.localizationParameters)
        default:
            break
        }
    }

}

@_spi(AdyenInternal)
extension UPIComponent: AdyenObserver {}
