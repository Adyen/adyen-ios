//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An abstract class that needs to be subclassed to abstract away any component
/// who's form consists of a combination of personal information pieces like first name, last name, phone, email, and billing address.
/// :nodoc:
open class AbstractPersonalInformationComponent: PaymentComponent, PresentableComponent, Localizable {

    // MARK: - Properties

    /// :nodoc:
    public let apiContext: APIContext
    
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

    /// :nodoc:
    public let configuration: Configuration

    /// :nodoc:
    public let shopperInformation: PrefilledShopperInformation?

    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter configuration: The Component's configuration.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: PaymentMethod,
                configuration: Configuration,
                apiContext: APIContext,
                shopperInformation: PrefilledShopperInformation? = nil,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.apiContext = apiContext
        self.shopperInformation = shopperInformation
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
    private func build(_ formViewController: FormViewController) {
        configuration.fields.forEach { field in
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
        guard configuration.fields.contains(.firstName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "firstNameItem")
        let injector = NameFormItemInjector(value: shopperInformation?.shopperName?.firstName,
                                            identifier: identifier,
                                            localizationKey: .firstName,
                                            style: style.textField,
                                            contentType: .givenName)
        injector.localizationParameters = localizationParameters
        return injector
    }()

    /// :nodoc:
    public var firstNameItem: FormTextInputItem? { firstNameItemInjector?.item }

    /// :nodoc:
    internal lazy var lastNameItemInjector: NameFormItemInjector? = {
        guard configuration.fields.contains(.lastName) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "lastNameItem")
        let injector = NameFormItemInjector(value: shopperInformation?.shopperName?.lastName,
                                            identifier: identifier,
                                            localizationKey: .lastName,
                                            style: style.textField,
                                            contentType: .familyName)
        injector.localizationParameters = localizationParameters
        return injector
    }()

    /// :nodoc:
    public var lastNameItem: FormTextInputItem? { lastNameItemInjector?.item }

    /// :nodoc:
    internal lazy var emailItemInjector: EmailFormItemInjector? = {
        guard configuration.fields.contains(.email) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        let injector = EmailFormItemInjector(value: shopperInformation?.emailAddress,
                                             identifier: identifier,
                                             style: style.textField)
        injector.localizationParameters = localizationParameters
        return injector
    }()

    /// :nodoc:
    public var emailItem: FormTextInputItem? { emailItemInjector?.item }
    
    /// :nodoc:
    internal lazy var addressItemInjector: AddressFormItemInjector? = {
        guard configuration.fields.contains(.address) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "addressItem")
        let initialCountry = shopperInformation?.billingAddress?.country ?? defaultCountryCode
        return AddressFormItemInjector(value: shopperInformation?.billingAddress,
                                       initialCountry: initialCountry,
                                       identifier: identifier,
                                       style: style.addressStyle)
    }()
    
    /// :nodoc:
    public var addressItem: FormAddressItem? { addressItemInjector?.item }
    
    /// :nodoc:
    internal lazy var deliveryAddressItemInjector: AddressFormItemInjector? = {
        guard configuration.fields.contains(.deliveryAddress) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "deliveryAddressItem")
        let initialCountry = shopperInformation?.deliveryAddress?.country ?? defaultCountryCode
        return AddressFormItemInjector(value: shopperInformation?.deliveryAddress,
                                       initialCountry: initialCountry,
                                       identifier: identifier,
                                       style: style.addressStyle)
    }()
    
    /// :nodoc:
    public var deliveryAddressItem: FormAddressItem? { deliveryAddressItemInjector?.item }

    /// :nodoc:
    internal lazy var phoneItemInjector: PhoneFormItemInjector? = {
        guard configuration.fields.contains(.phone) else { return nil }
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        let injector = PhoneFormItemInjector(value: shopperInformation?.telephoneNumber,
                                             identifier: identifier,
                                             phoneExtensions: selectableValues,
                                             style: style.textField)
        injector.localizationParameters = localizationParameters
        return injector
    }()

    /// :nodoc:
    public var phoneItem: FormPhoneNumberItem? { phoneItemInjector?.item }

    private lazy var selectableValues: [PhoneExtensionPickerItem] = getPhoneExtensions().map {
        PhoneExtensionPickerItem(identifier: $0.countryCode, element: $0)
    }

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
        guard let shopperInformation else { return }

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
