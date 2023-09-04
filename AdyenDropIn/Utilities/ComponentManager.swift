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

final class ComponentManager {

    /// Indicates the UI configuration of the drop in component.
    private var style: DropInComponent.Style

    private let partialPaymentEnabled: Bool
    
    private let supportsEditingStoredPaymentMethods: Bool

    let remainingAmount: Amount?

    let order: PartialPaymentOrder?
    
    let apiContext: APIContext

    weak var presentationDelegate: PresentationDelegate?
    
    init(paymentMethods: PaymentMethods,
         configuration: DropInComponent.Configuration,
         style: DropInComponent.Style,
         partialPaymentEnabled: Bool = true,
         remainingAmount: Amount? = nil,
         order: PartialPaymentOrder?,
         supportsEditingStoredPaymentMethods: Bool = false,
         presentationDelegate: PresentationDelegate) {
        self.paymentMethods = paymentMethods
        self.configuration = configuration
        self.apiContext = configuration.apiContext
        self.style = style
        self.partialPaymentEnabled = partialPaymentEnabled
        self.remainingAmount = remainingAmount
        self.order = order
        self.supportsEditingStoredPaymentMethods = supportsEditingStoredPaymentMethods
        self.presentationDelegate = presentationDelegate
    }
    
    // MARK: - Internal
    
    lazy var sections: [ComponentsSection] = {

        // Paid section
        let amountString: String = remainingAmount.map(\.formatted) ??
            localizedString(.amount, configuration.localizationParameters).lowercased()
        let footerTitle = localizedString(.partialPaymentPayRemainingAmount,
                                          configuration.localizationParameters,
                                          amountString)
        let paidFooter = ListSectionFooter(title: footerTitle,
                                           style: style.listComponent.partialPaymentSectionFooter)
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
            ListSectionHeader(title: $0, style: style.listComponent.sectionHeader)
        }
        let regularSection = ComponentsSection(header: regularHeader, components: regularComponents, footer: nil)
        
        return [paidSection, storedSection, regularSection].filter {
            $0.components.isEmpty == false
        }
    }()

    // Filter out payment methods without the Ecommerce shopper interaction.
    lazy var storedComponents: [PaymentComponent] = paymentMethods.stored.filter {
        $0.supportedShopperInteractions.contains(.shopperPresent)
    }.compactMap(component(for:))

    lazy var regularComponents = paymentMethods.regular.compactMap(component(for:))

    lazy var paidComponents = paymentMethods.paid.compactMap(component(for:))
    
    /// Returns the only regular component that is not an instant payment,
    /// when no other payment method exists.
    var singleRegularComponent: (PaymentComponent & PresentableComponent)? {
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
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type)
    }
    
    // MARK: - Private
    
    private let paymentMethods: PaymentMethods
    private let configuration: DropInComponent.Configuration
    
    private func createCardComponent(with paymentMethod: AnyCardPaymentMethod) -> PaymentComponent? {
        CardComponent(paymentMethod: paymentMethod,
                      apiContext: apiContext,
                      configuration: configuration.card,
                      shopperInformation: configuration.shopper,
                      style: style.formComponent)
    }
    
    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        let configuration = CardComponent.Configuration(showsHolderNameField: cardConfiguration.showsHolderNameField,
                                                        showsStorePaymentMethodField: cardConfiguration.showsStorePaymentMethodField,
                                                        showsSecurityCodeField: cardConfiguration.showsSecurityCodeField,
                                                        storedCardConfiguration: cardConfiguration.stored)

        return BCMCComponent(paymentMethod: paymentMethod,
                             configuration: configuration,
                             apiContext: apiContext,
                             style: style.formComponent)
    }
    
    private func createPreApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        guard var applePay = configuration.applePay else {
            adyenPrint("Failed to instantiate ApplePayComponent because ApplePayConfiguration is missing")
            return nil
        }
        
        guard let payment = configuration.payment else {
            adyenPrint("Failed to instantiate ApplePayComponent because payment is missing")
            return nil
        }

        if let amount = order?.remainingAmount ?? remainingAmount {
            let localeIdentifier = amount.localeIdentifier ?? configuration.localizationParameters?.locale
            applePay.update(amount: amount, localeIdentifier: localeIdentifier)
            if let component = try? PreApplePayComponent(paymentMethod: paymentMethod,
                                                         apiContext: apiContext,
                                                         payment: Payment(amount: amount,
                                                                          countryCode: payment.countryCode),
                                                         configuration: applePay,
                                                         style: style.applePay) {
                return component
            }
        }
        
        do {
            return try PreApplePayComponent(paymentMethod: paymentMethod,
                                            apiContext: apiContext,
                                            payment: payment,
                                            configuration: applePay,
                                            style: style.applePay)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                 apiContext: apiContext,
                                 style: style.formComponent)
    }

    private func createBACSDirectDebit(_ paymentMethod: BACSDirectDebitPaymentMethod) -> BACSDirectDebitComponent {
        var bacsConfiguration: BACSDirectDebitComponent.Configuration?
        if let payment = configuration.payment {
            bacsConfiguration = .init(payment: payment)
        }

        let bacsDirectDebitComponent = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                                                apiContext: apiContext,
                                                                configuration: bacsConfiguration)
        bacsDirectDebitComponent.presentationDelegate = presentationDelegate
        return bacsDirectDebitComponent
    }
    
    private func createACHDirectDebitComponent(_ paymentMethod: ACHDirectDebitPaymentMethod) -> ACHDirectDebitComponent {
        ACHDirectDebitComponent(configuration: ACHDirectDebitComponent.Configuration(),
                                paymentMethod: paymentMethod,
                                apiContext: apiContext,
                                shopperInformation: configuration.shopper,
                                localizationParameters: configuration.localizationParameters,
                                style: style.formComponent)
    }
    
    private func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        QiwiWalletComponent(paymentMethod: paymentMethod,
                            apiContext: apiContext,
                            style: style.formComponent)
    }
    
    private func createMBWayComponent(_ paymentMethod: MBWayPaymentMethod) -> MBWayComponent? {
        MBWayComponent(paymentMethod: paymentMethod,
                       apiContext: apiContext,
                       shopperInformation: configuration.shopper,
                       style: style.formComponent)
    }

    private func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        BLIKComponent(paymentMethod: paymentMethod,
                      apiContext: apiContext,
                      style: style.formComponent)
    }
    
    private func createBoletoComponent(_ paymentMethod: BoletoPaymentMethod) -> BoletoComponent {
        BoletoComponent(configuration: .init(boletoPaymentMethod: paymentMethod,
                                             payment: configuration.payment,
                                             shopperInformation: configuration.shopper,
                                             showEmailAddress: true),
                        apiContext: apiContext)
    }
}

