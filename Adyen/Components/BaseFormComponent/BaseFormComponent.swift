//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
open class BaseFormComponent: PaymentComponent, PresentableComponent, Localizable {

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)

    /// :nodoc:
    public var localizationParameters: LocalizationParameters? {
        didSet {
            formBuilder.localizationParameters = localizationParameters
        }
    }

    /// Describes the component's UI style.
    public let style: FormComponentStyle

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// :nodoc:
    public lazy var configuration: Configuration = {
        createConfiguration()
    }()

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter configuration: The Component's configuration.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: PaymentMethod,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.style = style
    }

    /// :nodoc:
    internal lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters

        formViewController.title = paymentMethod.name
        formViewController.delegate = self
        build(formViewController)

        return formViewController
    }()

    /// :nodoc:
    private lazy var formBuilder = BaseFormBuilder()

    /// :nodoc:
    private func build(_ formViewController: FormViewController) {
        configuration.fields.forEach { field in
            self.add(field, into: formViewController)
        }
        formViewController.append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))
    }

    /// :nodoc:
    private func add(_ field: BaseFormField,
                     into formViewController: FormViewController) {
        switch field {
        case let .email(element):
            let emailItem = element.build(formBuilder)
            formViewController.append(emailItem)
            self.emailItem = emailItem
        case let .firstName(element):
            let firstNameItem = element.build(formBuilder)
            formViewController.append(firstNameItem)
            self.firstNameItem = firstNameItem
        case let .lastName(element):
            let lastNameItem = element.build(formBuilder)
            formViewController.append(lastNameItem)
            self.lastNameItem = lastNameItem
        case let .phone(element):
            let phoneItem = element.build(formBuilder)
            formViewController.append(phoneItem)
            self.phoneItem = phoneItem
        }
    }

    /// :nodoc:
    internal var firstNameItem: FormTextInputItem?

    /// :nodoc:
    internal var lastNameItem: FormTextInputItem?

    /// :nodoc:
    internal var emailItem: FormTextInputItem?

    /// :nodoc:
    internal var phoneItem: FormPhoneNumberItem?

    /// The button item.
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = submitButtonTitle()
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    /// :nodoc:
    open func submitButtonTitle() -> String {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    /// :nodoc:
    open func createPaymentDetails(_ details: BaseFormDetails) -> PaymentMethodDetails {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    /// :nodoc:
    open func createConfiguration() -> Configuration {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

}
