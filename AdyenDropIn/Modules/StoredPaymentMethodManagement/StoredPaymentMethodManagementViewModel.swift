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
        var itemPendingConfirmation: StoredPaymentMethodManagementItem?
        private var removalStatesByIdentifier = [StoredPaymentMethodId: ItemRemovalState]()
    }

    fileprivate enum ItemRemovalState {
        case removing
        case failed
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
    @Published private var state = State()

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

        remove(item)
        router?.didRemove(paymentMethod: item.paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        router?.didRequestPaymentOptions()
    }

    // MARK: - Private

    private static func reduce(
        state: State,
        action: RemovalAction
    ) -> State? {
        var state = state

        switch action {
        case let .removeButtonTapped(item):
            guard state.itemPendingConfirmation == nil,
                  !state.isRemoving(item) else {
                return nil
            }

            state.itemPendingConfirmation = item
            state.clearRemovalState(for: item)
        case let .removeConfirmButtonTapped(item):
            guard state.isPendingConfirmation(for: item),
                  state.isIdle(item) else {
                return nil
            }

            state.itemPendingConfirmation = nil
            state.setRemovalState(.removing, for: item)
        case .removeCancelButtonTapped:
            guard state.itemPendingConfirmation != nil else {
                return nil
            }

            state.itemPendingConfirmation = nil
        case let .removalSucceeded(identifier):
            guard state.isRemoving(identifier) else {
                return nil
            }

            state.clearRemovalState(for: identifier)
        case let .removalFailed(identifier):
            guard state.isRemoving(identifier) else {
                return nil
            }

            state.setRemovalState(.failed, for: identifier)
        }

        return state
    }

    @discardableResult
    private func send(_ action: RemovalAction) -> Bool {
        guard let newState = Self.reduce(state: state, action: action) else {
            return false
        }

        guard newState.isValid else {
            assertionFailure("Reducer produced an invalid removal state")
            return false
        }

        state = newState
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

private extension StoredPaymentMethodManagementViewModel.State {

    typealias StoredPaymentMethodId = StoredPaymentMethodManagementViewModel.StoredPaymentMethodId
    typealias ItemRemovalState = StoredPaymentMethodManagementViewModel.ItemRemovalState

    var identifiersBeingRemoved: Set<StoredPaymentMethodId> {
        Set(removalStatesByIdentifier.compactMap { identifier, removalState in
            removalState.isRemoving ? identifier : nil
        })
    }

    var removalError: StoredPaymentMethodRemovalError? {
        removalStatesByIdentifier.values.contains(where: \.isFailed) ? .unsuccessful : nil
    }

    var isRemoving: Bool {
        removalStatesByIdentifier.values.contains(where: \.isRemoving)
    }

    var isValid: Bool {
        guard let itemPendingConfirmation else {
            return true
        }

        return isIdle(itemPendingConfirmation)
    }

    func removalState(for identifier: StoredPaymentMethodId) -> ItemRemovalState? {
        removalStatesByIdentifier[identifier]
    }

    func removalState(for item: StoredPaymentMethodManagementItem) -> ItemRemovalState? {
        removalState(for: item.paymentMethod.identifier)
    }

    func isIdle(_ item: StoredPaymentMethodManagementItem) -> Bool {
        removalState(for: item) == nil
    }

    func isRemoving(_ identifier: StoredPaymentMethodId) -> Bool {
        removalState(for: identifier)?.isRemoving == true
    }

    func isRemoving(_ item: StoredPaymentMethodManagementItem) -> Bool {
        isRemoving(item.paymentMethod.identifier)
    }

    func isPendingConfirmation(for item: StoredPaymentMethodManagementItem) -> Bool {
        itemPendingConfirmation?.paymentMethod.identifier == item.paymentMethod.identifier
    }

    mutating func setRemovalState(_ removalState: ItemRemovalState, for identifier: StoredPaymentMethodId) {
        removalStatesByIdentifier[identifier] = removalState
    }

    mutating func setRemovalState(_ removalState: ItemRemovalState, for item: StoredPaymentMethodManagementItem) {
        setRemovalState(removalState, for: item.paymentMethod.identifier)
    }

    mutating func clearRemovalState(for identifier: StoredPaymentMethodId) {
        removalStatesByIdentifier[identifier] = nil
    }

    mutating func clearRemovalState(for item: StoredPaymentMethodManagementItem) {
        clearRemovalState(for: item.paymentMethod.identifier)
    }
}

private extension StoredPaymentMethodManagementViewModel.ItemRemovalState {

    var isRemoving: Bool {
        if case .removing = self {
            return true
        }

        return false
    }

    var isFailed: Bool {
        if case .failed = self {
            return true
        }

        return false
    }
}