// MARK: - PaymentComponentBuilder

extension ComponentManager: PaymentComponentBuilder {
    
    func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }

    func build(paymentMethod: StoredPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
    }

    func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
    }

    func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }

    func build(paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        createBancontactComponent(with: paymentMethod)
    }

    func build(paymentMethod: IssuerListPaymentMethod) -> PaymentComponent? {
        IssuerListComponent(paymentMethod: paymentMethod,
                            apiContext: apiContext,
                            style: style.listComponent)
    }

    func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        createSEPAComponent(paymentMethod)
    }

    func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent? {
        createBACSDirectDebit(paymentMethod)
    }

    func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent? {
        createACHDirectDebitComponent(paymentMethod)
    }

    func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        createPreApplePayComponent(with: paymentMethod)
    }

    func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent? {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else { return nil }
        guard classObject.isDeviceSupported() else { return nil }
        return InstantPaymentComponent(paymentMethod: paymentMethod,
                                       paymentData: nil,
                                       apiContext: apiContext)
    }

    func build(paymentMethod: QiwiWalletPaymentMethod) -> PaymentComponent? {
        createQiwiWalletComponent(paymentMethod)
    }

    func build(paymentMethod: MBWayPaymentMethod) -> PaymentComponent? {
        createMBWayComponent(paymentMethod)
    }

    func build(paymentMethod: BLIKPaymentMethod) -> PaymentComponent? {
        createBLIKComponent(paymentMethod)
    }

    func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent? {
        BasicPersonalInfoFormComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext,
                                       shopperInformation: configuration.shopper,
                                       style: style.formComponent)
    }

    func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? {
        DokuComponent(paymentMethod: paymentMethod,
                      apiContext: apiContext,
                      shopperInformation: configuration.shopper,
                      style: style.formComponent)
    }

    func build(paymentMethod: OXXOPaymentMethod) -> PaymentComponent? {
        InstantPaymentComponent(paymentMethod: paymentMethod,
                                paymentData: nil,
                                apiContext: apiContext)
    }

    func build(paymentMethod: MultibancoPaymentMethod) -> PaymentComponent? {
        InstantPaymentComponent(paymentMethod: paymentMethod,
                                paymentData: nil,
                                apiContext: apiContext)
    }

    func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent? {
        guard partialPaymentEnabled else { return nil }
        return GiftCardComponent(paymentMethod: paymentMethod,
                                 apiContext: apiContext,
                                 style: style.formComponent)
    }

    func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent? {
        createBoletoComponent(paymentMethod)
    }

    func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent? {
        AffirmComponent(paymentMethod: paymentMethod,
                        apiContext: apiContext,
                        shopperInformation: configuration.shopper,
                        style: style.formComponent)
    }

    func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        InstantPaymentComponent(paymentMethod: paymentMethod,
                                paymentData: nil,
                                apiContext: apiContext)
    }

}
