//
// Copyright (c) 2019 Adyen N.V.
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
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation

internal protocol ComponentManaging {
    var sections: [PaymentMethodsSection] { get }
    func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent?
}

// TODO: - The ComponentManager should use the factories that Eren introduced in components.
internal final class ComponentManager: ComponentManaging {

    // MARK: - Properties

    internal let paymentMethods: PaymentMethods
    internal let configuration: DropInComponent.Configuration
    internal let context: AdyenContext
    internal let order: PartialPaymentOrder?
    internal let partialPaymentEnabled: Bool
    internal weak var presentationDelegate: PresentationDelegate?
    
    private let supportsEditingStoredPaymentMethods: Bool
    
    private var localizationParameters: LocalizationParameters? {
        configuration.localizationParameters
    }
    
    private var listStyle: ListComponentStyle {
        configuration.style.listComponent
    }

    // MARK: - Initializer
    
    internal init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        partialPaymentEnabled: Bool = true,
        order: PartialPaymentOrder?,
        supportsEditingStoredPaymentMethods: Bool = false,
        presentationDelegate: PresentationDelegate?
    ) {
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.partialPaymentEnabled = partialPaymentEnabled
        self.order = order
        self.supportsEditingStoredPaymentMethods = supportsEditingStoredPaymentMethods
        self.presentationDelegate = presentationDelegate

        updateContextPaymentIfNeeded()
    }
    
    // MARK: - ComponentManaging
    
    internal lazy var sections: [PaymentMethodsSection] = {
        [paidSection, storedSection, regularSection].filter { !$0.paymentMethods.isEmpty }
    }()

    internal func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard isAllowed(paymentMethod) else {
            AdyenAssertion.assertionFailure(message: """
            For voucher payment methods like \(paymentMethod.name) it is required to add a suitable \
            text for the key NSPhotoLibraryAddUsageDescription in the Application Info.plist, to enable \
            the shopper to save the voucher to their photo library.
            """)
            return nil
        }

        guard var paymentComponent = paymentMethod.buildComponent(using: self) else { return nil }
        paymentComponent.order = order

        if var localizableComponent = paymentComponent as? Localizable {
            localizableComponent.localizationParameters = localizationParameters
        }

        return paymentComponent
    }
    
    // MARK: - Computed Components

    internal lazy var storedComponents: [PaymentComponent] = {
        paymentMethods.stored
            .filter { $0.supportedShopperInteractions.contains(.shopperPresent) }
            .compactMap(buildComponent(for:))
    }()

    internal lazy var regularComponents: [PaymentComponent] = {
        paymentMethods.regular.compactMap(buildComponent(for:))
    }()

    internal lazy var paidComponents: [PaymentComponent] = {
        paymentMethods.paid.compactMap(buildComponent(for:))
    }()
    
    internal var singleRegularComponent: (PaymentComponent & PresentableComponent)? {
        guard storedComponents.isEmpty,
              paidComponents.isEmpty,
              regularComponents.count == 1,
              let component = regularComponents.first as? (PaymentComponent & PresentableComponent)
        else { return nil }
        
        return component
    }
}

// MARK: - Private

private extension ComponentManager {
    
    func updateContextPaymentIfNeeded() {
        guard let payment = context.payment,
              let remainingAmount = order?.remainingAmount else { return }
        
        let updatedPayment = Payment(amount: remainingAmount, countryCode: payment.countryCode)
        context.update(payment: updatedPayment)
    }
    
    // MARK: - Section Builders
    
    var paidSection: PaymentMethodsSection {
        let amountString = order?.remainingAmount.map(\.formatted)
            ?? localizedString(.amount, localizationParameters).lowercased()
        
        let footerTitle = localizedString(
            .partialPaymentPayRemainingAmount,
            localizationParameters,
            amountString
        )
        
        return PaymentMethodsSection(
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsPaidMethods, localizationParameters),
                style: listStyle.sectionHeader
            ),
            paymentMethods: paymentMethods.paid,
            footer: ListSectionFooter(title: footerTitle, style: listStyle.partialPaymentSectionFooter)
        )
    }
    
    var storedSection: PaymentMethodsSection {
        let allowDeleting = configuration.paymentMethodsList.allowDisablingStoredPaymentMethods
            && supportsEditingStoredPaymentMethods
        
        return PaymentMethodsSection(
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsStoredMethods, localizationParameters),
                editingStyle: allowDeleting ? .delete : .none,
                style: listStyle.sectionHeader
            ),
            paymentMethods: paymentMethods.stored,
            footer: nil
        )
    }
    
    var regularSection: PaymentMethodsSection {
        let needsHeader = !paidSection.paymentMethods.isEmpty || !storedSection.paymentMethods.isEmpty
        
        let header: ListSectionHeader? = needsHeader
            ? ListSectionHeader(
                title: localizedString(.paymentMethodsOtherMethods, localizationParameters),
                style: listStyle.sectionHeader
            )
            : nil
        
        return PaymentMethodsSection(
            header: header,
            paymentMethods: paymentMethods.regular,
            footer: nil
        )
    }
    
    // MARK: - Payment Method Validation
    
    func isAllowed(_ paymentMethod: PaymentMethod) -> Bool {
        let requiresPhotoLibrary = isVoucherPaymentMethod(paymentMethod) || isQRCodePaymentMethod(paymentMethod)
        guard requiresPhotoLibrary else { return true }
        
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription") != nil
    }

    func isQRCodePaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        QRCodePaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }

    func isVoucherPaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }
}
