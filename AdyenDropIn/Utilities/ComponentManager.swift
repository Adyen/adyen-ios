//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import struct AdyenUI.ListSection
#endif
import Foundation

@MainActor
internal protocol ComponentManaging {
    var sections: [PaymentMethodsSection] { get }
    func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent?
    func removeStoredPaymentMethod(withIdentifier identifier: String)
}

// TODO: - The ComponentManager should use the factories that Eren introduced in components.
@MainActor
internal final class ComponentManager: ComponentManaging {

    // MARK: - Properties

    internal private(set) var paymentMethods: PaymentMethods
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

        updateContextAmountIfNeeded()
    }
    
    // MARK: - ComponentManaging
    
    internal var sections: [PaymentMethodsSection] {
        [paidSection, storedSection, regularSection].filter { !$0.paymentMethods.isEmpty }
    }

    internal func removeStoredPaymentMethod(withIdentifier identifier: String) {
        paymentMethods.stored.removeAll { $0.identifier == identifier }
    }

    internal func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard isAllowed(paymentMethod) else {
            AdyenAssertion.assertionFailure(message: """
            For voucher payment methods like \(paymentMethod.name) it is required to add a suitable \
            text for the key NSPhotoLibraryAddUsageDescription in the Application Info.plist, to enable \
            the shopper to save the voucher to their photo library.
            """)
            return nil
        }

        let component: PaymentComponent? = {
            if let buildable = paymentMethod as? any PaymentComponentBuildable {
                buildable.buildComponent(using: self)
            } else {
                build(paymentMethod: paymentMethod)
            }
        }()
        guard var paymentComponent = component else { return nil }
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
    
    internal var singleRegularComponent: PresentablePaymentComponent? {
        guard storedComponents.isEmpty,
              paidComponents.isEmpty,
              regularComponents.count == 1,
              let component = regularComponents.first as? PresentablePaymentComponent
        else { return nil }
        
        return component
    }

    // MARK: - Private

    private lazy var paidSection: PaymentMethodsSection = {
        let amountString = order?.remainingAmount.map(\.formatted)
            ?? localizedString(.amount, localizationParameters).lowercased()

        let footerTitle = localizedString(
            .partialPaymentPayRemainingAmount,
            localizationParameters,
            amountString
        )

        return PaymentMethodsSection(
            kind: .paid,
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsPaidMethods, localizationParameters),
                style: listStyle.sectionHeader
            ),
            paymentMethods: paymentMethods.paid
        )
    }()

    private var storedSection: PaymentMethodsSection {
        let allowDeleting = configuration.paymentMethodsList.allowDisablingStoredPaymentMethods
            && supportsEditingStoredPaymentMethods

        let storedPaymentMethods = paymentMethods.stored
            .filter { $0.supportedShopperInteractions.contains(.shopperPresent) }

        return PaymentMethodsSection(
            kind: .stored,
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsStoredMethods, localizationParameters),
                editingStyle: allowDeleting ? .delete : .none,
                style: listStyle.sectionHeader
            ),
            paymentMethods: storedPaymentMethods
        )
    }

    private var regularSection: PaymentMethodsSection {
        let needsHeader = !paidSection.paymentMethods.isEmpty || !storedSection.paymentMethods.isEmpty

        let header: ListSectionHeader? = needsHeader
            ? ListSectionHeader(
                title: localizedString(.paymentMethodsOtherMethods, localizationParameters),
                style: listStyle.sectionHeader
            )
            : nil

        return PaymentMethodsSection(
            kind: .regular,
            header: header,
            paymentMethods: paymentMethods.regular
        )
    }
}

// MARK: - Private

private extension ComponentManager {
    
    func updateContextAmountIfNeeded() {
        guard let remainingAmount = order?.remainingAmount else { return }
        context.amount = remainingAmount
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
