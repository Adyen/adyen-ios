//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for phone number based payment methods like `MBWay` and `QiwiWallet`.
/// :nodoc:
public class PhoneBasedPaymentComponent: PaymentComponent, PresentableComponent, Localizable {
    /// :nodoc:
    public let paymentMethod: PaymentMethod

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

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter style: The Component's UI style.
    internal init(paymentMethod: PaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.style = style
    }

    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }

    private lazy var formViewController: FormViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)

        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters

        formViewController.title = paymentMethod.name
        formViewController.append(phoneNumberItem)
        formViewController.append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))

        return formViewController
    }()

    /// The full phone number item
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(selectableValues: selectableValues,
                                       style: style.textField,
                                       localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        return item
    }()

    internal lazy var selectableValues: [PhoneExtensionPickerItem] = {
        let query = PhoneExtensionsQuery(paymentMethod: PhoneNumberPaymentMethod.mbWay)
        return getPhoneExtensions().map {
            let title = "\($0.countryDisplayName) (\($0.value))"
            return PhoneExtensionPickerItem(identifier: $0.countryCode,
                                            title: title,
                                            phoneExtension: $0.value)

        }
    }()

    internal func getPhoneExtensions() -> [PhoneExtension] {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    /// The footer item.
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = ADYLocalizedString("adyen.continueTo", localizationParameters, paymentMethod.name)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    internal func createPaymentDetails() -> PaymentMethodDetails {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        let details = createPaymentDetails()

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
