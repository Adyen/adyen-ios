//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that provides a form for BLIK payments.
public final class BLIKComponent: PaymentComponent, PresentableComponent, Localizable {
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
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: BLIKPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.blikPaymentMethod = paymentMethod
        self.style = style
    }

    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }

    private lazy var formViewController: FormViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)

        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters

        formViewController.title = paymentMethod.name.uppercased()

        let container = ContainerFormItem(content: hintLabelItem,
                                          padding: .init(top: 7, left: 0, bottom: -7, right: 0))
        formViewController.append(container)
        formViewController.append(codeItem)
        formViewController.append(footerItem)

        return formViewController
    }()

    /// The helper message item.
    internal lazy var hintLabelItem: FormLabelItem = {
        FormLabelItem(text: ADYLocalizedString("adyen.blik.help", localizationParameters),
                      style: style.hintLabel,
                      identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeHintLabel"))
    }()

    /// The BLIK code item.
    internal lazy var codeItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        item.title = ADYLocalizedString("adyen.blik.code", localizationParameters)
        item.placeholder = ADYLocalizedString("adyen.blik.placeholder", localizationParameters)
        item.validator = NumericStringValidator(minimumLength: 6, maximumLength: 6)
        item.formatter = NumericFormatter()
        item.validationFailureMessage = ADYLocalizedString("adyen.blik.invalid", localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeItem")
        return item
    }()

    /// The footer item.
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem(style: style.footer)
        footerItem.submitButtonTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationParameters)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footerItem")
        return footerItem
    }()

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = BLIKDetails(paymentMethod: paymentMethod,
                                  blikCode: codeItem.value)
        footerItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
