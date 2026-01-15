//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
@testable import AdyenUI
import Testing
import UIKit

@MainActor
struct PaymentMethodListViewModelTests {

    // MARK: - Tests

    @Test
    func paymentMethodListView_shouldReturn_listViewController() async throws {
        // Given
        let (sut, _, _) = makeSUT()

        // When
        let paymentMethodListView = sut.paymentMethodListView

        // Then
        #expect(paymentMethodListView is ListViewController)
    }

    @Test
    func cancel_shouldCallRouter_dismiss() async throws {
        // Given
        let (sut, _, routerMock) = makeSUT()

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    @Test
    func didSelect_presentableComponent_shouldStartLoadingAndPresent() async throws {
        // Given
        let (sut, _, routerMock) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didSelect(paymentComponentMock, in: sut.paymentMethodListComponent)

        // Then
        #expect(routerMock.presentPaymentComponentOnCancelCallsCount == 1)
    }

    @Test
    func didSelect_paymentInitiableComponent_shouldInitiatePayment() async throws {
        // Given
        let (sut, _, _) = makeSUT()
        let paymentMethodMock = PaymentMethodMock(type: .twint, name: "Twint")
        let initiableComponentMock = InitiableComponentMock(paymentMethod: paymentMethodMock)

        // When
        sut.didSelect(initiableComponentMock, in: sut.paymentMethodListComponent)

        // Then
        #expect(initiableComponentMock.initiatePaymentCallsCount == 1)
    }

    @Test
    func didSubmit_shoulCallDropInFlowManager_submit() async throws {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let data = makePaymentComponentDataMock()

        // When
        sut.didSubmit(data, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromActionPresenterCallsCount == 1)

        let receivedActionPresenter = dropInFlowManagerMock.submitFromActionPresenterReceivedArguments?.actionPresenter
        #expect(sut === receivedActionPresenter)
    }

    @Test
    func didFail_givenComponentError_shouldCallDropInFlowManagerFail() async throws {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let error = ErrorMock(errorDescription: "Failure")

        // When
        sut.didFail(with: error, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 1)
    }

    @Test
    func didFail_givenCancellation_shouldDismissAndStopLoading() async throws {
        // Given
        let (sut, dropInFlowManagerMock, routerMock) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didFail(with: ComponentError.cancelled, from: paymentComponentMock)

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 0)
    }

    @Test
    func presentActionComponent_shouldCallRouterPresentActionComponent() async throws {
        // Given
        let (sut, _, routerMock) = makeSUT()
        let actionComponentMock = makeActionComponentMock()

        // When
        sut.present(actionComponent: actionComponentMock)

        // Then
        #expect(routerMock.presentActionComponentOnCancelCallsCount == 1)
    }

    @Test
    func presentActionComponent_whenCancelled_shouldRunCancelCallback() async throws {
        // Given
        let (sut, _, routerMock) = makeSUT()
        let actionComponentMock = makeActionComponentMock()

        await confirmation("The cancel callback should be called") { (confirm: Confirmation) in

            // Then
            routerMock.presentActionComponentOnCancelClosure = { _, _ in
                confirm()
            }

            // When
            sut.present(actionComponent: actionComponentMock)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: PaymentMethodListViewModel,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: PaymentMethodListRoutingMock
    ) {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )

        let componentManagerMock = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: .init(),
            order: nil,
            presentationDelegate: nil
        )
        let dropInFlowManagerMock = DropInFlowManagingMock()

        let sut = PaymentMethodListViewModel(
            context: context,
            componentManager: componentManagerMock,
            configuration: DropInComponent.Configuration(),
            dropInFlowManager: dropInFlowManagerMock
        )

        let routerMock = PaymentMethodListRoutingMock()
        sut.router = routerMock

        return (sut, dropInFlowManagerMock, routerMock)
    }

    private func makePaymentComponentDataMock() -> PaymentComponentData {
        let encryptedCard = EncryptedCard(
            number: "4111111111111111",
            securityCode: "737",
            expiryMonth: "03",
            expiryYear: "30"
        )

        let cardDetails = CardDetails(
            paymentMethod: CardPaymentMethodMock(
                type: .scheme,
                name: "Card",
                brands: [.visa]
            ),
            encryptedCard: encryptedCard,
            holderName: "Katrina del Mar"
        )

        return PaymentComponentData(
            paymentMethodDetails: cardDetails,
            amount: Amount(value: 1000, currencyCode: "EUR"),
            order: nil
        )
    }

    private var paymentMethods: PaymentMethods {
        let paymentMethodsDictionary = PaymentMethodsMock.paymentMethodsDictionary
        return try! AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }

    private func makePaymentComponentMock() -> PresentableComponentMock {
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )
        let viewControllerMock = UIViewController()

        return PresentableComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewControllerMock
        )
    }

    private func makeActionComponentMock() -> PresentableComponent {
        let redirectComponent = RedirectComponent(context: contextMock)
        let viewControllerMock = UIViewController()
        return PresentableComponentWrapper(
            component: redirectComponent,
            viewController: viewControllerMock
        )
    }

    private let contextMock = AdyenContext(
        apiContext: Dummy.apiContext,
        payment: nil,
        amount: .init(value: 100, currencyCode: "EUR")
    )
}
