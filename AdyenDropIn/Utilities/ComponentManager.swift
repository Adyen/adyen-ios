//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
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
        guard isAllowed(paymentMethod) else {
            // swiftlint:disable:next line_length
            assertionFailure("For voucher payment methods like \(paymentMethod.name) it is required to add a suitable text for the key NSPhotoLibraryAddUsageDescription in the Application Info.plist, to enable the shopper to save the voucher to their photo library.")
            return nil
        }
        let paymentComponent: PaymentComponent? = paymentMethod.buildComponent(using: self)
        
        paymentComponent?.clientKey = configuration.clientKey
        paymentComponent?.environment = environment
        
        if var paymentComponent = paymentComponent as? Localizable {
            paymentComponent.localizationParameters = configuration.localizationParameters
        }
        
        return paymentComponent
    }

    private func isAllowed(_ paymentMethod: PaymentMethod) -> Bool {
        guard isVoucherPaymentMethod(paymentMethod) else { return true }
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription") != nil
    }

    private func isVoucherPaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type)
    }
    
    // MARK: - Private
    
    private let paymentMethods: PaymentMethods
    private let payment: Payment?
    private let configuration: DropInComponent.PaymentMethodsConfiguration
    
    private func createCardComponent(with paymentMethod: AnyCardPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        let clientKey = configuration.clientKey
        let configuration = CardComponent.Configuration(showsHolderNameField: cardConfiguration.showsHolderNameField,
                                                        showsStorePaymentMethodField: cardConfiguration.showsStorePaymentMethodField,
                                                        showsSecurityCodeField: cardConfiguration.showsSecurityCodeField,
                                                        storedCardConfiguration: cardConfiguration.stored,
                                                        supportedCardTypes: nil)

        return CardComponent(paymentMethod: paymentMethod,
                             configuration: configuration,
                             clientKey: clientKey,
                             style: style.formComponent)
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        let clientKey = configuration.clientKey
        let configuration = CardComponent.Configuration(showsHolderNameField: cardConfiguration.showsHolderNameField,
                                                        showsStorePaymentMethodField: cardConfiguration.showsStorePaymentMethodField,
                                                        showsSecurityCodeField: cardConfiguration.showsSecurityCodeField,
                                                        storedCardConfiguration: cardConfiguration.stored,
                                                        supportedCardTypes: nil)

        return BCMCComponent(paymentMethod: paymentMethod,
                             configuration: configuration,
                             clientKey: clientKey,
                             style: style.formComponent)
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
            let configuration = ApplePayComponent.Configuration(payment: payment,
                                                                paymentMethod: paymentMethod,
                                                                summaryItems: summaryItems,
                                                                merchantIdentifier: identfier,
                                                                requiredBillingContactFields: requiredBillingContactFields,
                                                                requiredShippingContactFields: requiredShippingContactFields)
            return try ApplePayComponent(configuration: configuration)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
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
        MBWayComponent(paymentMethod: paymentMethod, style: style.formComponent)
    }

    private func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        BLIKComponent(paymentMethod: paymentMethod, style: style.formComponent)
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
    internal func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? {
        DokuComponent(paymentMethod: paymentMethod,
                      style: style.formComponent)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
    
}
