//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation

internal final class ComponentManager {

    internal let paymentMethods: PaymentMethods
    
    internal let configuration: DropInComponent.Configuration

    internal let partialPaymentEnabled: Bool
    
    private let supportsEditingStoredPaymentMethods: Bool

    internal let order: PartialPaymentOrder?
    
    internal let context: AdyenContext

    internal weak var presentationDelegate: PresentationDelegate?
    
    internal init(paymentMethods: PaymentMethods,
                  context: AdyenContext,
                  configuration: DropInComponent.Configuration,
                  partialPaymentEnabled: Bool = true,
                  order: PartialPaymentOrder?,
                  supportsEditingStoredPaymentMethods: Bool = false,
                  presentationDelegate: PresentationDelegate) {
        self.paymentMethods = paymentMethods
        self.configuration = configuration
        self.partialPaymentEnabled = partialPaymentEnabled
        self.order = order
        self.supportsEditingStoredPaymentMethods = supportsEditingStoredPaymentMethods
        self.presentationDelegate = presentationDelegate

        self.context = context
        if let payment = context.payment, let remainingAmount = order?.remainingAmount {
            let payment = Payment(amount: remainingAmount, countryCode: payment.countryCode)
            context.update(payment: payment)
        }
    }
    
    // MARK: - Internal
    
    internal lazy var sections: [ComponentsSection] = {

        // Paid section
        let amountString: String = order?.remainingAmount.map(\.formatted) ??
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

        guard var paymentComponent = paymentMethod.buildComponent(using: self) else { return nil }
        paymentComponent.order = order

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
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }
    
}
