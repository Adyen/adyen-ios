//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct StoredPaymentMethodManagementViewModelTests {

    @Test
    func removeAndCancelButtonTaps_updateItemPendingConfirmation() throws {
        let sut = makeSUT()
        let item = try #require(sut.sections.first?.items.first)

        sut.onRemoveButtonTap(item)
        #expect(sut.itemPendingConfirmation?.paymentMethod.identifier == item.paymentMethod.identifier)

        sut.onRemoveCancelButtonTap()
        #expect(sut.itemPendingConfirmation == nil)
    }

    @Test
    func removeConfirmButtonTap_afterSuccess_removesItemAndNotifiesRouter() async throws {
        var removalCallsCount = 0
        var observedRemovingState = false
        weak var weakSUT: StoredPaymentMethodManagementViewModel?
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { paymentMethod in
                removalCallsCount += 1
                observedRemovingState = weakSUT?.identifiersBeingRemoved.contains(paymentMethod.identifier) == true
            }
        )
        weakSUT = sut
        sut.router = router
        let item = try #require(sut.sections.first?.items.first)
        sut.onRemoveButtonTap(item)

        await sut.onRemoveConfirmButtonTap(item)

        #expect(removalCallsCount == 1)
        #expect(observedRemovingState)
        #expect(sut.sections.isEmpty)
        #expect(sut.itemPendingConfirmation == nil)
        #expect(!sut.isRemoving)
        #expect(router.removedPaymentMethods.last?.identifier == item.paymentMethod.identifier)
    }

    @Test
    func removeActions_whileSameItemIsRemoving_startOneRemoval() async throws {
        var removalContinuation: CheckedContinuation<Void, Never>?
        var removalCallsCount = 0
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                removalCallsCount += 1
                await withCheckedContinuation { continuation in
                    removalContinuation = continuation
                }
            }
        )
        let item = try #require(sut.sections.first?.items.first)
        sut.onRemoveButtonTap(item)
        let removal = Task { await sut.onRemoveConfirmButtonTap(item) }
        await Task.yield()

        sut.onRemoveButtonTap(item)
        await sut.onRemoveConfirmButtonTap(item)

        #expect(removalCallsCount == 1)
        #expect(sut.itemPendingConfirmation == nil)
        #expect(sut.isRemoving(item))

        let continuation = try #require(removalContinuation)
        continuation.resume()
        await removal.value

        #expect(sut.sections.isEmpty)
        #expect(!sut.isRemoving)
    }

    @Test
    func concurrentRemovals_whenFirstFailsAndSecondSucceeds_trackItemsAndPreserveError() async throws {
        var removalContinuations = [String: CheckedContinuation<Void, any Error>]()
        let firstPaymentMethod = storedPaymentMethod(identifier: "first-stored-payment-method-id")
        let secondPaymentMethod = storedPaymentMethod(identifier: "second-stored-payment-method-id")
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT(
            paymentMethods: [firstPaymentMethod, secondPaymentMethod],
            capability: StoredPaymentMethodManagementCapability { paymentMethod in
                try await withCheckedThrowingContinuation { continuation in
                    removalContinuations[paymentMethod.identifier] = continuation
                }
            }
        )
        sut.router = router
        let items = sut.sections.flatMap(\.items)
        let firstItem = try #require(items.first { $0.paymentMethod.identifier == firstPaymentMethod.identifier })
        let secondItem = try #require(items.first { $0.paymentMethod.identifier == secondPaymentMethod.identifier })

        sut.onRemoveButtonTap(firstItem)
        let firstRemoval = Task { await sut.onRemoveConfirmButtonTap(firstItem) }
        await Task.yield()
        sut.onRemoveButtonTap(secondItem)
        let secondRemoval = Task { await sut.onRemoveConfirmButtonTap(secondItem) }
        await Task.yield()

        #expect(sut.identifiersBeingRemoved == [firstPaymentMethod.identifier, secondPaymentMethod.identifier])

        let pendingFirstRemoval = removalContinuations.removeValue(forKey: firstPaymentMethod.identifier)
        let firstContinuation = try #require(pendingFirstRemoval)
        firstContinuation.resume(throwing: StoredPaymentMethodRemovalError.unsuccessful)
        await firstRemoval.value

        #expect(!sut.isRemoving(firstItem))
        #expect(sut.isRemoving(secondItem))
        #expect(sut.removalError == .unsuccessful)

        let pendingSecondRemoval = removalContinuations.removeValue(forKey: secondPaymentMethod.identifier)
        let secondContinuation = try #require(pendingSecondRemoval)
        secondContinuation.resume()
        await secondRemoval.value

        #expect(!sut.isRemoving)
        #expect(sut.removalError == .unsuccessful)
        #expect(sut.sections.flatMap(\.items).map(\.paymentMethod.identifier) == [firstPaymentMethod.identifier])
        #expect(router.removedPaymentMethods.map(\.identifier) == [secondPaymentMethod.identifier])
    }

    @Test
    func openingAndCancellingConfirmation_preserveError() async throws {
        let firstPaymentMethod = storedPaymentMethod(identifier: "first-stored-payment-method-id")
        let secondPaymentMethod = storedPaymentMethod(identifier: "second-stored-payment-method-id")
        let sut = makeSUT(
            paymentMethods: [firstPaymentMethod, secondPaymentMethod],
            capability: StoredPaymentMethodManagementCapability { _ in
                throw StoredPaymentMethodRemovalError.unsuccessful
            }
        )
        let items = sut.sections.flatMap(\.items)
        let firstItem = try #require(items.first { $0.paymentMethod.identifier == firstPaymentMethod.identifier })
        let secondItem = try #require(items.first { $0.paymentMethod.identifier == secondPaymentMethod.identifier })

        sut.onRemoveButtonTap(firstItem)
        await sut.onRemoveConfirmButtonTap(firstItem)
        sut.onRemoveButtonTap(secondItem)
        #expect(sut.removalError == .unsuccessful)
        await sut.onRemoveConfirmButtonTap(secondItem)
        #expect(!sut.isRemoving(firstItem))
        #expect(!sut.isRemoving(secondItem))
        #expect(sut.identifiersBeingRemoved.isEmpty)
        #expect(sut.sections.flatMap(\.items).count == 2)

        sut.onRemoveButtonTap(firstItem)
        #expect(sut.removalError == .unsuccessful)
        sut.onRemoveCancelButtonTap()
        #expect(sut.removalError == .unsuccessful)
    }

    @Test
    func removeConfirmButtonTap_whenCapabilityThrows_preservesItemAndError() async throws {
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                throw StoredPaymentMethodRemovalError.unavailable
            }
        )
        let item = try #require(sut.sections.first?.items.first)
        sut.onRemoveButtonTap(item)

        await sut.onRemoveConfirmButtonTap(item)

        #expect(sut.sections.first?.items.count == 1)
        #expect(sut.itemPendingConfirmation == nil)
        #expect(!sut.isRemoving)
        #expect(sut.removalError == .unsuccessful)

        sut.onRemoveCancelButtonTap()
        #expect(sut.removalError == .unsuccessful)
    }

    @Test
    func retryingRemoval_clearsError() async throws {
        var removalCallsCount = 0
        var retryContinuation: CheckedContinuation<Void, Never>?
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                removalCallsCount += 1
                if removalCallsCount == 1 {
                    throw StoredPaymentMethodRemovalError.unsuccessful
                }

                await withCheckedContinuation { continuation in
                    retryContinuation = continuation
                }
            }
        )
        let item = try #require(sut.sections.first?.items.first)
        sut.onRemoveButtonTap(item)
        await sut.onRemoveConfirmButtonTap(item)
        #expect(sut.removalError == .unsuccessful)

        sut.onRemoveButtonTap(item)
        let retry = Task { await sut.onRemoveConfirmButtonTap(item) }
        await Task.yield()

        #expect(sut.removalError == nil)
        #expect(sut.isRemoving(item))
        let continuation = try #require(retryContinuation)
        continuation.resume()

        await retry.value
    }

    @Test
    func removeConfirmButtonTap_fromIdle_doesNotCallCapability() async throws {
        var removalCallsCount = 0
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                removalCallsCount += 1
            }
        )
        let item = try #require(sut.sections.first?.items.first)

        await sut.onRemoveConfirmButtonTap(item)

        #expect(removalCallsCount == 0)
        #expect(sut.itemPendingConfirmation == nil)
        #expect(!sut.isRemoving)
    }

    @Test
    func didRequestPaymentOptions_forwardsRequestToRouter() {
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT()
        sut.router = router

        sut.didRequestPaymentOptions()

        #expect(router.paymentOptionsRequestCount == 1)
    }

    @Test
    func sectionTitle_whenOtherIsTheOnlySection_returnsNil() throws {
        let sut = makeSUT()
        let section = try #require(sut.sections.first)

        #expect(section.kind == .other)
        #expect(sut.sectionTitle(for: section) == nil)
    }

    private func makeSUT(
        paymentMethods: [StoredPaymentMethodMock]? = nil,
        capability: StoredPaymentMethodManagementCapability = StoredPaymentMethodManagementCapability { _ in }
    ) -> StoredPaymentMethodManagementViewModel {
        let mapper = StoredPaymentMethodManagementPresentationMapper(
            localizationParameters: nil,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment)
        )

        return StoredPaymentMethodManagementViewModel(
            paymentMethods: paymentMethods ?? [storedPaymentMethod()],
            capability: capability,
            mapper: mapper,
            localizationParameters: nil
        )
    }

    private func storedPaymentMethod(identifier: String = "stored-payment-method-id") -> StoredPaymentMethodMock {
        StoredPaymentMethodMock(
            identifier: identifier,
            supportedShopperInteractions: [.shopperPresent],
            type: .scheme,
            name: "Visa"
        )
    }
}
