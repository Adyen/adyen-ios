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

    // MARK: - Properties

    private let capability: StoredPaymentMethodManagementCapability
    private let mapper: StoredPaymentMethodManagementPresentationMapper
    private let localizationParameters: LocalizationParameters?
    internal weak var router: StoredPaymentMethodManagementRouting?

    @Published internal private(set) var sections: [StoredPaymentMethodManagementSection]
    @Published internal private(set) var itemPendingRemoval: StoredPaymentMethodManagementItem?
    @Published internal private(set) var removalError: StoredPaymentMethodRemovalError?

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

    internal var removalErrorTitle: String {
        localizedString(.errorTitle, localizationParameters)
    }

    internal var removalErrorMessage: String {
        localizedString(.storedPaymentMethodManagementRemovalErrorMessage, localizationParameters)
    }

    internal var dismissTitle: String {
        localizedString(.dismissButton, localizationParameters)
    }

    // MARK: - Initializers

    internal init(
        paymentMethods: [any StoredPaymentMethod],
        capability: StoredPaymentMethodManagementCapability,
        mapper: StoredPaymentMethodManagementPresentationMapper,
        localizationParameters: LocalizationParameters?
    ) {
        self.capability = capability
        self.mapper = mapper
        self.localizationParameters = localizationParameters
        self.sections = mapper.sections(from: paymentMethods)
    }

    // MARK: - Internal

    internal func sectionTitle(for kind: StoredPaymentMethodManagementSection.Kind) -> String {
        switch kind {
        case .cards:
            localizedString(.storedPaymentMethodManagementCardsTitle, localizationParameters)
        case .other:
            localizedString(.storedPaymentMethodManagementOtherTitle, localizationParameters)
        }
    }

    internal func requestRemoval(of item: StoredPaymentMethodManagementItem) {
        itemPendingRemoval = item
    }

    internal func dismissRemovalConfirmation() {
        itemPendingRemoval = nil
    }

    internal func dismissRemovalError() {
        removalError = nil
    }

    internal func confirmRemoval(of item: StoredPaymentMethodManagementItem) async {
        do {
            try await capability.remove(item.paymentMethod)
        } catch {
            itemPendingRemoval = nil
            removalError = .unsuccessful
            return
        }

        remove(item)
        itemPendingRemoval = nil
        router?.didRemove(paymentMethod: item.paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        router?.didRequestPaymentOptions()
    }

    // MARK: - Private

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
