//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A component that provides a form for MB Way payments.
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

    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    public var showsLargeTitle = true

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// :nodoc:
    private let blikPaymentMethod: BLIKPaymentMethod

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The MB Way payment method.
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

        if showsLargeTitle {
            let headerItem = FormHeaderItem(style: style.header)
            headerItem.title = paymentMethod.name
            headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
            formViewController.append(headerItem)
        } else {
            formViewController.title = paymentMethod.name
        }

        formViewController.append(phoneNumberItem)
        formViewController.append(footerItem)

        return formViewController
    }()

    /// The full phone number item.
    internal lazy var phoneNumberItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        item.title = ADYLocalizedString("adyen.phoneNumber.title", localizationParameters)
        item.placeholder = ADYLocalizedString("adyen.phoneNumber.placeholder", localizationParameters)
        item.validator = PhoneNumberValidator()
        item.formatter = PhoneNumberFormatter()
        item.validationFailureMessage = ADYLocalizedString("adyen.phoneNumber.invalid", localizationParameters)
        item.keyboardType = .phonePad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
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
                                  telephoneNumber: phoneNumberItem.value)
        footerItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
