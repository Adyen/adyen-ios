//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An abstract class that needs to be subclassed to abstract away any component
/// whoes form consists of a combination of personal information pieces like first name, last name, phone, email, and billing address.
/// :nodoc:
open class AbstractPersonalInformationComponent: PaymentComponent, PresentableComponent, Localizable {

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
    public let configuration: Configuration

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter configuration: The Component's configuration.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: PaymentMethod,
                configuration: Configuration,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.configuration = configuration
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
    private lazy var formBuilder = PersonalInformationFormBuilder()

    /// :nodoc:
    private func build(_ formViewController: FormViewController) {
        configuration.fields.forEach { field in
            self.add(field, into: formViewController)
        }
        formViewController.append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))
    }

    /// :nodoc:
    private func add(_ field: PersonalInformation,
                     into formViewController: FormViewController) {
        switch field {
        case .email:
            if let emailItem = emailItem {
                formViewController.append(emailItem)
            }
        case .firstName:
            if let firstNameItem = firstNameItem {
                formViewController.append(firstNameItem)
            }
        case .lastName:
            if let lastNameItem = lastNameItem {
                formViewController.append(lastNameItem)
            }
        case .phone:
            if let phoneItem = phoneItem {
                formViewController.append(phoneItem)
            }
        }
    }

    /// :nodoc:
    public lazy var firstNameItem: FormTextInputItem? = {
        guard configuration.fields.contains(.firstName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "firstNameItem")
        return FirstNameElement(identifier: identifier,
                                style: style.textField).build(formBuilder)
    }()

    /// :nodoc:
    public lazy var lastNameItem: FormTextInputItem? = {
        guard configuration.fields.contains(.lastName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "lastNameItem")
        return LastNameElement(identifier: identifier,
                               style: style.textField).build(formBuilder)
    }()

    /// :nodoc:
    public lazy var emailItem: FormTextInputItem? = {
        guard configuration.fields.contains(.email) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        return EmailElement(identifier: identifier,
                            style: style.textField).build(formBuilder)
    }()

    /// :nodoc:
    public lazy var phoneItem: FormPhoneNumberItem? = {
        guard configuration.fields.contains(.phone) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        return PhoneElement(identifier: identifier,
                            phoneExtensions: selectableValues,
                            style: style.textField).build(formBuilder)
    }()

    private lazy var selectableValues: [PhoneExtensionPickerItem] = {
        let query = PhoneExtensionsQuery(paymentMethod: PhoneNumberPaymentMethod.mbWay)
        return getPhoneExtensions().map {
            let title = "\($0.countryDisplayName) (\($0.value))"
            return PhoneExtensionPickerItem(identifier: $0.countryCode,
                                            title: title,
                                            phoneExtension: $0.value)

        }
    }()

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
    open func createPaymentDetails() -> PaymentMethodDetails {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    /// :nodoc:
    open func getPhoneExtensions() -> [PhoneExtension] {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

}
