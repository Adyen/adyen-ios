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
    func sendRenderEvent_shouldSendManagementRenderedEvent() throws {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProvider: analyticsProvider)

        sut.sendRenderEvent()

        let event = try #require(analyticsProvider.infos.first)
        #expect(analyticsProvider.infos.count == 1)
        #expect(event.component == "storedPaymentMethodManagement")
        #expect(event.type == .rendered)
    }

    @Test
    func requestAndDismissRemoval_shouldUpdatePendingItemWithoutSendingRemoveEvent() throws {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProvider: analyticsProvider)
        let item = try #require(sut.sections.first?.items.first)

        sut.requestRemoval(of: item)
        #expect(sut.itemToRemove?.paymentMethod.identifier == item.paymentMethod.identifier)

        sut.dismissRemovalConfirmation()
        #expect(sut.itemToRemove == nil)
        #expect(analyticsProvider.infos.isEmpty)
    }

    @Test
    func confirmRemoval_afterSuccess_shouldRemoveItemNotifyRouterAndSendRemoveEvent() async throws {
        let analyticsProvider = AnalyticsProviderMock()
        var removalCallsCount = 0
        var observedRemovingState = false
        var observedRemoveEvent = false
        weak var weakSUT: StoredPaymentMethodManagementViewModel?
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { paymentMethod in
                removalCallsCount += 1
                observedRemovingState = weakSUT?.identifiersBeingRemoved.contains(paymentMethod.identifier) == true
                observedRemoveEvent = analyticsProvider.infos.last?.type == .remove
                await weakSUT?.confirmRemoval()
            },
            analyticsProvider: analyticsProvider
        )
        weakSUT = sut
        sut.router = router
        let item = try #require(sut.sections.first?.items.first)
        sut.requestRemoval(of: item)

        await sut.confirmRemoval()

        #expect(removalCallsCount == 1)
        #expect(observedRemovingState)
        #expect(observedRemoveEvent)
        #expect(sut.sections.isEmpty)
        #expect(sut.itemToRemove == nil)
        #expect(!sut.isRemoving)
        #expect(router.removedPaymentMethods.last?.identifier == item.paymentMethod.identifier)
        let event = try #require(analyticsProvider.infos.first)
        #expect(analyticsProvider.infos.count == 1)
        #expect(event.component == "storedPaymentMethodManagement")
        #expect(event.type == .remove)
    }

    @Test
    func confirmRemoval_whileAnotherRemovalIsInProgress_shouldTrackBothItems() async throws {
        var removalContinuations = [String: CheckedContinuation<Void, any Error>]()
        let firstPaymentMethod = storedPaymentMethod(identifier: "first-stored-payment-method-id")
        let secondPaymentMethod = storedPaymentMethod(identifier: "second-stored-payment-method-id")
        let sut = makeSUT(
            paymentMethods: [firstPaymentMethod, secondPaymentMethod],
            capability: StoredPaymentMethodManagementCapability { paymentMethod in
                try await withCheckedThrowingContinuation { continuation in
                    removalContinuations[paymentMethod.identifier] = continuation
                }
            }
        )
        let items = sut.sections.flatMap(\.items)
        let firstItem = try #require(items.first { $0.paymentMethod.identifier == firstPaymentMethod.identifier })
        let secondItem = try #require(items.first { $0.paymentMethod.identifier == secondPaymentMethod.identifier })

        sut.requestRemoval(of: firstItem)
        let firstRemoval = Task { await sut.confirmRemoval() }
        await Task.yield()

        #expect(sut.identifiersBeingRemoved == [firstPaymentMethod.identifier])
        sut.requestRemoval(of: firstItem)
        #expect(sut.itemToRemove == nil)

        sut.requestRemoval(of: secondItem)
        let secondRemoval = Task { await sut.confirmRemoval() }
        await Task.yield()

        #expect(sut.identifiersBeingRemoved == [firstPaymentMethod.identifier, secondPaymentMethod.identifier])

        let pendingFirstRemoval = removalContinuations.removeValue(forKey: firstPaymentMethod.identifier)
        let firstContinuation = try #require(pendingFirstRemoval)
        firstContinuation.resume()
        await firstRemoval.value

        #expect(!sut.isRemoving(firstItem))
        #expect(sut.isRemoving(secondItem))

        let pendingSecondRemoval = removalContinuations.removeValue(forKey: secondPaymentMethod.identifier)
        let secondContinuation = try #require(pendingSecondRemoval)
        secondContinuation.resume()
        await secondRemoval.value

        #expect(sut.sections.isEmpty)
        #expect(!sut.isRemoving)
    }

    @Test
    func confirmRemoval_whenCapabilityThrows_shouldPreserveItemShowErrorAndSendRemoveEvent() async throws {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                throw StoredPaymentMethodRemovalError.unsuccessful
            },
            analyticsProvider: analyticsProvider
        )
        let item = try #require(sut.sections.first?.items.first)
        sut.requestRemoval(of: item)

        await sut.confirmRemoval()

        #expect(sut.sections.first?.items.count == 1)
        #expect(sut.itemToRemove == nil)
        #expect(!sut.isRemoving)
        #expect(sut.removalError == .unsuccessful)
        let event = try #require(analyticsProvider.infos.first)
        #expect(analyticsProvider.infos.count == 1)
        #expect(event.component == "storedPaymentMethodManagement")
        #expect(event.type == .remove)
    }

    @Test
    func confirmRemoval_afterFailureThenSuccess_shouldClearErrorWhenRetryStarts() async throws {
        var removalAttemptCount = 0
        var observedRetryError: StoredPaymentMethodRemovalError?
        weak var weakSUT: StoredPaymentMethodManagementViewModel?
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                removalAttemptCount += 1

                if removalAttemptCount == 1 {
                    throw StoredPaymentMethodRemovalError.unsuccessful
                }

                observedRetryError = weakSUT?.removalError
            }
        )
        weakSUT = sut
        let item = try #require(sut.sections.first?.items.first)
        sut.requestRemoval(of: item)
        await sut.confirmRemoval()
        #expect(sut.removalError == .unsuccessful)

        sut.requestRemoval(of: item)
        #expect(sut.removalError == .unsuccessful)
        await sut.confirmRemoval()

        #expect(observedRetryError == nil)
        #expect(sut.removalError == nil)
    }

    @Test
    func didRequestPaymentOptions_shouldForwardRequestToRouter() {
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT()
        sut.router = router

        sut.didRequestPaymentOptions()

        #expect(router.paymentOptionsRequestCount == 1)
    }

    @Test
    func sectionTitle_whenOtherIsTheOnlySection_shouldReturnNil() throws {
        let sut = makeSUT()
        let section = try #require(sut.sections.first)

        #expect(section.kind == .other)
        #expect(sut.sectionTitle(for: section) == nil)
    }

    private func makeSUT(
        paymentMethods: [StoredPaymentMethodMock]? = nil,
        capability: StoredPaymentMethodManagementCapability = StoredPaymentMethodManagementCapability { _ in },
        analyticsProvider: AnyAnalyticsProvider? = nil
    ) -> StoredPaymentMethodManagementViewModel {
        let mapper = StoredPaymentMethodManagementPresentationMapper(
            localizationParameters: nil,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment)
        )

        return StoredPaymentMethodManagementViewModel(
            paymentMethods: paymentMethods ?? [storedPaymentMethod()],
            capability: capability,
            mapper: mapper,
            localizationParameters: nil,
            analyticsProvider: analyticsProvider
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
