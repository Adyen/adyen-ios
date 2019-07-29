//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class ComponentManager {
    
    internal init(paymentMethods: PaymentMethods, configuration: DropInComponent.PaymentMethodsConfiguration) {
        self.paymentMethods = paymentMethods
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
    private let configuration: DropInComponent.PaymentMethodsConfiguration
    
    private func component(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        switch paymentMethod {
        case let paymentMethod as StoredCardPaymentMethod:
            return createCardComponent(with: paymentMethod)
        case let paymentMethod as StoredPaymentMethod:
            return StoredPaymentMethodComponent(paymentMethod: paymentMethod)
        case let paymentMethod as CardPaymentMethod:
            return createCardComponent(with: paymentMethod)
        case let paymentMethod as IssuerListPaymentMethod:
            return IssuerListComponent(paymentMethod: paymentMethod)
        case let paymentMethod as SEPADirectDebitPaymentMethod:
            return SEPADirectDebitComponent(paymentMethod: paymentMethod)
        case let paymentMethod as ApplePayPaymentMethod:
            return createApplePayComponent(with: paymentMethod)
        default:
            return EmptyPaymentComponent(paymentMethod: paymentMethod)
        }
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
    
    private func createApplePayComponent(with paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard let summaryItems = configuration.applePay.summaryItems, let identfier = configuration.applePay.merchantIdentifier else {
            return nil
        }
        
        return ApplePayComponent(paymentMethod: paymentMethod, merchantIdentifier: identfier, summaryItems: summaryItems)
    }
    
}
