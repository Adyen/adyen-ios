//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Combine
import Foundation

@MainActor
internal final class StoredPaymentMethodManagementViewModel: ObservableObject {

    private enum Constants {
        static let analyticsComponentIdentifier = "storedPaymentMethodManagement"
    }

    // MARK: - Properties

    internal typealias StoredPaymentMethodId = String

    private let capability: StoredPaymentMethodManagementCapability
    private let mapper: StoredPaymentMethodManagementPresentationMapper
    private let localizationParameters: LocalizationParameters?
    private let analyticsProvider: AnyAnalyticsProvider?
    internal weak var router: StoredPaymentMethodManagementRouting?

    @Published internal private(set) var sections: [StoredPaymentMethodManagementSection]
    @Published internal private(set) var removalError: StoredPaymentMethodRemovalError?
    @Published internal private(set) var itemToRemove: StoredPaymentMethodManagementItem?
    @Published internal private(set) var identifiersBeingRemoved = Set<StoredPaymentMethodId>()

    internal var isRemoving: Bool {
        !identifiersBeingRemoved.isEmpty
    }

    internal var isEmpty: Bool {
        sections.isEmpty
    }

    internal var title: String {
        localizedString(.storedPaymentMethodManagementTitle, localizationParameters)
    }

    internal var description: String {
        localizedString(.storedPaymentMethodManagementDescription, localizationParameters)
    }

    internal var paymentOptionsTitle: String {
        localizedString(.storedPaymentMethodManagementPaymentOptions, localizationParameters)
    }

    internal var cancelTitle: String {
        localizedString(.cancelButton, localizationParameters)
    }

    internal var emptyTitle: String {
        localizedString(.storedPaymentMethodManagementEmptyTitle, localizationParameters)
    }

    internal var emptyMessage: String {
        localizedString(.storedPaymentMethodManagementEmptyMessage, localizationParameters)
    }

    internal var removeButtonTitle: String {
        localizedString(.removeButton, localizationParameters)
    }

    internal var removalErrorMessage: String {
        localizedString(.storedPaymentMethodManagementRemovalErrorMessage, localizationParameters)
    }

    // MARK: - Initializers

    internal init(
        paymentMethods: [any StoredPaymentMethod],
        capability: StoredPaymentMethodManagementCapability,
        mapper: StoredPaymentMethodManagementPresentationMapper,
        localizationParameters: LocalizationParameters?,
        analyticsProvider: AnyAnalyticsProvider?
    ) {
        self.capability = capability
        self.mapper = mapper
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.sections = mapper.sections(from: paymentMethods)
    }

    // MARK: - Internal

    internal func sendRenderEvent() {
        sendAnalyticsEvent(type: .rendered)
    }

    internal func sectionTitle(for section: StoredPaymentMethodManagementSection) -> String? {
        // no title for the other section if there is no stored cards
        if section.kind == .other, !sections.contains(where: { $0.kind == .cards }) {
            return nil
        }

        return switch section.kind {
        case .cards:
            localizedString(.storedPaymentMethodManagementCardsTitle, localizationParameters)
        case .other:
            localizedString(.storedPaymentMethodManagementOtherTitle, localizationParameters)
        }
    }

    internal func isRemoving(_ item: StoredPaymentMethodManagementItem) -> Bool {
        identifiersBeingRemoved.contains(item.paymentMethod.identifier)
    }

    internal func requestRemoval(of item: StoredPaymentMethodManagementItem) {
        guard itemToRemove == nil, !isRemoving(item) else {
            return
        }

        itemToRemove = item
    }

    internal func dismissRemovalConfirmation() {
        itemToRemove = nil
    }

    internal func confirmRemoval() async {
        guard let item = itemToRemove else {
            return
        }

        sendAnalyticsEvent(type: .clicked, target: .storedPaymentRemoveButton)
        itemToRemove = nil

        let identifier = item.paymentMethod.identifier
        guard identifiersBeingRemoved.insert(identifier).inserted else {
            return
        }

        removalError = nil
        defer { identifiersBeingRemoved.remove(identifier) }

        do {
            try await capability.remove(item.paymentMethod)
        } catch {
            removalError = .unsuccessful
            return
        }

        remove(item)
        router?.didRemove(paymentMethod: item.paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        router?.didRequestPaymentOptions()
    }

    // MARK: - Private

    private func sendAnalyticsEvent(type: AnalyticsEventInfo.InfoType, target: AnalyticsEventTarget? = nil) {
        var event = AnalyticsEventInfo(
            component: Constants.analyticsComponentIdentifier,
            type: type
        )
        event.target = target
        analyticsProvider?.add(info: event)
    }

    private func remove(_ item: StoredPaymentMethodManagementItem) {
        sections = sections.compactMap { section in
            let remainingItems = section.items.filter { $0.paymentMethod.identifier != item.paymentMethod.identifier }

            guard !remainingItems.isEmpty else {
                return nil
            }

            return StoredPaymentMethodManagementSection(kind: section.kind, items: remainingItems)
        }
    }
}
