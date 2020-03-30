//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class ComponentManager {
    
    /// Indicates the UI configuration of the drop in component.
    private var style: DropInComponent.Style
    
    internal init(paymentMethods: PaymentMethods,
                  payment: Payment?,
                  configuration: DropInComponent.PaymentMethodsConfiguration,
                  style: DropInComponent.Style) {
        self.paymentMethods = paymentMethods
        self.payment = payment
        self.configuration = configuration
        self.style = style
    }
    
    // MARK: - Internal
    
    internal lazy var components: SectionedComponents = {
        // Filter out payment methods without the Ecommerce shopper interaction.
        let storedPaymentMethods = paymentMethods.stored.filter { $0.supportedShopperInteractions.contains(.shopperPresent) }
        
        return SectionedComponents(
            stored: storedPaymentMethods.compactMap { component(for: $0) },
            regular: paymentMethods.regular.compactMap { component(for: $0) }
        )
    }()
    
    // MARK: - Private
    
    private func component(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        let paymentComponent: PaymentComponent? = paymentMethod.buildComponent(using: self)
        
        if var paymentComponent = paymentComponent as? Localizable {
            paymentComponent.localizationParameters = configuration.localizationParameters
        }
        
        return paymentComponent
    }
    
    // MARK: - Private
    
    private let paymentMethods: PaymentMethods
    private let payment: Payment?
    private let configuration: DropInComponent.PaymentMethodsConfiguration
    
    private func createCardComponent(with paymentMethod: PaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        guard let publicKey = cardConfiguration.publicKey else {
            return nil
        }
        
        let cardComponent: CardComponent
        switch paymentMethod {
        case let cardPaymentMethod as CardPaymentMethod:
            cardComponent = CardComponent(paymentMethod: cardPaymentMethod,
                                          publicKey: publicKey,
                                          style: style.formComponent)
            cardComponent.showsLargeTitle = false
        case let storedCardPaymentMethod as StoredCardPaymentMethod:
            cardComponent = CardComponent(paymentMethod: storedCardPaymentMethod,
                                          publicKey: publicKey,
                                          style: style.formComponent)
        default:
            return nil
        }
        
        cardComponent.showsHolderNameField = cardConfiguration.showsHolderNameField
        cardComponent.showsStorePaymentMethodField = cardConfiguration.showsStorePaymentMethodField
        
        return cardComponent
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        guard let publicKey = cardConfiguration.publicKey else { return nil }
        
        let component = BCMCComponent(paymentMethod: paymentMethod,
                                      publicKey: publicKey,
                                      style: style.formComponent)
        component.showsLargeTitle = false
        component.showsHolderNameField = cardConfiguration.showsHolderNameField
        component.showsStorePaymentMethodField = cardConfiguration.showsStorePaymentMethodField
        
        return component
    }
    
    private func createApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        guard
            let summaryItems = configuration.applePay.summaryItems,
            let identfier = configuration.applePay.merchantIdentifier,
            let payment = payment else {
            return nil
        }
        
        let requiredBillingContactFields = configuration.applePay.requiredBillingContactFields
        let requiredShippingContactFields = configuration.applePay.requiredShippingContactFields
        
        do {
            return try ApplePayComponent(paymentMethod: paymentMethod,
                                         payment: payment,
                                         merchantIdentifier: identfier,
                                         summaryItems: summaryItems,
                                         requiredBillingContactFields: requiredBillingContactFields,
                                         requiredShippingContactFields: requiredShippingContactFields)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 style: style.formComponent)
        component.showsLargeTitle = false
        return component
    }
    
    private func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        let component = QiwiWalletComponent(paymentMethod: paymentMethod, style: style.formComponent)
        component.showsLargeTitle = false
        return component
    }
    
}

// MARK: - PaymentComponentBuilder

extension ComponentManager: PaymentComponentBuilder {
    
    /// :nodoc:
    internal func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: StoredPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        createBancontactComponent(with: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: IssuerListPaymentMethod) -> PaymentComponent? {
        IssuerListComponent(paymentMethod: paymentMethod,
                            style: style.listComponent)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        return createSEPAComponent(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        createApplePayComponent(with: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent? {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else { return nil }
        guard classObject.isDeviceSupported() else { return nil }
        return EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: QiwiWalletPaymentMethod) -> PaymentComponent? {
        createQiwiWalletComponent(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
    
}
