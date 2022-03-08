//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An abstract class that needs to be subclassed to abstract away any component
/// who's form consists of a combination of personal information pieces like first name, last name, phone, email, and billing address.
/// :nodoc:
open class AbstractPersonalInformationComponent: PaymentComponent, PresentableComponent {

    /// :nodoc:
    public typealias Configuration = PersonalInformationConfiguration
    
    // MARK: - Properties

    /// :nodoc:
    public let apiContext: APIContext

    /// The Adyen context.
    public let adyenContext: AdyenContext
    
    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// :nodoc:
    public var configuration: Configuration
    
    private let fields: [PersonalInformation]

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter apiContext: The API context.
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter fields: The component's fields.
    /// - Parameter configuration: The Component's configuration.
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext,
                fields: [PersonalInformation],
                configuration: Configuration) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.adyenContext = adyenContext
        self.fields = fields
        self.configuration = configuration
    }

    /// :nodoc:
    internal lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters

        formViewController.title = paymentMethod.name
        formViewController.delegate = self
        build(formViewController)

        return formViewController
    }()

    /// :nodoc:
    private func build(_ formViewController: FormViewController) {
        fields.forEach { field in
            self.add(field, into: formViewController)
        }
        formViewController.append(FormSpacerItem())
        formViewController.append(button)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
    }

    /// :nodoc:
    private func add(_ field: PersonalInformation,
                     into formViewController: FormViewController) {
        switch field {
        case .email:
            emailItemInjector?.inject(into: formViewController)
        case .firstName:
            firstNameItemInjector?.inject(into: formViewController)
        case .lastName:
            lastNameItemInjector?.inject(into: formViewController)
        case .phone:
            phoneItemInjector?.inject(into: formViewController)
        case .address:
            addressItemInjector?.inject(into: formViewController)
        case .deliveryAddress:
            deliveryAddressItemInjector?.inject(into: formViewController)
        case let .custom(injector):
            injector.inject(into: formViewController)
        }
    }

    /// :nodoc:
    internal lazy var firstNameItemInjector: NameFormItemInjector? = {
        guard fields.contains(.firstName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "firstNameItem")
        let injector = NameFormItemInjector(value: configuration.shopperInformation?.shopperName?.firstName,
                                            identifier: identifier,
                                            localizationKey: .firstName,
                                            style: configuration.style.textField,
                                            contentType: .givenName)
        injector.localizationParameters = configuration.localizationParameters
        return injector
    }()

    /// :nodoc:
    public var firstNameItem: FormTextInputItem? { firstNameItemInjector?.item }

    /// :nodoc:
    internal lazy var lastNameItemInjector: NameFormItemInjector? = {
        guard fields.contains(.lastName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "lastNameItem")
        let injector = NameFormItemInjector(value: configuration.shopperInformation?.shopperName?.lastName,
                                            identifier: identifier,
                                            localizationKey: .lastName,
                                            style: configuration.style.textField,
                                            contentType: .familyName)
        injector.localizationParameters = configuration.localizationParameters
        return injector
    }()

    /// :nodoc:
    public var lastNameItem: FormTextInputItem? { lastNameItemInjector?.item }

    /// :nodoc:
    internal lazy var emailItemInjector: EmailFormItemInjector? = {
        guard fields.contains(.email) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        let injector = EmailFormItemInjector(value: configuration.shopperInformation?.emailAddress,
                                             identifier: identifier,
                                             style: configuration.style.textField)
        injector.localizationParameters = configuration.localizationParameters
        return injector
    }()

    /// :nodoc:
    public var emailItem: FormTextInputItem? { emailItemInjector?.item }
    
    /// :nodoc:
    internal lazy var addressItemInjector: AddressFormItemInjector? = {
        guard fields.contains(.address) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "addressItem")
        let initialCountry = configuration.shopperInformation?.billingAddress?.country ?? defaultCountryCode
        return AddressFormItemInjector(value: configuration.shopperInformation?.billingAddress,
                                       initialCountry: initialCountry,
                                       identifier: identifier,
                                       style: configuration.style.addressStyle)
    }()
    
    /// :nodoc:
    public var addressItem: FormAddressItem? { addressItemInjector?.item }
    
    /// :nodoc:
    internal lazy var deliveryAddressItemInjector: AddressFormItemInjector? = {
        guard fields.contains(.deliveryAddress) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "deliveryAddressItem")
        let initialCountry = configuration.shopperInformation?.deliveryAddress?.country ?? defaultCountryCode
        return AddressFormItemInjector(value: configuration.shopperInformation?.deliveryAddress,
                                       initialCountry: initialCountry,
                                       identifier: identifier,
                                       style: configuration.style.addressStyle)
    }()
    
    /// :nodoc:
    public var deliveryAddressItem: FormAddressItem? { deliveryAddressItemInjector?.item }

    /// :nodoc:
    internal lazy var phoneItemInjector: PhoneFormItemInjector? = {
        guard fields.contains(.phone) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        let injector = PhoneFormItemInjector(value: configuration.shopperInformation?.telephoneNumber,
                                             identifier: identifier,
                                             phoneExtensions: selectableValues,
                                             style: configuration.style.textField)
        injector.localizationParameters = configuration.localizationParameters
        return injector
    }()

    /// :nodoc:
    public var phoneItem: FormPhoneNumberItem? { phoneItemInjector?.item }

    private lazy var selectableValues: [PhoneExtensionPickerItem] = phoneExtensions().map {
        PhoneExtensionPickerItem(identifier: $0.countryCode, element: $0)
    }

    /// The button item.
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
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
    open func phoneExtensions() -> [PhoneExtension] {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    /// :nodoc:
    private var defaultCountryCode: String {
        payment?.countryCode ?? Locale.current.regionCode ?? "US"
    }

    /// :nodoc:
    public func showValidation() {
        formViewController.showValidation()
    }

    /// :nodoc:
    internal func populateFields() {
        guard let shopperInformation = configuration.shopperInformation else { return }

        shopperInformation.shopperName.map {
            firstNameItem?.value = $0.firstName
            lastNameItem?.value = $0.lastName
        }
        shopperInformation.emailAddress.map { emailItem?.value = $0 }
        shopperInformation.telephoneNumber.map { phoneItem?.value = $0 }
        shopperInformation.billingAddress.map { addressItem?.value = $0 }
        shopperInformation.deliveryAddress.map { deliveryAddressItem?.value = $0 }
    }
}
