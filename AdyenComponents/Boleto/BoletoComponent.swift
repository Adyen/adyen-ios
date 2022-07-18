//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A component that provides a form for Boleto payment.
public final class BoletoComponent: PaymentComponent,
    PaymentAware,
    LoadingComponent,
    PresentableComponent,
    AdyenObserver {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    public weak var delegate: PaymentComponentDelegate?
        
    public var paymentMethod: PaymentMethod { boletoPaymentMethod }

    public let requiresModalPresentation: Bool = true
    
    /// The Component's configuration.
    public var configuration: Configuration
    
    internal let boletoPaymentMethod: BoletoPaymentMethod
    
    /// Initializes the Boleto Component
    /// - Parameters:
    ///   - paymentMethod: Boleto Payment Method
    ///   - context: The context object for this component.
    ///   - configuration: The Component's configuration.
    public init(paymentMethod: BoletoPaymentMethod,
                context: AdyenContext,
                configuration: Configuration) {
        self.boletoPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        socialSecurityNumberItem.isHidden.wrappedValue = false
    }

    // MARK: - Private
    
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
    
    internal lazy var sendCopyByEmailItem: FormToggleItem = {
        let sendCopyToEmailItem = FormToggleItem(style: configuration.style.toggle)
        sendCopyToEmailItem.value = false
        sendCopyToEmailItem.title = localizedString(.boletoSendCopyToEmail, configuration.localizationParameters)
        sendCopyToEmailItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sendCopyToEmailItem")

        return sendCopyToEmailItem
    }()
    
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
    
    private lazy var formComponent: FormComponent = {
        let configuration = AbstractPersonalInformationComponent.Configuration(style: configuration.style,
                                                                               shopperInformation: configuration.shopperInformation,
                                                                               localizationParameters: configuration.localizationParameters)
        let component = FormComponent(paymentMethod: paymentMethod,
                                      context: context,
                                      fields: formFields,
                                      configuration: configuration,
                                      onCreatePaymentDetails: { [weak self] in
                                          var paymentMethodDetails: PaymentMethodDetails?
                                          do {
                                              paymentMethodDetails = try self?.createPaymentDetails()
                                          } catch {
                                              adyenPrint(error)
                                          }
                                          return paymentMethodDetails
                                      })

        if let emailItem = component.emailItem {
            bind(sendCopyByEmailItem.publisher, to: emailItem, at: \.isHidden.wrappedValue, with: { !$0 })
        }
        (component.viewController as? SecuredViewController)?.delegate = self
        component.delegate = self
        return component
    }()
    
    public lazy var viewController: UIViewController = formComponent.viewController
    
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
    
    private func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let firstNameItem = formComponent.firstNameItem,
              let lastNameItem = formComponent.lastNameItem,
              let billingAddress = configuration.shopperInformation?.billingAddress ?? formComponent.addressItem?.value else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
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
    
    /// Obtain email address depending if it was prefilled, or the checkbox was ticked
    private func getEmailDetails() -> String? {
        if let prefilledEmail = configuration.shopperInformation?.emailAddress {
            return prefilledEmail
        } else if sendCopyByEmailItem.value, let filledEmail = formComponent.emailItem?.value {
            return filledEmail
        }

        return nil
    }

    // MARK: - Public
    
    public func stopLoading() {
        formComponent.stopLoading()
    }
}

@_spi(AdyenInternal)
extension BoletoComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension BoletoComponent: ViewControllerDelegate {

    public func viewDidLoad(viewController: UIViewController) {}

    public func viewDidAppear(viewController: UIViewController) {}

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
        prefillFields(for: formComponent)
    }
}

@_spi(AdyenInternal)
extension BoletoComponent: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        submit(data: data, component: self)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent) {
        delegate?.didFail(with: error, from: self)
    }
}

@_spi(AdyenInternal)
extension BoletoComponent {
    
    fileprivate final class FormComponent: AbstractPersonalInformationComponent {
        
        private let onCreatePaymentDetails: () -> PaymentMethodDetails?
        
        fileprivate init(paymentMethod: PaymentMethod,
                         context: AdyenContext,
                         fields: [PersonalInformation],
                         configuration: AbstractPersonalInformationComponent.Configuration,
                         onCreatePaymentDetails: @escaping () -> PaymentMethodDetails?) {
            self.onCreatePaymentDetails = onCreatePaymentDetails
            
            super.init(paymentMethod: paymentMethod,
                       context: context,
                       fields: fields,
                       configuration: configuration)
        }
        
        @_spi(AdyenInternal)
        override public func submitButtonTitle() -> String {
            localizedString(.boletobancarioBtnLabel, configuration.localizationParameters)
        }
        
        @_spi(AdyenInternal)
        override public func createPaymentDetails() -> PaymentMethodDetails {
            onCreatePaymentDetails() ?? InstantPaymentDetails(type: paymentMethod.type)
        }
    }
}
