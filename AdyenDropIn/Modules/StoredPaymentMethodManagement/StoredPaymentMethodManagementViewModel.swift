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

    internal typealias StoredPaymentMethodId = String

    private struct RemovalState {
        var itemPendingConfirmation: StoredPaymentMethodManagementItem?
        var identifiersBeingRemoved = Set<StoredPaymentMethodId>()
        var removalError: StoredPaymentMethodRemovalError?

        var isRemoving: Bool {
            !identifiersBeingRemoved.isEmpty
        }

        func isRemoving(_ item: StoredPaymentMethodManagementItem) -> Bool {
            identifiersBeingRemoved.contains(item.paymentMethod.identifier)
        }
    }

    private enum RemovalAction {
        case removeButtonTapped(StoredPaymentMethodManagementItem)
        case removeConfirmButtonTapped(StoredPaymentMethodManagementItem)
        case removeCancelButtonTapped
        case removalSucceeded(identifier: StoredPaymentMethodId)
        case removalFailed(identifier: StoredPaymentMethodId)
    }

    // MARK: - Properties

    private let capability: StoredPaymentMethodManagementCapability
    private let mapper: StoredPaymentMethodManagementPresentationMapper
    private let localizationParameters: LocalizationParameters?
    internal weak var router: StoredPaymentMethodManagementRouting?

    @Published internal private(set) var sections: [StoredPaymentMethodManagementSection]
    @Published private var removalState = RemovalState()

    internal var itemPendingConfirmation: StoredPaymentMethodManagementItem? {
        removalState.itemPendingConfirmation
    }

    internal var identifiersBeingRemoved: Set<StoredPaymentMethodId> {
        removalState.identifiersBeingRemoved
    }

    internal var removalError: StoredPaymentMethodRemovalError? {
        removalState.removalError
    }

    internal var isRemoving: Bool {
        removalState.isRemoving
    }

    internal var isRemovingPublisher: AnyPublisher<Bool, Never> {
        $removalState
            .map(\.isRemoving)
            .removeDuplicates()
            .eraseToAnyPublisher()
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

    internal func isRemoving(_ item: StoredPaymentMethodManagementItem) -> Bool {
        removalState.isRemoving(item)
    }

    internal func onRemoveButtonTap(_ item: StoredPaymentMethodManagementItem) {
        send(.removeButtonTapped(item))
    }

    internal func onRemoveCancelButtonTap() {
        send(.removeCancelButtonTapped)
    }

    internal func onRemoveConfirmButtonTap(_ item: StoredPaymentMethodManagementItem) async {
        guard send(.removeConfirmButtonTapped(item)) else {
            return
        }

        let identifier = item.paymentMethod.identifier

        do {
            try await capability.remove(item.paymentMethod)
        } catch {
            send(.removalFailed(identifier: identifier))
            return
        }

        guard send(.removalSucceeded(identifier: identifier)) else {
            return
        }

        remove(item)
        router?.didRemove(paymentMethod: item.paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        router?.didRequestPaymentOptions()
    }

    // MARK: - Private

    private static func reduce(
        state: RemovalState,
        action: RemovalAction
    ) -> RemovalState? {
        var state = state

        switch action {
        case let .removeButtonTapped(item):
            let identifier = item.paymentMethod.identifier
            guard state.itemPendingConfirmation == nil,
                  !state.identifiersBeingRemoved.contains(identifier) else {
                return nil
            }

            state.itemPendingConfirmation = item
            state.removalError = nil
        case let .removeConfirmButtonTapped(item):
            let identifier = item.paymentMethod.identifier
            guard state.itemPendingConfirmation?.paymentMethod.identifier == identifier,
                  state.identifiersBeingRemoved.insert(identifier).inserted else {
                return nil
            }

            state.itemPendingConfirmation = nil
        case .removeCancelButtonTapped:
            guard state.itemPendingConfirmation != nil else {
                return nil
            }

            state.itemPendingConfirmation = nil
        case let .removalSucceeded(identifier):
            guard state.identifiersBeingRemoved.remove(identifier) != nil else {
                return nil
            }
        case let .removalFailed(identifier):
            guard state.identifiersBeingRemoved.remove(identifier) != nil else {
                return nil
            }

            state.removalError = .unsuccessful
        }

        return state
    }

    @discardableResult
    private func send(_ action: RemovalAction) -> Bool {
        guard let state = Self.reduce(state: removalState, action: action) else {
            return false
        }

        removalState = state
        return true
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
