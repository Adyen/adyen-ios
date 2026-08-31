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

    fileprivate struct State {
        var sections: [StoredPaymentMethodManagementSection]
        var itemPendingConfirmation: StoredPaymentMethodManagementItem?
        var identifiersBeingRemoved = Set<StoredPaymentMethodId>()
        var removalError: StoredPaymentMethodRemovalError?
    }

    private enum Action {
        case removeButtonTapped(StoredPaymentMethodManagementItem)
        case removeConfirmButtonTapped(StoredPaymentMethodManagementItem)
        case removeCancelButtonTapped
        case removalSucceeded(identifier: StoredPaymentMethodId)
        case removalFailed(identifier: StoredPaymentMethodId)
    }

    // MARK: - Properties

    private let capability: StoredPaymentMethodManagementCapability
    private let localizationParameters: LocalizationParameters?
    internal weak var router: StoredPaymentMethodManagementRouting?

    @Published private var state: State

    internal var sections: [StoredPaymentMethodManagementSection] {
        state.sections
    }

    internal var itemPendingConfirmation: StoredPaymentMethodManagementItem? {
        state.itemPendingConfirmation
    }

    internal var identifiersBeingRemoved: Set<StoredPaymentMethodId> {
        state.identifiersBeingRemoved
    }

    internal var removalError: StoredPaymentMethodRemovalError? {
        state.removalError
    }

    internal var isRemoving: Bool {
        state.isRemoving
    }

    internal var isRemovingPublisher: AnyPublisher<Bool, Never> {
        $state
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
        self.localizationParameters = localizationParameters
        self.state = State(sections: mapper.sections(from: paymentMethods))
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
        state.isRemoving(item)
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
        router?.didRemove(paymentMethod: item.paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        router?.didRequestPaymentOptions()
    }

    // MARK: - Private

    private static func reduce(
        state: State,
        action: Action
    ) -> State? {
        var state = state

        switch action {
        case let .removeButtonTapped(item):
            guard state.itemPendingConfirmation == nil,
                  !state.isRemoving(item) else {
                return nil
            }

            state.itemPendingConfirmation = item
        case let .removeConfirmButtonTapped(item):
            guard state.isPendingConfirmation(for: item) else {
                return nil
            }

            state.itemPendingConfirmation = nil
            state.identifiersBeingRemoved.insert(item.paymentMethod.identifier)
            state.removalError = nil
        case .removeCancelButtonTapped:
            guard state.itemPendingConfirmation != nil else {
                return nil
            }

            state.itemPendingConfirmation = nil
        case let .removalSucceeded(identifier):
            guard state.isRemoving(identifier) else {
                return nil
            }

            state.identifiersBeingRemoved.remove(identifier)
            state.removeItem(withIdentifier: identifier)
        case let .removalFailed(identifier):
            guard state.isRemoving(identifier) else {
                return nil
            }

            state.identifiersBeingRemoved.remove(identifier)
            state.removalError = .unsuccessful
        }

        return state
    }

    @discardableResult
    private func send(_ action: Action) -> Bool {
        guard let newState = Self.reduce(state: state, action: action) else {
            return false
        }

        state = newState
        return true
    }

}

private extension StoredPaymentMethodManagementViewModel.State {

    typealias StoredPaymentMethodId = StoredPaymentMethodManagementViewModel.StoredPaymentMethodId
    var isRemoving: Bool {
        !identifiersBeingRemoved.isEmpty
    }

    func isRemoving(_ identifier: StoredPaymentMethodId) -> Bool {
        identifiersBeingRemoved.contains(identifier)
    }

    func isRemoving(_ item: StoredPaymentMethodManagementItem) -> Bool {
        isRemoving(item.paymentMethod.identifier)
    }

    func isPendingConfirmation(for item: StoredPaymentMethodManagementItem) -> Bool {
        itemPendingConfirmation?.paymentMethod.identifier == item.paymentMethod.identifier
    }

    mutating func removeItem(withIdentifier identifier: StoredPaymentMethodId) {
        sections = sections.compactMap { section in
            let remainingItems = section.items.filter { $0.paymentMethod.identifier != identifier }

            guard !remainingItems.isEmpty else {
                return nil
            }

            return StoredPaymentMethodManagementSection(kind: section.kind, items: remainingItems)
        }
    }
}
