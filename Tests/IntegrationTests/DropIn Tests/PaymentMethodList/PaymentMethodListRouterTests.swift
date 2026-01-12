//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@Suite
@MainActor
struct PaymentMethodListRouterTests {

    @Test("This test makes sure the component's view controller is the start of the navigation flow.")
    func rootViewController_shouldHave_componentViewController_asFirstView() async throws {
        // Given
        let (sut, expectedViewController, _, _) = makeSUT()

        // When
        let rootViewController = sut.rootViewController

        // Then
        let navigationController = try #require(rootViewController as? UINavigationController)

        let receivedViewController = navigationController.viewControllers.first
        #expect(expectedViewController == receivedViewController)
    }

    @Test
    func dismiss_shouldCall_listener_didDismissPaymentMethodList() async throws {
        // Given
        let (sut, _, listenerMock, _) = makeSUT()

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(listenerMock.didDismissPaymentMethodListCompletionCallsCount == 1)
    }

    @Test
    func dismiss_shouldDeallocate_childRouter() async throws {
        // Given
        let (sut, _, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        sut.present(paymentComponent: paymentComponentMock) {}
        try #require(sut.childRouter != nil)

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    @Test
    func presentComponent_should_presentComponentContainerViewController() async throws {
        // Given
        let (sut, viewControllerSpy, _, componentContainerAssemblerMock) = makeSUT()
        let paymentComponent = makePaymentComponentMock()
        let componentContainerRouter = componentContainerAssemblerMock.resolveComponentContainerRouterForDelegateOnCancelReturnValue
        let expectedComponentContainerViewController = try #require(componentContainerRouter?.rootViewController)

        // When
        sut.present(paymentComponent: paymentComponent) {}

        // Then
        #expect(viewControllerSpy.presentCallsCount == 1)
        #expect(sut.childRouter === componentContainerRouter)
        let receivedComponentContainerViewController = viewControllerSpy.capturedPresentedViewController
        #expect(expectedComponentContainerViewController === receivedComponentContainerViewController)
    }

    @Test
    func presentActionComponent() async throws {
        // Given
        let (sut, viewControllerSpy, _, _) = makeSUT()
        let actionComponent = makeActionComponent()

        // When
        sut.present(actionComponent: actionComponent, onCancel: nil)

        // Then
        #expect(viewControllerSpy.presentCallsCount == 1)
    }

    @Test
    func didDismissComponentContainer_should_deallocatedChildRouter() async throws {
        // Given
        let (sut, _, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        sut.present(paymentComponent: paymentComponentMock) {}
        try #require(sut.childRouter != nil)

        // When
        sut.didDismissComponentContainer(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: PaymentMethodListRouter,
        viewControllerSpy: ViewControllerSpy,
        listenerMock: PaymentMethodListRouterListenerMock,
        componentContainerAssemblerMock: ComponentContainerAssemblerProtocolMock
    ) {
        let viewControllerSpy = ViewControllerSpy()
        let listenerMock = PaymentMethodListRouterListenerMock()

        let componentContainerRouterMock = RouterMock()
        componentContainerRouterMock.rootViewController = UIViewController()
        let componentContainerAssemblerMock = ComponentContainerAssemblerProtocolMock()
        componentContainerAssemblerMock.resolveComponentContainerRouterForDelegateOnCancelReturnValue = componentContainerRouterMock

        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            listener: listenerMock,
            componentContainerAssembler: componentContainerAssemblerMock
        )

        return (sut, viewControllerSpy, listenerMock, componentContainerAssemblerMock)
    }

    private func makePaymentComponentMock() -> PresentableComponentMock {
        let paymentMethodMock = PaymentMethodMock(type: .card, name: "Visa")
        let viewControllerMock = UIViewController()
        return PresentableComponentMock(
            paymentMethod: paymentMethodMock,
            viewController: viewControllerMock
        )
    }

    private func makeActionComponent() -> PresentableComponent {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )
        let redirect = RedirectComponent(context: context)
        let viewController = UIViewController()
        return PresentableComponentWrapper(component: redirect, viewController: viewController)
    }
}
