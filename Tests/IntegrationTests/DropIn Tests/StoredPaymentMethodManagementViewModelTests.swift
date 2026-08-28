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
    func requestAndDismissRemoval_updatesItemPendingRemoval() throws {
        let sut = makeSUT()
        let item = try #require(sut.sections.first?.items.first)

        sut.requestRemoval(of: item)
        #expect(sut.itemToRemove?.paymentMethod.identifier == item.paymentMethod.identifier)

        sut.dismissRemovalConfirmation()
        #expect(sut.itemToRemove == nil)
    }

    @Test
    func confirmRemoval_afterSuccess_removesItemAndNotifiesRouter() async throws {
        var removalCallsCount = 0
        var observedRemovingState = false
        weak var weakSUT: StoredPaymentMethodManagementViewModel?
        let router = StoredPaymentMethodManagementRoutingMock()
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                removalCallsCount += 1
                observedRemovingState = weakSUT?.isRemoving == true
                await weakSUT?.confirmRemoval()
            }
        )
        weakSUT = sut
        sut.router = router
        let item = try #require(sut.sections.first?.items.first)
        sut.requestRemoval(of: item)

        await sut.confirmRemoval()

        #expect(removalCallsCount == 1)
        #expect(observedRemovingState)
        #expect(sut.sections.isEmpty)
        #expect(sut.itemToRemove == nil)
        #expect(router.removedPaymentMethods.last?.identifier == item.paymentMethod.identifier)
    }

    @Test
    func confirmRemoval_whenCapabilityThrows_preservesItemAndShowsError() async throws {
        let sut = makeSUT(
            capability: StoredPaymentMethodManagementCapability { _ in
                throw StoredPaymentMethodRemovalError.unsuccessful
            }
        )
        let item = try #require(sut.sections.first?.items.first)
        sut.requestRemoval(of: item)

        await sut.confirmRemoval()

        #expect(sut.sections.first?.items.count == 1)
        #expect(sut.itemToRemove == nil)
        #expect(sut.removalError == .unsuccessful)
    }

    @Test
    func confirmRemoval_afterFailureThenSuccess_clearsErrorWhenRetryStarts() async throws {
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
        capability: StoredPaymentMethodManagementCapability = StoredPaymentMethodManagementCapability { _ in }
    ) -> StoredPaymentMethodManagementViewModel {
        let mapper = StoredPaymentMethodManagementPresentationMapper(
            localizationParameters: nil,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment)
        )
        let paymentMethod = StoredPaymentMethodMock(
            identifier: "stored-payment-method-id",
            supportedShopperInteractions: [.shopperPresent],
            type: .scheme,
            name: "Visa"
        )

        return StoredPaymentMethodManagementViewModel(
            paymentMethods: [paymentMethod],
            capability: capability,
            mapper: mapper,
            localizationParameters: nil
        )
    }
}
