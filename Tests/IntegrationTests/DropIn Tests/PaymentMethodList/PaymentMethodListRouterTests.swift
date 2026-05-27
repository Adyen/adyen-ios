//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct PaymentMethodListRouterTests {

    @Test("This test makes sure the component's view controller is the start of the navigation flow.")
    func rootViewController_shouldHave_componentViewController_asFirstView() throws {
        // Given
        let (sut, expectedViewController, _, _, _) = makeSUT()

        // When
        let rootViewController = sut.rootViewController

        // Then
        let navigationController = try #require(rootViewController as? UINavigationController)

        let receivedViewController = navigationController.viewControllers.first
        #expect(expectedViewController == receivedViewController)
    }

    @Test
    func dismiss_shouldCall_listener_didDismissPaymentMethodList() {
        // Given
        let (sut, _, _, listenerMock, _) = makeSUT()

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(listenerMock.didDismissPaymentMethodListCompletionCallsCount == 1)
    }

    @Test
    func dismiss_shouldDeallocate_childRouter() throws {
        // Given
        let (sut, _, _, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        sut.present(component: paymentComponentMock)
        try #require(sut.childRouter != nil)

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    @Test
    func presentComponent_should_pushComponentContainerViewController() throws {
        // Given
        let (sut, _, navigationControllerSpy, _, componentContainerAssemblerMock) = makeSUT()
        let paymentComponent = makePaymentComponentMock()
        let componentContainerRouter = componentContainerAssemblerMock.resolveComponentContainerRouterForListenerReturnValue
        let expectedComponentContainerViewController = try #require(componentContainerRouter?.rootViewController)

        // When
        sut.present(component: paymentComponent)

        // Then
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 1)
        #expect(sut.childRouter === componentContainerRouter)
        let receivedComponentContainerViewController = navigationControllerSpy.capturedPushedViewController
        #expect(expectedComponentContainerViewController === receivedComponentContainerViewController)
    }

    @Test
    func presentActionComponent() {
        // Given
        let (sut, _, navigationControllerSpy, _, _) = makeSUT()
        let actionComponent = makeActionComponent()

        // When
        sut.present(actionComponent: actionComponent, onCancel: nil)

        // Then - rootViewController is the navigationController, so it receives the present call
        #expect(navigationControllerSpy.presentCallsCount == 1)
    }

    @Test
    func didDismissComponentContainer_should_deallocatedChildRouter() throws {
        // Given
        let (sut, _, _, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        sut.present(component: paymentComponentMock)
        try #require(sut.childRouter != nil)

        // When
        sut.didDismissComponentContainer(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    @Test
    func didDismissComponentContainer_shouldCallCompletion() {
        // Given
        let (sut, _, _, _, _) = makeSUT()
        var completionCalled = false

        // When
        sut.didDismissComponentContainer {
            completionCalled = true
        }

        // Then
        #expect(completionCalled == true)
    }

    @Test
    func presentComponent_givenStoredComponent_shouldPresentComponentContainerModally() {
        // Given
        let (sut, _, navigationControllerSpy, _, componentContainerAssemblerMock) = makeSUT()
        let storedPaymentComponent = makeStoredPaymentComponentMock()
        let componentContainerRouter = componentContainerAssemblerMock.resolveComponentContainerRouterForListenerReturnValue

        // When
        sut.present(component: storedPaymentComponent)

        // Then - stored components are presented modally, not pushed
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 0)
        #expect(navigationControllerSpy.presentCallsCount == 1)
        #expect(sut.childRouter === componentContainerRouter)
    }

    @Test
    func presentComponent_givenInitiableComponent_shouldNotPresentAnything() {
        // Given
        let (sut, _, navigationControllerSpy, _, componentContainerAssemblerMock) = makeSUT()
        let initiablePaymentComponent = makeInitiablePaymentComponentMock()

        // When
        sut.present(component: initiablePaymentComponent)

        // Then - initiable components are not presented by the router
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 0)
        #expect(navigationControllerSpy.presentCallsCount == 0)
        #expect(componentContainerAssemblerMock.resolveComponentContainerRouterForListenerCallsCount == 0)
        #expect(sut.childRouter == nil)
    }

    @Test
    func presentViewController_shouldPresentModally() {
        // Given
        let (sut, _, navigationControllerSpy, _, _) = makeSUT()
        let viewControllerToPresent = UIViewController()

        // When
        sut.present(viewController: viewControllerToPresent)

        // Then
        #expect(navigationControllerSpy.presentCallsCount == 1)
        #expect(navigationControllerSpy.capturedPresentedViewController === viewControllerToPresent)
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: PaymentMethodListRouter,
        viewControllerSpy: ViewControllerSpy,
        navigationControllerSpy: NavigationControllerSpy,
        listenerMock: PaymentMethodListRouterListenerMock,
        componentContainerAssemblerMock: ComponentContainerAssemblerProtocolMock
    ) {
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        let listenerMock = PaymentMethodListRouterListenerMock()

        let componentContainerRouterMock = RouterMock()
        let componentContainerAssemblerMock = ComponentContainerAssemblerProtocolMock()
        componentContainerAssemblerMock.resolveComponentContainerRouterForListenerReturnValue = componentContainerRouterMock

        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: listenerMock,
            componentContainerAssembler: componentContainerAssemblerMock
        )

        return (sut, viewControllerSpy, navigationControllerSpy, listenerMock, componentContainerAssemblerMock)
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
            amount: .init(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        let redirect = RedirectComponent(context: context)
        let viewController = UIViewController()
        return PresentableComponentWrapper(component: redirect, viewController: viewController)
    }
}
