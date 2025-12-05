//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
import Testing
import UIKit

struct ComponentContainerViewModelTests {

    // MARK: - Helpers

    private func setupSUT(onCancel: (() -> Void)? = nil) async -> (
        sut: ComponentContainerViewModel,
        paymentMethodMock: CardPaymentMethodMock,
        paymentComponentMock: PresentableComponentMock,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: ComponentContainerRoutingMock
    ) {
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )
        let viewControllerMock = await UIViewController()

        let paymentComponentMock = PresentableComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewControllerMock
        )

        let dropInFlowManagerMock = DropInFlowManagingMock()

        let sut = ComponentContainerViewModel(
            component: paymentComponentMock,
            configuration: DropInComponent.Configuration(),
            dropInFlowManager: dropInFlowManagerMock,
            cardComponentDelegate: nil,
            partialPaymentDelegate: nil,
            onCancel: onCancel
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

        let amount = Amount(value: amountValue, currencyCode: "EUR")
        return PaymentComponentData(paymentMethodDetails: cardDetails, amount: amount, order: nil)
    }

    // MARK: - Tests

    @Test
    func componentViewControllerShouldBeComponentViewController() async throws {
        // Given
        let (sut, _, paymentComponentMock, _, _) = await setupSUT()
        let expectedComponentViewController = paymentComponentMock.viewController

        // When
        let receivedComponentViewController = sut.componentViewController

        // Then
        #expect(expectedComponentViewController === receivedComponentViewController)
    }

    @Test
    func didSubmitShouldCallDropInFlowManagerSubmit() async throws {
        // Given
        let (sut, cardPaymentMethodMock, paymentComponentMock, dropInFlowManagerMock, _) = await setupSUT()

        // When
        let paymentData = makePaymentComponentData(paymentMethod: cardPaymentMethodMock)
        sut.didSubmit(paymentData, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromActionPresenterCallsCount == 1)
    }

    @Test
    func didFailGivenComponentErrorShouldCallDropInFlowManagerFail() async throws {
        // Given
        let (sut, _, paymentComponentMock, dropInFlowManagerMock, _) = await setupSUT()

        // When
        let errorMock = ErrorMock(errorDescription: "Payment component's error")
        sut.didFail(with: errorMock, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 1)
    }

    @Test
    func didFailGivenCancellationShouldCallDropInFlowManagerCancel() async throws {
        // Given
        let (sut, _, paymentComponentMock, dropInFlowManagerMock, _) = await setupSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 0)
        #expect(dropInFlowManagerMock.cancelComponentCallsCount == 1)
    }

    @Test
    func didFailGivenCancellationShouldCallStopComponentLoading() async throws {
        // Given
        let (sut, _, paymentComponentMock, _, _) = await setupSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(paymentComponentMock.stopLoadingCallsCount == 1)
    }

    @Test
    func didFailGivenCancellationShouldPerfomCancelCallback() async throws {
        // Given
        await withCheckedContinuation { continuation in
            let onCancelCallback: () -> Void = {
                continuation.resume()
            }

            Task {
                let (sut, _, paymentComponentMock, _, _) = await setupSUT(onCancel: onCancelCallback)

                // When
                let cancelledError = ComponentError.cancelled
                sut.didFail(with: cancelledError, from: paymentComponentMock)
            }
        }

        // Then
        #expect(true)
    }

    @Test
    func didFailGivenCancellationShouldCallRouterDismiss() async throws {
        // Given
        let (sut, _, paymentComponentMock, _, routerMock) = await setupSUT()

        // When
        let cancelledError = ComponentError.cancelled
        sut.didFail(with: cancelledError, from: paymentComponentMock)

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    @Test
    func presentActionComponentShouldCallRouterPresentActionComponent() async throws {
        // Given
        let (sut, _, _, _, routerMock) = await setupSUT()

        let contextMock = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )
        let redirectComponent = RedirectComponent(context: contextMock)
        let viewControllerMock = await UIViewController()
        let actionComponentMock = PresentableComponentWrapper(component: redirectComponent, viewController: viewControllerMock)

        // When
        sut.present(actionComponent: actionComponentMock)

        // Then
        #expect(routerMock.presentActionComponentOnCancelCallsCount == 1)
    }

    @Test
    func presentActionComponentShouldStopPaymentComponentLoadingOnCancel() async throws {
        // Given
        let (sut, _, paymentComponentMock, _, routerMock) = await setupSUT()

        let contextMock = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )
        let redirectComponent = RedirectComponent(context: contextMock)
        let viewControllerMock = await UIViewController()
        let actionComponentMock = PresentableComponentWrapper(component: redirectComponent, viewController: viewControllerMock)

        routerMock.presentActionComponentOnCancelClosure = { _, onCancel in
            // Then
            onCancel?()
            #expect(paymentComponentMock.stopLoadingCallsCount == 1)
        }

        // When
        sut.present(actionComponent: actionComponentMock)
    }

    @Test
    func didCancelShouldStopPaymentComponentLoading() async throws {
        // Given
        let (sut, _, paymentComponentMock, _, _) = await setupSUT()

        let contextMock = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )
        let redirectComponent = RedirectComponent(context: contextMock)

        // When
        sut.didCancel(actionComponent: redirectComponent)

        // Then
        #expect(paymentComponentMock.stopLoadingCallsCount == 1)
    }
}
