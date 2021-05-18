//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Boleto payment.
public final class BoletoComponent: PaymentComponent, PresentableComponent, Localizable, Observer {
    
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
    public let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    private let style: FormComponentStyle
    
    /// Initializes the Boleto Component
    /// - Parameters:
    ///   - configuration: The Component's configuration.
    ///   - style: The Component's UI style.
    public init(
        configuration: Configuration,
        style: FormComponentStyle = FormComponentStyle()
    ) {
        self.configuration = configuration
        self.style = style
        
        socialSecurityNumberItem.isHidden.wrappedValue = false
    }
    
    /// :nodoc:
    private lazy var socialSecurityNumberItem: FormTextInputItem = {
        let socialSecurityNumberItem = FormTextInputItem(style: style.textField)
        socialSecurityNumberItem.title = localizedString(LocalizationKey(key: "CPF/CNPJ"), localizationParameters)
        socialSecurityNumberItem.placeholder = localizedString(LocalizationKey(key: "CPF/CNPJ"), localizationParameters)
        socialSecurityNumberItem.validator = LengthValidator(minimumLength: 1)
        socialSecurityNumberItem.autocapitalizationType = .none
        socialSecurityNumberItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "personalNumberItem")
        
        return socialSecurityNumberItem
    }()
    
    /// :nodoc:
    internal lazy var sendCopyByEmailItem: FormSwitchItem = {
        let sendCopyToEmailItem = FormSwitchItem(style: FormSwitchItemStyle())
        sendCopyToEmailItem.title = localizedString(LocalizationKey(key: "Enviar copia por email"), localizationParameters)
        sendCopyToEmailItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sendCopyToEmailItem")

        return sendCopyToEmailItem
    }()
    
    /// :nodoc:
    internal lazy var billingAddressLabelItem: FormContainerItem = {
        FormLabelItem(
            text: configuration.shopperInfo.billingAddress?.formatted ?? "",
            style: style.hintLabel,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "preFilledBillingAddress")
        ).withPadding(padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
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
        ).withPadding(padding: .init(top: 8, left: 0, bottom: 0, right: 0))
    }
    
    /// :nodoc:
    private lazy var formComponent: FormComponent = {
        let component = FormComponent(
            paymentMethod: paymentMethod,
            configuration: AbstractPersonalInformationComponent.Configuration(fields: getFormFields()),
            onCreatePaymentDetails: { [weak self] in self?.createPaymentDetails() }
        )
        setUpFields(for: component)
        component.delegate = self
        return component
    }()
    
    /// :nodoc:
    public lazy var viewController: UIViewController = formComponent.viewController
    
    /// :nodoc:
    /// Constructs the fields for the form based on the configuration
    private func getFormFields() -> [PersonalInformation] {
        var fields: [PersonalInformation] = [
            .custom(CustomFormItemInjector(item: headerFormItem(key: LocalizationKey(key: "Dados pessoais")))),
            .firstName,
            .lastName,
            .custom(CustomFormItemInjector(item: socialSecurityNumberItem))
        ]

        if configuration.shopperInfo.billingAddress != nil {
            fields.append(
                .custom(CustomFormItemInjector(item: headerFormItem(key: .billingAddressSectionTitle)))
            )
            fields.append(.custom(CustomFormItemInjector(item: billingAddressLabelItem)))
        } else {
            fields.append(.address)
        }
        
        if configuration.showEmailAddress {
            fields.append( .custom(CustomFormItemInjector(item: sendCopyByEmailItem)))
            fields.append(.email)
        }
        
        return fields
    }
    
    /// :nodoc:
    /// Sets the initial values for the form fields based on configuration
    private func setUpFields(for component: FormComponent) {
        if let shopperName = configuration.shopperInfo.shopperName {
            component.firstNameItem?.value = shopperName.firstName
            component.lastNameItem?.value = shopperName.lastName
        }
        
        if let socialSecurityNumber = configuration.shopperInfo.socialSecurityNumber {
            socialSecurityNumberItem.value = socialSecurityNumber
        }
        
        if let emailItem = component.emailItem {
            sendCopyByEmailItem.value = false
            emailItem.value = configuration.shopperInfo.emailAddress ?? ""
            bind(sendCopyByEmailItem.publisher, to: emailItem, at: \.isHidden.wrappedValue, with: { !$0 })
        }
    }
    
    /// :nodoc:
    private func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = formComponent.firstNameItem,
              let lastNameItem = formComponent.lastNameItem,
              case let shopperName = ShopperName(firstName: firstNameItem.value, lastName: lastNameItem.value),
              let billingAddress = configuration.shopperInfo.billingAddress ?? formComponent.addressItem?.value else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }

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
        if let prefilledEmail = configuration.shopperInfo.emailAddress {
            return prefilledEmail
        } else if sendCopyByEmailItem.publisher.wrappedValue,
                  let filledEmail = formComponent.emailItem?.value {
            return filledEmail
        } else {
            return nil
        }
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
            onCreatePaymentDetails: @escaping () -> PaymentMethodDetails?,
            style: FormComponentStyle = FormComponentStyle()) {
            self.onCreatePaymentDetails = onCreatePaymentDetails
            
            super.init(paymentMethod: paymentMethod, configuration: configuration, style: style)
        }
        
        /// :nodoc:
        public override func submitButtonTitle() -> String {
            localizedString(LocalizationKey(key: "Gerar Boleto"), localizationParameters)
        }
        
        /// :nodoc:
        public override func createPaymentDetails() -> PaymentMethodDetails {
            onCreatePaymentDetails() ?? EmptyPaymentDetails(type: paymentMethod.type)
        }
    }
    
}
