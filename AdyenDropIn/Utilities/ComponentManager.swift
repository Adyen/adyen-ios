//
// Copyright (c) 2022 Adyen N.V.
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

    private let partialPaymentEnabled: Bool
    
    private let supportsEditingStoredPaymentMethods: Bool

    internal let remainingAmount: Amount?

    internal let order: PartialPaymentOrder?
    
    internal let apiContext: APIContext

    internal weak var presentationDelegate: PresentationDelegate?
    
    internal init(paymentMethods: PaymentMethods,
                  configuration: DropInComponent.Configuration,
                  partialPaymentEnabled: Bool = true,
                  remainingAmount: Amount? = nil,
                  order: PartialPaymentOrder?,
                  supportsEditingStoredPaymentMethods: Bool = false,
                  presentationDelegate: PresentationDelegate) {
        self.paymentMethods = paymentMethods
        self.configuration = configuration
        self.apiContext = configuration.apiContext
        self.partialPaymentEnabled = partialPaymentEnabled
        self.remainingAmount = remainingAmount
        self.order = order
        self.supportsEditingStoredPaymentMethods = supportsEditingStoredPaymentMethods
        self.presentationDelegate = presentationDelegate
    }
    
    // MARK: - Internal
    
    internal lazy var sections: [ComponentsSection] = {

        // Paid section
        let amountString: String = remainingAmount.map(\.formatted) ??
            localizedString(.amount, configuration.localizationParameters).lowercased()
        let footerTitle = localizedString(.partialPaymentPayRemainingAmount,
                                          configuration.localizationParameters,
                                          amountString)
        let paidFooter = ListSectionFooter(title: footerTitle,
                                           style: configuration.style.listComponent.partialPaymentSectionFooter)
        let paidSection = ComponentsSection(header: nil,
                                            components: paidComponents,
                                            footer: paidFooter)

        // Stored section
        let storedSection: ComponentsSection
        
        if supportsEditingStoredPaymentMethods {
            let allowDeleting = configuration.paymentMethodsList.allowDisablingStoredPaymentMethods
            let editingStyle: EditingStyle = allowDeleting ? .delete : .none
            storedSection = ComponentsSection(header: .init(title: localizedString(.paymentMethodsStoredMethods,
                                                                                   configuration.localizationParameters),
                                                            editingStyle: editingStyle,
                                                            style: ListSectionHeaderStyle()),
                                              components: storedComponents,
                                              footer: nil)
        } else {
            storedSection = ComponentsSection(components: storedComponents)
        }
        
        // Regular section
        let localizedTitle = localizedString(.paymentMethodsOtherMethods, configuration.localizationParameters)
        let regularSectionTitle = storedSection.components.isEmpty ? nil : localizedTitle
        let regularHeader: ListSectionHeader? = regularSectionTitle.map {
            ListSectionHeader(title: $0, style: configuration.style.listComponent.sectionHeader)
        }
        let regularSection = ComponentsSection(header: regularHeader, components: regularComponents, footer: nil)
        
        return [paidSection, storedSection, regularSection].filter {
            $0.components.isEmpty == false
        }
    }()

    // Filter out payment methods without the Ecommerce shopper interaction.
    internal lazy var storedComponents: [PaymentComponent] = paymentMethods.stored.filter {
        $0.supportedShopperInteractions.contains(.shopperPresent)
    }.compactMap(component(for:))

    internal lazy var regularComponents = paymentMethods.regular.compactMap(component(for:))

    internal lazy var paidComponents = paymentMethods.paid.compactMap(component(for:))
    
    /// Returns the only regular component that is not an instant payment,
    /// when no other payment method exists.
    internal var singleRegularComponent: (PaymentComponent & PresentableComponent)? {
        guard storedComponents.isEmpty,
              paidComponents.isEmpty,
              regularComponents.count == 1,
              let regularComponent = regularComponents.first as? (PaymentComponent & PresentableComponent) else { return nil }
        return regularComponent
    }
    
    // MARK: - Private
    
    private func component(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard isAllowed(paymentMethod) else {
            // swiftlint:disable:next line_length
            AdyenAssertion.assertionFailure(message: "For voucher payment methods like \(paymentMethod.name) it is required to add a suitable text for the key NSPhotoLibraryAddUsageDescription in the Application Info.plist, to enable the shopper to save the voucher to their photo library.")
            return nil
        }

        guard let paymentComponent = paymentMethod.buildComponent(using: self) else { return nil }

        if var paymentComponent = paymentComponent as? Localizable {
            paymentComponent.localizationParameters = configuration.localizationParameters
        }

        paymentComponent.payment = configuration.payment
        paymentComponent.order = order
        return paymentComponent
    }

    private func isAllowed(_ paymentMethod: PaymentMethod) -> Bool {
        guard isVoucherPaymentMethod(paymentMethod) else { return true }
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription") != nil
    }

    private func isVoucherPaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }
    
    // MARK: - Private
    
    private let paymentMethods: PaymentMethods
    private let configuration: DropInComponent.Configuration
    
    private func createCardComponent(with paymentMethod: AnyCardPaymentMethod) -> PaymentComponent? {
        var cardConfiguration = configuration.card.cardComponentConfiguration
        cardConfiguration.style = configuration.style.formComponent
        cardConfiguration.localizationParameters = configuration.localizationParameters
        cardConfiguration.shopperInformation = configuration.shopper
        return CardComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: cardConfiguration)
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        let configuration = CardComponent.Configuration(style: configuration.style.formComponent,
                                                        shopperInformation: configuration.shopper,
                                                        localizationParameters: configuration.localizationParameters,
                                                        showsHolderNameField: cardConfiguration.showsHolderNameField,
                                                        showsStorePaymentMethodField: cardConfiguration.showsStorePaymentMethodField,
                                                        showsSecurityCodeField: cardConfiguration.showsSecurityCodeField,
                                                        storedCardConfiguration: cardConfiguration.stored)

        return BCMCComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: configuration)
    }
    
    private func createPreApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        guard let applePay = configuration.applePay else {
            adyenPrint("Failed to instantiate ApplePayComponent because ApplePayConfiguration is missing")
            return nil
        }
        
        do {
            let preApplePayConfig = PreApplePayComponent.Configuration(style: configuration.style.applePay,
                                                                       localizationParameters: configuration.localizationParameters)
            return try PreApplePayComponent(paymentMethod: paymentMethod,
                                            apiContext: apiContext,
                                            configuration: preApplePayConfig,
                                            applePayConfiguration: applePay)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        let config = SEPADirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                            localizationParameters: configuration.localizationParameters)
        return SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                        apiContext: apiContext,
                                        configuration: config)
    }

    private func createBACSDirectDebit(_ paymentMethod: BACSDirectDebitPaymentMethod) -> BACSDirectDebitComponent {
        let bacsConfiguration = BACSDirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                                       localizationParameters: configuration.localizationParameters)

        let bacsDirectDebitComponent = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                                                apiContext: apiContext,
                                                                configuration: bacsConfiguration)
        bacsDirectDebitComponent.presentationDelegate = presentationDelegate
        return bacsDirectDebitComponent
    }
    
    private func createACHDirectDebitComponent(_ paymentMethod: ACHDirectDebitPaymentMethod) -> ACHDirectDebitComponent {
        let config = ACHDirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                           shopperInformation: configuration.shopper,
                                                           localizationParameters: configuration.localizationParameters)
        return ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext,
                                       configuration: config)
    }
    
    private func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        let config = QiwiWalletComponent.Configuration(style: configuration.style.formComponent,
                                                       shopperInformation: configuration.shopper,
                                                       localizationParameters: configuration.localizationParameters)
        return QiwiWalletComponent(paymentMethod: paymentMethod,
                                   apiContext: apiContext, configuration: config)
    }
    
    private func createMBWayComponent(_ paymentMethod: MBWayPaymentMethod) -> MBWayComponent? {
        let config = MBWayComponent.Configuration(style: configuration.style.formComponent,
                                                  shopperInformation: configuration.shopper,
                                                  localizationParameters: configuration.localizationParameters)
        return MBWayComponent(paymentMethod: paymentMethod,
                              apiContext: apiContext, configuration: config)
    }

    private func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        BLIKComponent(paymentMethod: paymentMethod,
                      apiContext: apiContext,
                      configuration: .init(style: configuration.style.formComponent,
                                           localizationParameters: configuration.localizationParameters))
    }
    
    private func createBoletoComponent(_ paymentMethod: BoletoPaymentMethod) -> BoletoComponent {
        BoletoComponent(paymentMethod: paymentMethod,
                        apiContext: apiContext,
                        configuration: BoletoComponent.Configuration(style: configuration.style.formComponent,
                                                                     localizationParameters: configuration.localizationParameters,
                                                                     shopperInformation: configuration.shopper,
                                                                     showEmailAddress: true))
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
        StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
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
                            apiContext: apiContext,
                            configuration: .init(style: configuration.style.listComponent,
                                                 localizationParameters: configuration.localizationParameters))
    }
    
    /// :nodoc:
    internal func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        createSEPAComponent(paymentMethod)
    }

    /// :nodoc:
    internal func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent? {
        createBACSDirectDebit(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent? {
        createACHDirectDebitComponent(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        createPreApplePayComponent(with: paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent? {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else { return nil }
        guard classObject.isDeviceSupported() else { return nil }
        return InstantPaymentComponent(paymentMethod: paymentMethod,
                                       paymentData: nil,
                                       apiContext: apiContext)
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
    internal func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent? {
        let config = BasicPersonalInfoFormComponent.Configuration(style: configuration.style.formComponent,
                                                                  shopperInformation: configuration.shopper,
                                                                  localizationParameters: configuration.localizationParameters)
        return BasicPersonalInfoFormComponent(paymentMethod: paymentMethod,
                                              apiContext: apiContext,
                                              configuration: config)
    }

    /// :nodoc:
    internal func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? {
        let config = DokuComponent.Configuration(style: configuration.style.formComponent,
                                                 shopperInformation: configuration.shopper,
                                                 localizationParameters: configuration.localizationParameters)
        return DokuComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: config)
    }

    /// :nodoc:
    internal func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent? {
        guard partialPaymentEnabled else { return nil }
        return GiftCardComponent(paymentMethod: paymentMethod,
                                 apiContext: apiContext,
                                 style: configuration.style.formComponent)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent? {
        createBoletoComponent(paymentMethod)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent? {
        let config = AffirmComponent.Configuration(style: configuration.style.formComponent,
                                                   shopperInformation: configuration.shopper,
                                                   localizationParameters: configuration.localizationParameters)
        return AffirmComponent(paymentMethod: paymentMethod,
                               apiContext: apiContext,
                               configuration: config)
    }
    
    /// :nodoc:
    internal func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        InstantPaymentComponent(paymentMethod: paymentMethod,
                                paymentData: nil,
                                apiContext: apiContext)
    }

    /// :nodoc:
    internal func build(paymentMethod: AtomePaymentMethod) -> PaymentComponent? {
        let config = AtomeComponent.Configuration(style: configuration.style.formComponent,
                                                  shopperInformation: configuration.shopper,
                                                  localizationParameters: configuration.localizationParameters)
        return AtomeComponent(paymentMethod: paymentMethod,
                              apiContext: apiContext,
                              configuration: config)
    }

}
