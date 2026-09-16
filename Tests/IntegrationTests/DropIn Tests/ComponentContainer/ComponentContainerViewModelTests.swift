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
    func didSubmit_shouldCallDropInFlowManagerSubmit() {
        // Given
        let (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, _) = makeSUT()

        // When
        let paymentData = makePaymentComponentData(paymentMethod: cardPaymentMethodMock)
        sut.didSubmit(paymentData, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromActionPresenterCallsCount == 1)
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

    @Test
    func presentActionComponent_shouldCallRouterPresentActionComponent() {
        // Given
        let (sut, _, _, _, routerMock) = makeSUT()

        let actionComponentMock = UIViewController()

        // When
        sut.present(actionViewController: actionComponentMock)

        // Then
        #expect(routerMock.presentActionComponentOnCancelCallsCount == 1)
    }

    @Test
    func presentActionComponent_whenCancelled_shouldStopPaymentComponentLoading() {
        // Given
        let (sut, _, paymentComponentMock, _, routerMock) = makeSUT()

        let actionComponentMock = UIViewController()

        routerMock.presentActionComponentOnCancelClosure = { (_: UIViewController, onCancel: (() -> Void)?) in
            // Then
            onCancel?()
            #expect(paymentComponentMock.stopLoadingCallsCount == 1)
        }

        // When
        sut.present(actionViewController: actionComponentMock)
    }

    @Test
    func didCancel_shouldStopPaymentComponentLoading() {
        // Given
        let (sut, _, paymentComponentMock, _, _) = makeSUT()

        let contextMock = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: .init(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        let redirectComponent = RedirectComponent(context: contextMock)

        // When
        sut.didCancel(actionComponent: redirectComponent)

        // Then
        #expect(paymentComponentMock.stopLoadingCallsCount == 1)
    }

    // MARK: - Mocks

    private class ComponentContainerRoutingMock: ComponentContainerRouting {
        var presentPaymentComponentCallsCount = 0
        var presentPaymentComponentReceivedPaymentComponent: PresentablePaymentComponent?

        func present(paymentComponent: PresentablePaymentComponent) {
            presentPaymentComponentCallsCount += 1
            presentPaymentComponentReceivedPaymentComponent = paymentComponent
        }

        var presentActionComponentOnCancelCallsCount = 0
        var presentActionComponentOnCancelReceivedArguments: (actionViewController: UIViewController, onCancel: (() -> Void)?)?
        var presentActionComponentOnCancelClosure: ((UIViewController, (() -> Void)?) -> Void)?

        func present(actionViewController: UIViewController, onCancel: (() -> Void)?) {
            presentActionComponentOnCancelCallsCount += 1
            presentActionComponentOnCancelReceivedArguments = (actionViewController, onCancel)
            presentActionComponentOnCancelClosure?(actionViewController, onCancel)
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
