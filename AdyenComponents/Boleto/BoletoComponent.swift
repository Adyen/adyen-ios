//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Boleto payment.
public final class BoletoComponent: PaymentComponent, LoadingComponent, PresentableComponent, Localizable, Observer {

    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
        
    /// :nodoc:
    public var paymentMethod: PaymentMethod { configuration.boletoPaymentMethod }
    
    /// :nodoc:
    public var payment: Payment? { configuration.payment }
    
    /// :nodoc:
    private let configuration: Configuration

    /// :nodoc:
    internal var shopperInformation: PrefilledShopperInformation {
        configuration.shopperInformation
    }
    
    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    private let style: FormComponentStyle
    
    /// Initializes the Boleto Component
    /// - Parameters:
    ///   - configuration: The Component's configuration.
    ///   - style: The Component's UI style.
    public init(configuration: Configuration,
                apiContext: APIContext,
                style: FormComponentStyle = FormComponentStyle()) {
        self.configuration = configuration
        self.apiContext = apiContext
        self.style = style
        
        socialSecurityNumberItem.isHidden.wrappedValue = false
    }
    
    /// :nodoc:
    private lazy var socialSecurityNumberItem: FormTextInputItem = {
        let socialSecurityNumberItem = FormTextInputItem(style: style.textField)
        socialSecurityNumberItem.title = localizedString(.boletoSocialSecurityNumber, localizationParameters)
        socialSecurityNumberItem.placeholder = localizedString(.boletoSocialSecurityNumber, localizationParameters)
        socialSecurityNumberItem.formatter = BrazilSocialSecurityNumberFormatter()
        socialSecurityNumberItem.validator = NumericStringValidator(exactLength: 11) || NumericStringValidator(exactLength: 14)
        socialSecurityNumberItem.autocapitalizationType = .none
        socialSecurityNumberItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "socialSecurityNumberItem")
        
        return socialSecurityNumberItem
    }()
    
    /// :nodoc:
    internal lazy var sendCopyByEmailItem: FormToggleItem = {
        let sendCopyToEmailItem = FormToggleItem(style: style.toggle)
        sendCopyToEmailItem.value = false
        sendCopyToEmailItem.title = localizedString(.boletoSendCopyToEmail, localizationParameters)
        sendCopyToEmailItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sendCopyToEmailItem")

        return sendCopyToEmailItem
    }()
    
    /// :nodoc:
    private func headerFormItem(key: LocalizationKey) -> FormContainerItem {
        FormLabelItem(
            text: localizedString(key, localizationParameters),
            style: style.sectionHeader,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: localizedString(key, localizationParameters)
            )
        ).addingDefaultMargins()
    }
    
    /// :nodoc:
    private lazy var formComponent: FormComponent = {
        let configuration = AbstractPersonalInformationComponent.Configuration(fields: formFields)
        let component = FormComponent(paymentMethod: paymentMethod,
                                      configuration: configuration,
                                      apiContext: apiContext,
                                      onCreatePaymentDetails: { [weak self] in self?.createPaymentDetails() },
                                      style: style)

        if let emailItem = component.emailItem {
            bind(sendCopyByEmailItem.publisher, to: emailItem, at: \.isHidden.wrappedValue, with: { !$0 })
        }
        (component.viewController as? SecuredViewController)?.delegate = self
        component.delegate = self
        return component
    }()
    
    /// :nodoc:
    public lazy var viewController: UIViewController = formComponent.viewController
    
    /// :nodoc:
    /// Constructs the fields for the form based on the configuration
    private var formFields: [PersonalInformation] {
        var fields: [PersonalInformation] = [
            .custom(CustomFormItemInjector(item: headerFormItem(key: .boletoPersonalDetails))),
            .firstName,
            .lastName,
            .custom(CustomFormItemInjector(item: socialSecurityNumberItem)),
            .address
        ]

        if configuration.showEmailAddress {
            fields.append(.custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 1))))
            fields.append(.custom(CustomFormItemInjector(item: sendCopyByEmailItem)))
            fields.append(.email)
            fields.append(.custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 1))))
        }

        return fields
    }

    /// :nodoc:
    /// Sets the initial values for the form fields based on configuration
    private func prefillFields(for component: FormComponent) {
        shopperInformation.shopperName.map {
            component.firstNameItem?.value = $0.firstName
            component.lastNameItem?.value = $0.lastName
        }
        shopperInformation.socialSecurityNumber.map { socialSecurityNumberItem.value = $0 }
        shopperInformation.billingAddress.map { component.addressItem?.value = $0 }

        if let emailItem = component.emailItem {
            sendCopyByEmailItem.value = false
            emailItem.value = shopperInformation.emailAddress ?? ""
        }
    }
    
    /// :nodoc:
    private func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = formComponent.firstNameItem,
              let lastNameItem = formComponent.lastNameItem,
              let billingAddress = shopperInformation.billingAddress ?? formComponent.addressItem?.value else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        
        let shopperName = ShopperName(firstName: firstNameItem.value, lastName: lastNameItem.value)

        return BoletoDetails(
            type: paymentMethod.type,
            shopperName: shopperName,
            socialSecurityNumber: socialSecurityNumberItem.value,
            emailAddress: getEmailDetails(),
            billingAddress: billingAddress
        )
    }
    
    /// :nodoc:
    /// Obtain email address depending if it was prefilled, or the checkbox was ticked
    private func getEmailDetails() -> String? {
        if let prefilledEmail = shopperInformation.emailAddress {
            return prefilledEmail
        } else if sendCopyByEmailItem.value, let filledEmail = formComponent.emailItem?.value {
            return filledEmail
        }

        return nil
    }
    
    /// :nodoc:
    public func stopLoading() {
        formComponent.stopLoading()
    }
}

extension BoletoComponent: ViewControllerDelegate {

    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {}

    /// :nodoc:
    public func viewDidAppear(viewController: UIViewController) {}

    /// :nodoc:
    public func viewWillAppear(viewController: UIViewController) {
        prefillFields(for: formComponent)
    }
}

extension BoletoComponent: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        delegate?.didSubmit(data, from: self)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
}

/// :nodoc:
extension BoletoComponent {
    
    /// :nodoc:
    fileprivate final class FormComponent: AbstractPersonalInformationComponent {
        
        /// :nodoc:
        private let onCreatePaymentDetails: () -> PaymentMethodDetails?
        
        /// :nodoc:
        fileprivate init(
            paymentMethod: PaymentMethod,
            configuration: AbstractPersonalInformationComponent.Configuration,
            apiContext: APIContext,
            onCreatePaymentDetails: @escaping () -> PaymentMethodDetails?,
            style: FormComponentStyle = FormComponentStyle()
        ) {
            self.onCreatePaymentDetails = onCreatePaymentDetails
            
            super.init(paymentMethod: paymentMethod,
                       configuration: configuration,
                       apiContext: apiContext,
                       style: style)
        }
        
        /// :nodoc:
        override public func submitButtonTitle() -> String {
            localizedString(.boletobancarioBtnLabel, localizationParameters)
        }
        
        /// :nodoc:
        override public func createPaymentDetails() -> PaymentMethodDetails {
            onCreatePaymentDetails() ?? InstantPaymentDetails(type: paymentMethod.type)
        }
    }
}
