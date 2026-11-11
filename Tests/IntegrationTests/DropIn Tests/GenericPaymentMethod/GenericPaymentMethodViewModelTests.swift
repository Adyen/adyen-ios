//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenUI
import Testing
import UIKit

@MainActor
struct GenericPaymentMethodViewModelTests {

    // MARK: - Tests

    @Test
    func title_shouldReturnPaymentMethodName() {
        // Given
        let (sut, _, _, _) = makeSUT(paymentMethodName: "MB WAY")

        // Then
        #expect(sut.title == "MB WAY")
    }

    @Test
    func paymentMethodLogoURL_shouldUsePaymentMethodTypeAsLogoName() {
        // Given
        let (sut, paymentComponentMock, _, _) = makeSUT()

        // When
        let logoURL = sut.paymentMethodLogoURL

        // Then
        let expectedURL = LogoURLProvider(environment: Dummy.apiContext.environment)
            .logoURL(withName: paymentComponentMock.paymentMethod.type.rawValue)
        #expect(logoURL == expectedURL)
    }

    @Test
    func startPayment_shouldSetLoadingStateAndCallPerformSubmit() {
        // Given
        let (sut, paymentComponentMock, _, _) = makeSUT()
        paymentComponentMock.shouldCallDelegateOnSubmit = false

        // When
        sut.startPayment()

        // Then
        #expect(sut.state == .loading)
        #expect(paymentComponentMock.submitCallsCount == 1)
    }

    @Test
    func dismiss_shouldCallRouterDismiss() {
        // Given
        let (sut, _, _, routerMock) = makeSUT()

        // When
        sut.dismiss()

        // Then
        #expect(routerMock.dismissCallsCount == 1)
    }

    @Test
    func didSubmit_shouldCallDropInFlowManagerSubmit() {
        // Given
        let (sut, paymentComponentMock, dropInFlowManagerMock, routerMock) = makeSUT()
        let data = PaymentComponentData(
            paymentMethodDetails: GenericPaymentDetails(type: paymentComponentMock.paymentMethod.type),
            order: nil
        )

        // When
        sut.didSubmit(data, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromCallsCount == 1)
        let receivedArguments = dropInFlowManagerMock.submitFromReceivedArguments
        #expect((receivedArguments?.data.paymentMethod as? GenericPaymentDetails)?.type == paymentComponentMock.paymentMethod.type)
        #expect(receivedArguments?.component === paymentComponentMock)
        // The module stays presented while the payment is in flight.
        #expect(routerMock.dismissCallsCount == 0)
    }

    @Test
    func didFail_shouldCallDropInFlowManagerFailAndResetStateToIdle() {
        // Given
        let (sut, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()
        paymentComponentMock.shouldCallDelegateOnSubmit = false
        sut.startPayment()
        #expect(sut.state == .loading)

        // When
        let error = ErrorMock(errorDescription: "Payment component's error")
        sut.didFail(with: error, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 1)
        #expect(dropInFlowManagerMock.failWithFromReceivedArguments?.component === paymentComponentMock)
        #expect(sut.state == .idle)
    }

    @Test
    func isPaymentInProgress_whenTheDropInFlowManagerChanges_shouldFollowIt() {
        // Given
        let (sut, _, dropInFlowManagerMock, _) = makeSUT()
        #expect(!sut.isPaymentInProgress)

        // When
        dropInFlowManagerMock.paymentInProgressSubject.send(true)

        // Then
        #expect(sut.isPaymentInProgress)

        // When
        dropInFlowManagerMock.paymentInProgressSubject.send(false)

        // Then
        #expect(!sut.isPaymentInProgress)
    }

    @Test("The navigation locks as soon as the payment starts, before Drop-in reports it in progress.")
    func startPayment_shouldLockTheNavigationImmediately() {
        // Given
        let (sut, paymentComponentMock, _, _) = makeSUT()
        paymentComponentMock.shouldCallDelegateOnSubmit = false
        var isNavigationLocked: Bool?
        let cancellable = sut.isNavigationLocked.sink { isNavigationLocked = $0 }
        #expect(isNavigationLocked == false)

        // When
        sut.startPayment()

        // Then
        #expect(isNavigationLocked == true)
        cancellable.cancel()
    }

    @Test("When the payment attempt ends, for example after a refused payment, the screen is idle and the navigation unlocks.")
    func paymentAttempt_whenEnded_shouldResetTheStateAndUnlockTheNavigation() {
        // Given
        let (sut, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()
        paymentComponentMock.shouldCallDelegateOnSubmit = false
        var isNavigationLocked: Bool?
        let cancellable = sut.isNavigationLocked.sink { isNavigationLocked = $0 }
        sut.startPayment()
        dropInFlowManagerMock.paymentInProgressSubject.send(true)

        // When
        dropInFlowManagerMock.paymentInProgressSubject.send(false)

        // Then
        #expect(sut.state == .idle)
        #expect(isNavigationLocked == false)
        cancellable.cancel()
    }

    // MARK: - Helpers

    private func makeSUT(
        paymentMethodName: String = "Generic Payment Method"
    ) -> (
        sut: GenericPaymentMethodViewModel,
        paymentComponentMock: PaymentComponentMock,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: GenericPaymentMethodRoutingMock
    ) {
        let paymentMethodMock = PaymentMethodMock(type: .other("genericPaymentMethod"), name: paymentMethodName)
        let paymentComponentMock = PaymentComponentMock(paymentMethod: paymentMethodMock)
        let dropInFlowManagerMock = DropInFlowManagingMock()

        let sut = GenericPaymentMethodViewModel(
            component: paymentComponentMock,
            dropInFlowManager: dropInFlowManagerMock,
            logoUrlProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            localizationParameters: LocalizationParameters()
        )

        let routerMock = GenericPaymentMethodRoutingMock()
        sut.router = routerMock

        return (sut, paymentComponentMock, dropInFlowManagerMock, routerMock)
    }
}

// MARK: - GenericPaymentMethodViewModel.State Test Helpers

extension GenericPaymentMethodViewModel.State: Equatable {

    static func == (lhs: GenericPaymentMethodViewModel.State, rhs: GenericPaymentMethodViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): true
        case (.loading, .loading): true
        default: false
        }
    }
}
