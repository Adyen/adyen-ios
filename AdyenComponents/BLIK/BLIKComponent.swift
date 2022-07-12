//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A component that provides a form for BLIK payments.
public final class BLIKComponent: PaymentComponent, PresentableComponent, PaymentAware, LoadingComponent {
    
    /// Configuration for BLIK Component.
    public typealias Configuration = BasicComponentConfiguration
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    public var paymentMethod: PaymentMethod { blikPaymentMethod }

    public weak var delegate: PaymentComponentDelegate?

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)
    
    /// Component's configuration
    public var configuration: Configuration

    public let requiresModalPresentation: Bool = true

    private let blikPaymentMethod: BLIKPaymentMethod

    /// Initializes the BLIK component.
    ///
    /// - Parameter paymentMethod: The BLIK payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: BLIKPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.blikPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title

        formViewController.append(FormSpacerItem())
        formViewController.append(hintLabelItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem())
        formViewController.append(codeItem)
        formViewController.append(FormSpacerItem())
        formViewController.append(button)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))

        return formViewController
    }()

    /// The helper message item.
    internal lazy var hintLabelItem: FormLabelItem = .init(text: localizedString(.blikHelp, configuration.localizationParameters),
                                                           style: configuration.style.hintLabel,
                                                           identifier: ViewIdentifierBuilder.build(scopeInstance: self,
                                                                                                   postfix: "blikCodeHintLabel"))

    /// The BLIK code item.
    internal lazy var codeItem: FormTextInputItem = {
        let item = FormTextInputItem(style: configuration.style.textField)
        item.title = localizedString(.blikCode, configuration.localizationParameters)
        item.placeholder = localizedString(.blikPlaceholder, configuration.localizationParameters)
        item.validator = NumericStringValidator(exactLength: 6)
        item.formatter = NumericFormatter()
        item.validationFailureMessage = localizedString(.blikInvalid, configuration.localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeItem")
        return item
    }()

    /// The footer item.
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                style: .immediate,
                                                configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Private

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = BLIKDetails(paymentMethod: paymentMethod,
                                  blikCode: codeItem.value)
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }
}

@_spi(AdyenInternal)
extension BLIKComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension BLIKComponent: ViewControllerDelegate {
    // MARK: - ViewControllerDelegate

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}
