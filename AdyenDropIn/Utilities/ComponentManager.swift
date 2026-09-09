//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import struct AdyenUI.ListSection
#endif
import Foundation

package typealias DropInPaymentComponentBuilder =
    @MainActor (_ paymentMethod: PaymentMethod) throws -> PaymentComponent

@MainActor
internal protocol ComponentManaging {
    var sections: [PaymentMethodsSection] { get }
    func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent?
    func removeStoredPaymentMethod(withIdentifier identifier: String)
}

@MainActor
internal final class ComponentManager: ComponentManaging {

    // MARK: - Properties

    internal private(set) var paymentMethods: PaymentMethods
    internal let configuration: DropInConfiguration
    internal let context: AdyenContext
    internal let order: PartialPaymentOrder?
    internal var hasPhotoLibraryUsageDescription = Bundle.main.object(
        forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription"
    ) != nil
    
    private let paymentComponentBuilder: DropInPaymentComponentBuilder

    private var localizationParameters: LocalizationParameters? {
        configuration.resolvedLocalizationParameters
    }

    private var listStyle: ListComponentStyle {
        ListComponentStyle()
    }

    // MARK: - Initializer

    internal init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInConfiguration,
        order: PartialPaymentOrder?,
        paymentComponentBuilder: @escaping DropInPaymentComponentBuilder
    ) {
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.order = order
        self.paymentComponentBuilder = paymentComponentBuilder

        updateContextAmountIfNeeded()
    }

    // MARK: - ComponentManaging

    internal var sections: [PaymentMethodsSection] {
        [paidSection, storedSection, regularSection].filter { !$0.paymentMethods.isEmpty }
    }

    internal var visibleStoredPaymentMethods: [any StoredPaymentMethod] {
        supportedStoredPaymentMethods
    }

    internal func removeStoredPaymentMethod(withIdentifier identifier: String) {
        paymentMethods.stored.removeAll { $0.identifier == identifier }
        supportedStoredPaymentMethods.removeAll { $0.identifier == identifier }
    }

    internal func update(paymentMethods: PaymentMethods) {
        self.paymentMethods = paymentMethods
        supportedStoredPaymentMethods = storedPaymentMethodCandidates.filter { canBuildComponent(for: $0) }
        supportedRegularPaymentMethods = paymentMethods.regular.filter { canBuildComponent(for: $0) }
        supportedPaidPaymentMethods = paymentMethods.paid.filter { canBuildComponent(for: $0) }
    }

    internal func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard containsSupportedPaymentMethod(paymentMethod) else { return nil }

        return assembleComponent(for: paymentMethod)
    }

    // MARK: - Supported Payment Methods

    internal lazy var supportedStoredPaymentMethods = storedPaymentMethodCandidates.filter { canBuildComponent(for: $0) }

    internal lazy var supportedRegularPaymentMethods = paymentMethods.regular.filter { canBuildComponent(for: $0) }

    internal lazy var supportedPaidPaymentMethods = paymentMethods.paid.filter { canBuildComponent(for: $0) }

    internal var firstStoredComponent: PaymentComponent? {
        supportedStoredPaymentMethods.first.flatMap(buildComponent(for:))
    }

    internal var singleRegularComponent: PresentablePaymentComponent? {
        guard supportedStoredPaymentMethods.isEmpty,
              supportedPaidPaymentMethods.isEmpty,
              supportedRegularPaymentMethods.count == 1,
              let paymentMethod = supportedRegularPaymentMethods.first
        else { return nil }

        return buildComponent(for: paymentMethod) as? PresentablePaymentComponent
    }

    // MARK: - Private

    private var paidSection: PaymentMethodsSection {
        PaymentMethodsSection(
            kind: .paid,
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsPaidMethods, localizationParameters),
                style: listStyle.sectionHeader
            ),
            paymentMethods: supportedPaidPaymentMethods
        )
    }

    private var storedSection: PaymentMethodsSection {
        guard !configuration.hideStoredPaymentMethods else {
            return PaymentMethodsSection(kind: .stored, header: nil, paymentMethods: [])
        }

        return PaymentMethodsSection(
            kind: .stored,
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsStoredMethods, localizationParameters),
                style: listStyle.sectionHeader
            ),
            paymentMethods: visibleStoredPaymentMethods
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
            paymentMethods: supportedRegularPaymentMethods
        )
    }
}

// MARK: - Private

private extension ComponentManager {

    var storedPaymentMethodCandidates: [any StoredPaymentMethod] {
        paymentMethods.stored
            .filter { $0.supportedShopperInteractions.contains(.shopperPresent) }
    }

    // TODO: To be improved with payment method availability feature.
    func canBuildComponent(for paymentMethod: PaymentMethod) -> Bool {
        assembleComponent(for: paymentMethod) != nil
    }

    func containsSupportedPaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        if let storedPaymentMethod = paymentMethod as? any StoredPaymentMethod {
            return supportedStoredPaymentMethods.contains { $0 == storedPaymentMethod }
        }
        
        return supportedRegularPaymentMethods.contains { $0 == paymentMethod }
            || supportedPaidPaymentMethods.contains { $0 == paymentMethod }
    }

    func assembleComponent(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        guard isAllowed(paymentMethod) else {
            AdyenAssertion.assertionFailure(message: """
            For voucher payment methods like \(paymentMethod.name) it is required to add a suitable \
            text for the key NSPhotoLibraryAddUsageDescription in the Application Info.plist, to enable \
            the shopper to save the voucher to their photo library.
            """)
            return nil
        }

        do {
            var component = try paymentComponentBuilder(paymentMethod)
            // TODO: Preserve the order assignment until partial payments have a dedicated design.
            component.order = order
            return component
        } catch {
            // TODO: Store these errors if we need to track them.
            adyenPrint("Failed to build component for \(paymentMethod.type.rawValue):", error)
            return nil
        }
    }

    func updateContextAmountIfNeeded() {
        guard let remainingAmount = order?.remainingAmount else { return }
        context.amount = remainingAmount
    }

    // MARK: - Payment Method Validation

    func isAllowed(_ paymentMethod: PaymentMethod) -> Bool {
        let requiresPhotoLibrary = isVoucherPaymentMethod(paymentMethod) || isQRCodePaymentMethod(paymentMethod)
        guard requiresPhotoLibrary else { return true }

        return hasPhotoLibraryUsageDescription
    }

    func isQRCodePaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        QRCodePaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }

    func isVoucherPaymentMethod(_ paymentMethod: PaymentMethod) -> Bool {
        VoucherPaymentMethod.allCases.map(\.rawValue).contains(paymentMethod.type.rawValue)
    }
}
