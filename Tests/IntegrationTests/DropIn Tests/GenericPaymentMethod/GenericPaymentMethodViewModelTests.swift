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
    func didSubmit_shouldCallDropInFlowManagerSubmit() async {
        // Given
        let (sut, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()
        let data = PaymentComponentData(
            paymentMethodDetails: GenericPaymentDetails(type: paymentComponentMock.paymentMethod.type),
            order: nil
        )

        // When
        await confirmation { didSubmit in
            dropInFlowManagerMock.submitFromClosure = { _, _ in
                didSubmit()
                return nil
            }
            sut.didSubmit(data, from: paymentComponentMock)
            await waitUntil { dropInFlowManagerMock.submitFromCalled }
        }

        // Then
        let receivedPaymentMethod = dropInFlowManagerMock.submitFromReceivedArguments?.data.paymentMethod as? GenericPaymentDetails
        #expect(receivedPaymentMethod?.type == paymentComponentMock.paymentMethod.type)
        #expect(dropInFlowManagerMock.submitFromReceivedArguments?.component === paymentComponentMock)
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
    func didSubmit_givenAnAction_shouldPresentPaymentAction() async throws {
        // Given
        let (sut, paymentComponentMock, dropInFlowManagerMock, routerMock) = makeSUT()
        let action = try Action.redirect(RedirectAction(url: #require(URL(string: "https://adyen.com")), paymentData: "payment_data"))
        dropInFlowManagerMock.submitFromReturnValue = action
        let data = PaymentComponentData(
            paymentMethodDetails: GenericPaymentDetails(type: paymentComponentMock.paymentMethod.type),
            order: nil
        )

        // When
        await confirmation { didPresentPaymentAction in
            routerMock.presentPaymentActionForClosure = { _ in didPresentPaymentAction() }
            sut.didSubmit(data, from: paymentComponentMock)
            await waitUntil { routerMock.presentPaymentActionForCallsCount > 0 }
        }

        // Then
        #expect(routerMock.presentPaymentActionForCallsCount == 1)
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
