//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct DropInFlowManagerTests {

    // MARK: - Failure Tests

    @Test
    func fail_shouldNotifyTheMerchantOfTheComponentFailure() {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()
        let error = ErrorMock(errorDescription: "Payment component's error")

        // When
        environment.sut.fail(with: error, from: component)

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didFailWithFromInReceivedArguments?.component === component)
    }

    @Test("The merchant is looked up on the drop in, so a delegate set after initialisation is notified too.")
    func fail_withADelegateSetAfterInitialisation_shouldNotifyTheNewDelegate() {
        // Given
        let environment = makeSUT()
        let newDelegate = DropInComponentDelegateMock()
        environment.dropInComponent.delegate = newDelegate

        // When
        environment.sut.fail(with: ErrorMock(errorDescription: "Payment component's error"), from: makePaymentComponent())

        // Then
        #expect(newDelegate.didFailWithFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didFailWithFromInCallsCount == 0)
    }

    // MARK: - Cancellation Tests

    @Test
    func cancelComponent_shouldNotifyTheMerchantOfTheCancelledComponent() {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()

        // When
        environment.sut.cancel(component: component)

        // Then
        #expect(environment.dropInComponentDelegate.didCancelComponentFromCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didCancelComponentFromReceivedArguments?.component === component)
    }

    @Test
    func cancelDropIn_shouldNotifyTheMerchantWithACancellationError() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromCallsCount == 1)
        #expect(isCancellation(environment.dropInComponentDelegate.didFailWithFromReceivedArguments?.error))
    }

    @Test
    func cancelDropIn_shouldSendAClosedAnalyticsEvent() throws {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        let log = try #require(environment.analyticsProvider.logs.first)
        #expect(log.component == "dropin")
        #expect(log.type == .closed)
    }

    @Test("The drop in can be cancelled from several places at once, for example by a swipe that also dismisses a module.")
    func cancelDropIn_whenCalledRepeatedly_shouldOnlyNotifyTheMerchantOnce() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromCallsCount == 1)
        #expect(environment.analyticsProvider.logs.count == 1)
    }

    @Test("Cancelling the drop in only notifies the merchant, so the drop in is dismissed separately.")
    func cancelDropIn_shouldNotDismissTheDropIn() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 0)
    }

    // MARK: - Dismissal Tests

    @Test
    func dismissDropIn_shouldDismissThroughTheRouter() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.dismissDropIn()

        // Then
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 1)
    }

    // MARK: - Helpers

    /// The flow manager holds the drop in, its delegate and its router weakly, so they are kept alive by the environment.
    @MainActor
    private struct Environment {
        let sut: DropInFlowManager
        let dropInComponent: DropInComponent
        let dropInComponentDelegate: DropInComponentDelegateMock
        let dropInFlowRouter: DropInDismissingMock
        let analyticsProvider: AnalyticsProviderMock
    }

    private func makeSUT() -> Environment {
        let analyticsProvider = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Amount(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: analyticsProvider
        )

        let dropInComponent = DropInComponent(
            paymentMethods: PaymentMethods(regular: [], stored: []),
            context: context,
            paymentComponentBuilder: { PaymentComponentMock(paymentMethod: $0) }
        )

        let dropInComponentDelegate = DropInComponentDelegateMock()
        dropInComponent.delegate = dropInComponentDelegate

        let sut = DropInFlowManager(
            dropInComponent: dropInComponent,
            context: context,
            actionComponentConfiguration: .init()
        )

        let dropInFlowRouter = DropInDismissingMock()
        sut.dropInFlowRouter = dropInFlowRouter

        return Environment(
            sut: sut,
            dropInComponent: dropInComponent,
            dropInComponentDelegate: dropInComponentDelegate,
            dropInFlowRouter: dropInFlowRouter,
            analyticsProvider: analyticsProvider
        )
    }

    private func makePaymentComponent() -> PaymentComponentMock {
        PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .other("genericPaymentMethod"), name: "Generic"))
    }

    private func isCancellation(_ error: Error?) -> Bool {
        guard let error = error as? ComponentError, case .cancelled = error else { return false }
        return true
    }
}
