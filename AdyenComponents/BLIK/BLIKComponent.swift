//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for BLIK payments.
public final class BLIKComponent: PaymentComponent, PresentableComponent, Localizable, LoadingComponent {
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public var paymentMethod: PaymentMethod { blikPaymentMethod }

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// Describes the component's UI style.
    public let style: FormComponentStyle

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// :nodoc:
    private let blikPaymentMethod: BLIKPaymentMethod

    /// Initializes the BLIK component.
    ///
    /// - Parameter paymentMethod: The BLIK payment method.
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: BLIKPaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = FormComponentStyle()) {
        self.blikPaymentMethod = paymentMethod
        self.style = style
        self.apiContext = apiContext
    }

    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.name.uppercased()

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
    internal lazy var hintLabelItem: FormLabelItem = .init(text: localizedString(.blikHelp, localizationParameters),
                                                           style: style.hintLabel,
                                                           identifier: ViewIdentifierBuilder.build(scopeInstance: self,
                                                                                                   postfix: "blikCodeHintLabel"))

    /// The BLIK code item.
    internal lazy var codeItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.blikCode, localizationParameters)
        item.placeholder = localizedString(.blikPlaceholder, localizationParameters)
        item.validator = NumericStringValidator(exactLength: 6)
        item.formatter = NumericFormatter()
        item.validationFailureMessage = localizedString(.blikInvalid, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeItem")
        return item
    }()

    /// The footer item.
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                style: .immediate,
                                                localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = BLIKDetails(paymentMethod: paymentMethod,
                                  blikCode: codeItem.value)
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }
}

extension BLIKComponent: TrackableComponent {}
