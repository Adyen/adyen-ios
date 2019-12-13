//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class ComponentManager {
    
    internal init(paymentMethods: PaymentMethods, payment: Payment?, configuration: DropInComponent.PaymentMethodsConfiguration) {
        self.paymentMethods = paymentMethods
        self.payment = payment
        self.configuration = configuration
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
    
    private let paymentMethods: PaymentMethods
    private let payment: Payment?
    private let configuration: DropInComponent.PaymentMethodsConfiguration
    
    private func component(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        var paymentComponent: PaymentComponent?
        
        switch paymentMethod {
        case let paymentMethod as StoredCardPaymentMethod:
            paymentComponent = createCardComponent(with: paymentMethod)
        case let paymentMethod as StoredPaymentMethod:
            paymentComponent = StoredPaymentMethodComponent(paymentMethod: paymentMethod)
        case let paymentMethod as StoredBCMCPaymentMethod:
            paymentComponent = StoredPaymentMethodComponent(paymentMethod: paymentMethod)
        case let paymentMethod as CardPaymentMethod:
            paymentComponent = createCardComponent(with: paymentMethod)
        case let paymentMethod as BCMCPaymentMethod:
            paymentComponent = createBancontactComponent(with: paymentMethod)
        case let paymentMethod as IssuerListPaymentMethod:
            paymentComponent = IssuerListComponent(paymentMethod: paymentMethod)
        case let paymentMethod as SEPADirectDebitPaymentMethod:
            paymentComponent = SEPADirectDebitComponent(paymentMethod: paymentMethod)
        case let paymentMethod as ApplePayPaymentMethod:
            paymentComponent = createApplePayComponent(with: paymentMethod)
        default:
            paymentComponent = EmptyPaymentComponent(paymentMethod: paymentMethod)
        }
        
        if var paymentComponent = paymentComponent as? Localizable {
            paymentComponent.localizationTable = configuration.localizationTable
        }
        
        return paymentComponent
    }
    
    private func createCardComponent(with paymentMethod: PaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        guard let publicKey = cardConfiguration.publicKey else {
            return nil
        }
        
        let cardComponent: CardComponent
        if let cardPaymentMethod = paymentMethod as? CardPaymentMethod {
            cardComponent = CardComponent(paymentMethod: cardPaymentMethod, publicKey: publicKey)
        } else if let storedCardPaymentMethod = paymentMethod as? StoredCardPaymentMethod {
            cardComponent = CardComponent(paymentMethod: storedCardPaymentMethod, publicKey: publicKey)
        } else {
            return nil
        }
        
        cardComponent.showsHolderNameField = cardConfiguration.showsHolderNameField
        cardComponent.showsStorePaymentMethodField = cardConfiguration.showsStorePaymentMethodField
        
        return cardComponent
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        guard let publicKey = cardConfiguration.publicKey else { return nil }
        
        let component = BCMCComponent(paymentMethod: paymentMethod, publicKey: publicKey)
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
        
        do {
            return try ApplePayComponent(paymentMethod: paymentMethod,
                                         payment: payment,
                                         merchantIdentifier: identfier,
                                         summaryItems: summaryItems)
        } catch {
            print("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }
    
}
