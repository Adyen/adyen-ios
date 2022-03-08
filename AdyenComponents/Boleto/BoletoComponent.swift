//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Boleto payment.
public final class BoletoComponent: PaymentComponent, LoadingComponent, PresentableComponent, AdyenObserver {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// The Adyen context
    public let adyenContext: AdyenContext
    
    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?
        
    /// :nodoc:
    public var paymentMethod: PaymentMethod { boletoPaymentMethod }

    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// The Component's configuration.
    public var configuration: Configuration
    
    internal let boletoPaymentMethod: BoletoPaymentMethod
    
    /// Initializes the Boleto Component
    /// - Parameters:
    ///   - paymentMethod: Boleto Payment Method
    ///   - apiContext: The component's API context.
    ///   - adyenContext: The Adyen context.
    ///   - configuration: The Component's configuration.
    public init(paymentMethod: BoletoPaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext,
                configuration: Configuration) {
        self.boletoPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.adyenContext = adyenContext
        self.configuration = configuration
        socialSecurityNumberItem.isHidden.wrappedValue = false
    }
    
    /// :nodoc:
    private lazy var socialSecurityNumberItem: FormTextInputItem = {
        let socialSecurityNumberItem = FormTextInputItem(style: configuration.style.textField)
        socialSecurityNumberItem.title = localizedString(.boletoSocialSecurityNumber, configuration.localizationParameters)
        socialSecurityNumberItem.placeholder = localizedString(.boletoSocialSecurityNumber, configuration.localizationParameters)
        socialSecurityNumberItem.formatter = BrazilSocialSecurityNumberFormatter()
        socialSecurityNumberItem.validator = NumericStringValidator(exactLength: 11) || NumericStringValidator(exactLength: 14)
        socialSecurityNumberItem.autocapitalizationType = .none
        socialSecurityNumberItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "socialSecurityNumberItem")
        
        return socialSecurityNumberItem
    }()
    
    /// :nodoc:
    internal lazy var sendCopyByEmailItem: FormToggleItem = {
        let sendCopyToEmailItem = FormToggleItem(style: configuration.style.toggle)
        sendCopyToEmailItem.value = false
        sendCopyToEmailItem.title = localizedString(.boletoSendCopyToEmail, configuration.localizationParameters)
        sendCopyToEmailItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sendCopyToEmailItem")

        return sendCopyToEmailItem
    }()
    
    /// :nodoc:
    private func headerFormItem(key: LocalizationKey) -> FormContainerItem {
        FormLabelItem(
            text: localizedString(key, configuration.localizationParameters),
            style: configuration.style.sectionHeader,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: localizedString(key, configuration.localizationParameters)
            )
        ).addingDefaultMargins()
    }
    
    /// :nodoc:
    private lazy var formComponent: FormComponent = {
        let configuration = AbstractPersonalInformationComponent.Configuration(style: configuration.style,
                                                                               shopperInformation: configuration.shopperInformation,
                                                                               localizationParameters: configuration.localizationParameters)
        let component = FormComponent(paymentMethod: paymentMethod,
                                      apiContext: apiContext,
                                      adyenContext: adyenContext,
                                      fields: formFields,
                                      configuration: configuration,
                                      onCreatePaymentDetails: { [weak self] in self?.createPaymentDetails() })

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
        configuration.shopperInformation?.shopperName.map {
            component.firstNameItem?.value = $0.firstName
            component.lastNameItem?.value = $0.lastName
        }
        configuration.shopperInformation?.socialSecurityNumber.map { socialSecurityNumberItem.value = $0 }
        configuration.shopperInformation?.billingAddress.map { component.addressItem?.value = $0 }

        if let emailItem = component.emailItem {
            sendCopyByEmailItem.value = false
            emailItem.value = configuration.shopperInformation?.emailAddress ?? ""
        }
    }
    
    /// :nodoc:
    private func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = formComponent.firstNameItem,
              let lastNameItem = formComponent.lastNameItem,
              let billingAddress = configuration.shopperInformation?.billingAddress ?? formComponent.addressItem?.value else {
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
        if let prefilledEmail = configuration.shopperInformation?.emailAddress {
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
        fileprivate init(paymentMethod: PaymentMethod,
                         apiContext: APIContext,
                         adyenContext: AdyenContext,
                         fields: [PersonalInformation],
                         configuration: AbstractPersonalInformationComponent.Configuration,
                         onCreatePaymentDetails: @escaping () -> PaymentMethodDetails?) {
            self.onCreatePaymentDetails = onCreatePaymentDetails
            
            super.init(paymentMethod: paymentMethod,
                       apiContext: apiContext,
                       adyenContext: adyenContext,
                       fields: fields,
                       configuration: configuration)
        }
        
        /// :nodoc:
        override public func submitButtonTitle() -> String {
            localizedString(.boletobancarioBtnLabel, configuration.localizationParameters)
        }
        
        /// :nodoc:
        override public func createPaymentDetails() -> PaymentMethodDetails {
            onCreatePaymentDetails() ?? InstantPaymentDetails(type: paymentMethod.type)
        }
    }
}
