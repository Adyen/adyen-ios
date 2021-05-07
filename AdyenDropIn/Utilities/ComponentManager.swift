//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation

internal final class ComponentManager {
    
    /// Indicates the UI configuration of the drop in component.
    private var style: DropInComponent.Style
    
    /// Defines the environment used to make networking requests.
    internal var environment: Environment = .live
    
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
        
        paymentComponent?.clientKey = configuration.clientKey
        paymentComponent?.environment = environment
        
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
        
        guard let paymentMethod = paymentMethod as? AnyCardPaymentMethod else { return nil }
        
        var cardComponent: CardComponent?
        
        if let clientKey = configuration.clientKey {
            cardComponent = CardComponent(paymentMethod: paymentMethod,
                                          clientKey: clientKey,
                                          style: style.formComponent)
            
        } else if let publicKey = configuration.card.deprecatedPublicKey {
            cardComponent = CardComponent.component(paymentMethod: paymentMethod,
                                                    publicKey: publicKey,
                                                    style: style.formComponent)
        } else {
            adyenPrint("Failed to instantiate CardComponent because client key is not configured.")
            return nil
        }
        
        cardComponent?.showsHolderNameField = cardConfiguration.showsHolderNameField
        cardComponent?.showsStorePaymentMethodField = cardConfiguration.showsStorePaymentMethodField
        cardComponent?.showsSecurityCodeField = cardConfiguration.showsSecurityCodeField
        cardComponent?.storedCardConfiguration = cardConfiguration.stored
        
        return cardComponent
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        
        var component: BCMCComponent?
        
        if let clientKey = configuration.clientKey {
            component = BCMCComponent(paymentMethod: paymentMethod,
                                      clientKey: clientKey,
                                      style: style.formComponent)
            
        } else if let publicKey = configuration.card.deprecatedPublicKey {
            component = BCMCComponent.component(paymentMethod: paymentMethod,
                                                publicKey: publicKey,
                                                style: style.formComponent)
        } else {
            adyenPrint("Failed to instantiate BCMCComponent because client key is not configured.")
            return nil
        }
        
        component?.showsHolderNameField = cardConfiguration.showsHolderNameField
        component?.showsStorePaymentMethodField = cardConfiguration.showsStorePaymentMethodField
        
        return component
    }
    
    private func createApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        guard let payment = payment else {
            adyenPrint("Failed to instantiate ApplePayComponent: no payment specified.")
            return nil
        }

        guard let configuration = configuration.applePay.componentConfiguration() else {
            adyenPrint("Failed to instantiate ApplePayComponent: ApplePayConfiguration is missing summary items or MerchantIden ID")
            return nil
        }

        do {
            return try PreApplePayComponent(payment: payment, paymentMethod: paymentMethod, configuration: configuration)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent: \(error)")
            return nil
        }
    }
    
    private func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                 style: style.formComponent)
    }
    
    private func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        QiwiWalletComponent(paymentMethod: paymentMethod, style: style.formComponent)
    }
    
    private func createMBWayComponent(_ paymentMethod: MBWayPaymentMethod) -> MBWayComponent? {
        guard configuration.clientKey != nil else {
            // swiftlint:disable:next line_length
            adyenPrint("Failed to instantiate MBWayComponent because client key is not configured. Please supply the client key in the PaymentMethodsConfiguration.")
            return nil
        }
        return MBWayComponent(paymentMethod: paymentMethod, style: style.formComponent)
    }

    private func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        guard configuration.clientKey != nil else {
            // swiftlint:disable:next line_length
            adyenPrint("Failed to instantiate BLIKComponent because client key is not configured. Please supply the client key in the PaymentMethodsConfiguration.")
            return nil
        }

        return BLIKComponent(paymentMethod: paymentMethod, style: style.formComponent)
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
        createSEPAComponent(paymentMethod)
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
    internal func build(paymentMethod: MBWayPaymentMethod) -> PaymentComponent? {
        createMBWayComponent(paymentMethod)
    }

    /// :nodoc:
    internal func build(paymentMethod: BLIKPaymentMethod) -> PaymentComponent? {
        createBLIKComponent(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
    
}

extension DropInComponent.PaymentMethodsConfiguration.ApplePayConfiguration {

    fileprivate func componentConfiguration() -> ApplePayComponent.Configuration? {
        guard let summaryItems = summaryItems, let merchantIdentifier = merchantIdentifier else {
            return nil
        }

        return ApplePayComponent.Configuration(summaryItems: summaryItems,
                                               merchantIdentifier: merchantIdentifier,
                                               requiredBillingContactFields: requiredBillingContactFields,
                                               requiredShippingContactFields: requiredShippingContactFields,
                                               excludedCardNetworks: excludedCardNetworks)
    }

}
