//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
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
        let (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, routerMock) = makeSUT()

        // When
        let paymentData = makePaymentComponentData(paymentMethod: cardPaymentMethodMock)
        sut.didSubmit(paymentData, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromCallsCount == 1)
        #expect(dropInFlowManagerMock.submitFromReceivedArguments?.component === paymentComponentMock)
        // The module stays presented while the payment is in flight.
        #expect(routerMock.dismissCompletionCallsCount == 0)
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

    @Test("Closing the drop in from the container notifies the merchant and dismisses the whole drop in.")
    func cancelDropIn_shouldCancelAndDismissTheDropIn() {
        // Given
        let (sut, _, _, dropInFlowManagerMock, routerMock) = makeSUT()

        // When
        sut.cancelDropIn()

        // Then
        #expect(dropInFlowManagerMock.cancelDropInCallsCount == 1)
        #expect(dropInFlowManagerMock.dismissDropInCallsCount == 1)
        #expect(dropInFlowManagerMock.cancelComponentCallsCount == 0)
        #expect(routerMock.dismissCompletionCallsCount == 0)
    }

    @Test
    func viewDidDisappear_whenLeavingScreen_shouldCancelComponent() {
        // Given
        let (sut, _, _, dropInFlowManagerMock, routerMock) = makeSUT()

        // When
        sut.viewDidDisappear(isLeavingScreen: true)

        // Then
        #expect(dropInFlowManagerMock.cancelComponentCallsCount == 1)
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    @Test
    func viewDidDisappear_whenScreenIsCovered_shouldNotCancelComponent() {
        // Given
        let (sut, _, paymentComponentMock, dropInFlowManagerMock, routerMock) = makeSUT()

        // When
        sut.viewDidDisappear(isLeavingScreen: false)

        // Then
        #expect(dropInFlowManagerMock.cancelComponentCallsCount == 0)
        #expect(paymentComponentMock.stopLoadingCallsCount == 0)
        #expect(routerMock.dismissCompletionCallsCount == 0)
    }

    // MARK: - Mocks

    private class ComponentContainerRoutingMock: ComponentContainerRouting {
        var childRouter: Router?
        var rootViewController: UIViewController = .init()

        var presentPaymentComponentCallsCount = 0
        var presentPaymentComponentReceivedPaymentComponent: PaymentComponent?

        func present(paymentComponent: PaymentComponent) {
            presentPaymentComponentCallsCount += 1
            presentPaymentComponentReceivedPaymentComponent = paymentComponent
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
            theme: CheckoutTheme(),
            configuration: DropInConfiguration(),
            dropInFlowManager: dropInFlowManagerMock,
            partialPaymentDelegate: nil,
            isDropInRoot: false
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
