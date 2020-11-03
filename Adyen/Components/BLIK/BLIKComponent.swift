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

        formViewController.title = paymentMethod.name
        formViewController.append(hinLabelItem)
        formViewController.append(blikCodeItem)
        formViewController.append(footerItem)

        return formViewController
    }()

    /// The helper message item.
    internal lazy var hinLabelItem: UILabel = {
        let item = UILabel()
        item.text = ADYLocalizedString("adyen.blik.help", localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeHintItem")
        item.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "blikCodeHintItem.label")
        item.font = style.helper.font
        item.textColor = style.helper.color
        item.textAlignment = style.helper.textAlignment
        item.backgroundColor = style.helper.backgroundColor

        return item
    }()

    /// The BLIK code item.
    internal lazy var blikCodeItem: FormTextInputItem = {
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
        footerItem.submitButtonTitle = ADYLocalizedString("adyen.continueTo", localizationParameters, blikPaymentMethod.name)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footerItem")
        return footerItem
    }()

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = BLIKDetails(paymentMethod: paymentMethod,
                                  blikCode: blikCodeItem.value)
        footerItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
