//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif

/// A component that provides a form for BLIK payments.
@MainActor
public final class BLIKComponent: PaymentComponent, PresentableComponent, LoadingComponent {
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    public var paymentMethod: PaymentMethod {
        blikPaymentMethod
    }

    public weak var delegate: PaymentComponentDelegate?

    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        theme: configuration.theme
    )
    
    /// Component's configuration
    public var configuration: BLIKComponentConfiguration

    private let blikPaymentMethod: BLIKPaymentMethod

    /// Initializes the BLIK component.
    ///
    /// - Parameter paymentMethod: The BLIK payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: BLIKPaymentMethod,
        context: AdyenContext,
        configuration: BLIKComponentConfiguration = .init()
    ) {
        self.blikPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    public func submit() {
        didSelectSubmitButton()
    }
    
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            localizationParameters: configuration.localizationParameters,
            theme: configuration.theme
        )

        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title

        formViewController.append(FormSpacerItem())
        formViewController.append(hintLabelItem.padding())
        formViewController.append(FormSpacerItem())
        formViewController.append(codeItem)
        formViewController.append(FormSpacerItem())

        if configuration.showsSubmitButton {
            formViewController.append(button)
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        }

        return formViewController
    }()

    /// The helper message item.
    internal lazy var hintLabelItem: FormLabelItem = .init(
        text: localizedString(.blikHelp, configuration.localizationParameters),
        identifier: ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: "blikCodeHintLabel"
        ),
        labelStyle: configuration.theme.elements.labels.body
    )

    /// The BLIK code item.
    internal lazy var codeItem: FormTextInputItem = {
        let item = FormTextInputItem()
        item.title = localizedString(.blikCode, configuration.localizationParameters)
        item.placeholder = localizedString(.blikPlaceholder, configuration.localizationParameters)
        item.validator = NumericStringValidator(exactLength: 6)
        item.formatter = NumericFormatter()
        item.validationFailureMessage = localizedString(.blikInvalid, configuration.localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeItem")
        return item
    }()

    /// The button item.
    internal lazy var button: FormButtonItem = {
        let buttonStylePrimary = configuration.theme.elements.buttons.primary
        let item = FormButtonItem(buttonStyle: buttonStylePrimary)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(
            with: context.amount,
            style: .immediate,
            configuration.localizationParameters
        )
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Private

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = BLIKDetails(
            paymentMethod: paymentMethod,
            blikCode: codeItem.value
        )
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        let data = PaymentComponentData(paymentMethodDetails: details, amount: context.amount, order: order)
        submit(data: data)
    }
}

@_spi(AdyenInternal)
extension BLIKComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension BLIKComponent: ViewControllerDelegate {}
