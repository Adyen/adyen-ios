//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
import Testing
import UIKit

@MainActor
struct ComponentContainerViewModelTests {

    // MARK: - Tests

    @Test("The exposed componentViewController should match the one coming from the component's view controller")
    func componentViewController_shouldMatchComponentViewController() {
        // Given
        let (sut, _, paymentComponentMock, _, _) = makeSUT()
        let expectedComponentViewController = paymentComponentMock.viewController

        // When
        let receivedComponentViewController = sut.componentViewController

        // Then
        #expect(expectedComponentViewController === receivedComponentViewController)
    }

    @Test
    func didSubmit_shouldCallDropInFlowManagerSubmit() async {
        // Given
        let (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()

        // When
        let paymentData = makePaymentComponentData(paymentMethod: cardPaymentMethodMock)
        await confirmation { didSubmit in
            dropInFlowManagerMock.submitFromClosure = { _, _ in
                didSubmit()
                return nil
            }
            sut.didSubmit(paymentData, from: paymentComponentMock)
            await waitUntil { dropInFlowManagerMock.submitFromCalled }
        }

        // Then
        #expect(dropInFlowManagerMock.submitFromReceivedArguments?.component === paymentComponentMock)
    }

    @Test
    func didSubmit_givenAnAction_shouldPresentPaymentAction() async {
        // Given
        let (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, routerMock) = makeSUT()
        dropInFlowManagerMock.submitFromReturnValue = makeAction()

        // When
        let paymentData = makePaymentComponentData(paymentMethod: cardPaymentMethodMock)
        await confirmation { didPresentPaymentAction in
            routerMock.presentPaymentActionForClosure = { _ in didPresentPaymentAction() }
            sut.didSubmit(paymentData, from: paymentComponentMock)
            await waitUntil { routerMock.presentPaymentActionForCallsCount > 0 }
        }

        // Then
        #expect(routerMock.presentPaymentActionForCallsCount == 1)
    }

    @Test
    func didFail_givenComponentError_shouldCallDropInFlowManagerFail() {
        // Given
        let (sut, _, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()

        // When
        let errorMock = ErrorMock(errorDescription: "Payment component's error")
        sut.didFail(with: errorMock, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 1)
    }

    @Test
    func didFail_givenCancellation_shouldCallDropInFlowManagerCancel() {
        // Given
        let (sut, _, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 0)
        #expect(dropInFlowManagerMock.cancelComponentCallsCount == 1)
    }

    @Test
    func didFail_givenCancellation_shouldCallStopComponentLoading() {
        // Given
        let (sut, _, paymentComponentMock, _, _) = makeSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(paymentComponentMock.stopLoadingCallsCount == 1)
    }

    @Test
    func didFail_givenCancellation_shouldCallRouterDismiss() {
        // Given
        let (sut, _, paymentComponentMock, _, routerMock) = makeSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    // MARK: - Mocks

    private class ComponentContainerRoutingMock: ComponentContainerRouting {
        var presentPaymentComponentCallsCount = 0
        var presentPaymentComponentReceivedPaymentComponent: PaymentComponent?

        func present(paymentComponent: PaymentComponent) {
            presentPaymentComponentCallsCount += 1
            presentPaymentComponentReceivedPaymentComponent = paymentComponent
        }

        var presentPaymentActionForCallsCount = 0
        var presentPaymentActionForReceivedAction: Action?
        var presentPaymentActionForClosure: ((Action) -> Void)?

        func presentPaymentAction(for action: Action) async {
            presentPaymentActionForCallsCount += 1
            presentPaymentActionForReceivedAction = action
            presentPaymentActionForClosure?(action)
        }

        var dismissCompletionCallsCount = 0
        var dismissCompletionReceivedCompletion: (() -> Void)?

        func dismiss(completion: (() -> Void)?) {
            dismissCompletionCallsCount += 1
            dismissCompletionReceivedCompletion = completion
            completion?()
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: ComponentContainerViewModel,
        paymentMethodMock: CardPaymentMethodMock,
        paymentComponentMock: PresentablePaymentComponentMock,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: ComponentContainerRoutingMock
    ) {
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )
        let viewControllerMock = UIViewController()

        let paymentComponentMock = PresentablePaymentComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewControllerMock
        )

        let dropInFlowManagerMock = DropInFlowManagingMock()

        let sut = ComponentContainerViewModel(
            component: paymentComponentMock,
            configuration: DropInConfiguration(),
            dropInFlowManager: dropInFlowManagerMock,
            partialPaymentDelegate: nil
        )

        let routerMock = ComponentContainerRoutingMock()
        sut.router = routerMock

        return (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, routerMock)
    }

    private func makeAction() -> Action {
        .redirect(RedirectAction(url: URL(string: "https://adyen.com")!, paymentData: "payment_data"))
    }

    private func makePaymentComponentData(
        paymentMethod: AnyCardPaymentMethod,
        amountValue: Int = 1000
    ) -> PaymentComponentData {
        let encryptedCard = EncryptedCard(
            number: "4111111111111111",
            securityCode: "737",
            expiryMonth: "03",
            expiryYear: "30"
        )

        let cardDetails = CardDetails(
            paymentMethod: paymentMethod,
            encryptedCard: encryptedCard,
            holderName: "Katrina del Mar"
        )

        return PaymentComponentData(paymentMethodDetails: cardDetails, order: nil)
    }
}
