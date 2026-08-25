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

    private enum RemovalFlow {
        case idle(error: StoredPaymentMethodRemovalError?)
        case confirming(
            item: StoredPaymentMethodManagementItem,
            error: StoredPaymentMethodRemovalError?
        )
        case removing(item: StoredPaymentMethodManagementItem)
    }

    // MARK: - Properties

    private let capability: StoredPaymentMethodManagementCapability
    private let mapper: StoredPaymentMethodManagementPresentationMapper
    private let localizationParameters: LocalizationParameters?
    internal weak var router: StoredPaymentMethodManagementRouting?

    @Published internal private(set) var sections: [StoredPaymentMethodManagementSection]
    @Published private var removalFlow: RemovalFlow = .idle(error: nil)

    internal var itemToRemove: StoredPaymentMethodManagementItem? {
        guard case let .confirming(item, _) = removalFlow else {
            return nil
        }

        return item
    }

    internal var removalError: StoredPaymentMethodRemovalError? {
        switch removalFlow {
        case let .idle(error), let .confirming(_, error):
            error
        case .removing:
            nil
        }
    }

    internal var isRemoving: Bool {
        if case .removing = removalFlow {
            return true
        }

        return false
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
        localizationParameters: LocalizationParameters?
    ) {
        self.capability = capability
        self.mapper = mapper
        self.localizationParameters = localizationParameters
        self.sections = mapper.sections(from: paymentMethods)
    }

    // MARK: - Internal

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

    internal func requestRemoval(of item: StoredPaymentMethodManagementItem) {
        guard case let .idle(error) = removalFlow else {
            return
        }

        removalFlow = .confirming(item: item, error: error)
    }

    internal func dismissRemovalConfirmation() {
        guard case let .confirming(_, error) = removalFlow else {
            return
        }

        removalFlow = .idle(error: error)
    }

    internal func confirmRemoval() async {
        guard case let .confirming(item, _) = removalFlow else {
            return
        }

        removalFlow = .removing(item: item)

        do {
            try await capability.remove(item.paymentMethod)
        } catch {
            removalFlow = .idle(error: .unsuccessful)
            return
        }

        remove(item)
        removalFlow = .idle(error: nil)
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
