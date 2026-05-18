//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import Combine
import Testing
import UIKit

@MainActor
struct PaymentMethodListViewModelTests {

    // MARK: - Protocol Conformance Tests

    @Test
    func title_shouldReturnLocalizedPaymentMethodsTitle() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        let expectedTitle = localizedString(.paymentMethodsTitle, LocalizationParameters())
        #expect(sut.title == expectedTitle)
    }

    @Test
    func paymentMethodSections_shouldMatchComponentManagerSections() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        #expect(sut.paymentMethodSections.isEmpty == false)
    }

    // MARK: - State Tests

    @Test
    func initialState_shouldBeIdle() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle")
        }
    }

    @Test
    func didLoad_shouldTransitionToLoadedState() {
        // Given
        let (sut, _, _) = makeSUT()

        // When
        sut.didLoad()

        // Then
        if case let .loaded(sections) = sut.state {
            #expect(sections.isEmpty == false)
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }

    // MARK: - Cancel Tests

    @Test
    func cancel_shouldCallRouterDismiss() {
        // Given
        let (sut, _, routerMock) = makeSUT()

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    // MARK: - PaymentComponentDelegate Tests

    @Test
    func didSubmit_shouldCallDropInFlowManagerSubmit() {
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
    func didFail_givenError_shouldCallDropInFlowManagerFail() {
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
    func didFail_givenError_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let error = ErrorMock(errorDescription: "Failure")

        // When
        sut.didFail(with: error, from: paymentComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after failure")
        }
    }

    @Test
    func didFail_givenCancellation_shouldNotCallDropInFlowManagerFail() {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didFail(with: ComponentError.cancelled, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 0)
    }

    @Test
    func didFail_givenCancellation_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didFail(with: ComponentError.cancelled, from: paymentComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after cancellation")
        }
    }

    // MARK: - ActionPresenter Tests

    @Test
    func presentActionComponent_shouldCallRouterPresentActionComponent() {
        // Given
        let (sut, _, routerMock) = makeSUT()
        let actionComponentMock = makeActionComponentMock()

        // When
        sut.present(actionComponent: actionComponentMock)

        // Then
        #expect(routerMock.presentActionComponentOnCancelCallsCount == 1)
    }

    @Test
    func didCancelActionComponent_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let actionComponentMock = RedirectComponent(context: contextMock)

        // When
        sut.didCancel(actionComponent: actionComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after action cancel")
        }
    }

    // MARK: - Mocks

    private class DropInFlowManagingMock: DropInFlowManaging {
        var submitFromActionPresenterCallsCount = 0
        var submitFromActionPresenterReceivedArguments: (
            data: PaymentComponentData,
            component: PaymentComponent,
            actionPresenter: ActionPresenter
        )?

        func submit(
            _ data: PaymentComponentData,
            from component: PaymentComponent,
            actionPresenter: ActionPresenter
        ) {
            submitFromActionPresenterCallsCount += 1
            submitFromActionPresenterReceivedArguments = (data, component, actionPresenter)
        }

        var failWithFromCallsCount = 0
        var failWithFromReceivedArguments: (error: Error, component: PaymentComponent)?

        func fail(with error: Error, from component: PaymentComponent) {
            failWithFromCallsCount += 1
            failWithFromReceivedArguments = (error, component)
        }

        var cancelComponentCallsCount = 0
        var cancelComponentReceivedComponent: PaymentComponent?

        func cancel(component: PaymentComponent) {
            cancelComponentCallsCount += 1
            cancelComponentReceivedComponent = component
        }

        var handleActionCallsCount = 0
        var handleActionReceivedAction: Action?

        func handle(action: Action) {
            handleActionCallsCount += 1
            handleActionReceivedAction = action
        }
    }

    private class PaymentMethodListRoutingMock: PaymentMethodListRouting {
        var presentComponentCallsCount = 0
        var presentComponentReceivedComponent: PaymentComponent?

        func present(component: PaymentComponent) {
            presentComponentCallsCount += 1
            presentComponentReceivedComponent = component
        }

        var presentViewControllerCallsCount = 0
        var presentViewControllerReceivedViewController: UIViewController?

        func present(viewController: UIViewController) {
            presentViewControllerCallsCount += 1
            presentViewControllerReceivedViewController = viewController
        }

        var presentActionComponentOnCancelCallsCount = 0
        var presentActionComponentOnCancelReceivedArguments: (actionComponent: PresentableComponent, onCancel: (() -> Void)?)?

        func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?) {
            presentActionComponentOnCancelCallsCount += 1
            presentActionComponentOnCancelReceivedArguments = (actionComponent, onCancel)
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
        sut: PaymentMethodListViewModel,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: PaymentMethodListRoutingMock
    ) {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: .init(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )

        let componentManagerMock = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: .init(),
            order: nil,
            presentationDelegate: nil
        )
        let dropInFlowManagerMock = DropInFlowManagingMock()
        let logoURLProvider = LogoURLProvider(environment: context.apiContext.environment)

        let sut = PaymentMethodListViewModel(
            context: context,
            localizationParameters: LocalizationParameters(),
            componentManager: componentManagerMock,
            configuration: DropInComponent.Configuration(),
            dropInFlowManager: dropInFlowManagerMock,
            logoURLProvider: logoURLProvider,
            theme: TestTheme.distinctive()
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
        amount: .init(value: 100, currencyCode: "EUR"),
        publicKey: Dummy.publicKey,
        analyticsProvider: AnalyticsProviderMock()
    )
}
