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
        storedComponents.compactMap { $0.paymentMethod as? any StoredPaymentMethod }
    }

    internal func removeStoredPaymentMethod(withIdentifier identifier: String) {
        paymentMethods.stored.removeAll { $0.identifier == identifier }
        storedComponents.removeAll {
            ($0.paymentMethod as? any StoredPaymentMethod)?.identifier == identifier
        }
    }

    internal func update(paymentMethods: PaymentMethods) {
        self.paymentMethods = paymentMethods
        storedComponents = buildComponents(for: storedPaymentMethodCandidates)
        regularComponents = buildComponents(for: paymentMethods.regular)
        paidComponents = buildComponents(for: paymentMethods.paid)
    }

    internal func buildComponent(for paymentMethod: PaymentMethod) -> PaymentComponent? {
        cachedComponents.first {
            isSamePaymentMethod($0.paymentMethod, as: paymentMethod)
        }
    }

    // MARK: - Computed Components

    internal lazy var storedComponents = buildComponents(for: storedPaymentMethodCandidates)

    internal lazy var regularComponents = buildComponents(for: paymentMethods.regular)

    internal lazy var paidComponents = buildComponents(for: paymentMethods.paid)

    internal var singleRegularComponent: PresentablePaymentComponent? {
        guard storedComponents.isEmpty,
              paidComponents.isEmpty,
              regularComponents.count == 1,
              let component = regularComponents.first as? PresentablePaymentComponent
        else { return nil }

        return component
    }

    // MARK: - Private

    private var paidSection: PaymentMethodsSection {
        PaymentMethodsSection(
            kind: .paid,
            header: ListSectionHeader(
                title: localizedString(.paymentMethodsPaidMethods, localizationParameters),
                style: listStyle.sectionHeader
            ),
            paymentMethods: paidComponents.map(\.paymentMethod)
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
            paymentMethods: regularComponents.map(\.paymentMethod)
        )
    }
}

// MARK: - Private

private extension ComponentManager {

    var storedPaymentMethodCandidates: [any StoredPaymentMethod] {
        paymentMethods.stored
            .filter { $0.supportedShopperInteractions.contains(.shopperPresent) }
    }

    var cachedComponents: [PaymentComponent] {
        paidComponents + storedComponents + regularComponents
    }

    func buildComponents(for paymentMethods: [PaymentMethod]) -> [PaymentComponent] {
        paymentMethods.compactMap(assembleComponent)
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

    func isSamePaymentMethod(_ lhs: PaymentMethod, as rhs: PaymentMethod) -> Bool {
        if let lhs = lhs as? any StoredPaymentMethod,
           let rhs = rhs as? any StoredPaymentMethod {
            return lhs == rhs
        }

        return lhs == rhs
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
