//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct PaymentMethodListRouterTests {

    // MARK: - Root ViewController Tests

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
        #expect(!navigationController.navigationBar.prefersLargeTitles)
    }

    // MARK: - Dismiss Tests

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

    // MARK: - Present Component Tests

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
        sut.present(actionViewController: actionComponent, onCancel: nil)

        // Then - rootViewController is the navigationController, so it receives the present call
        #expect(navigationControllerSpy.presentCallsCount == 1)
    }

    // MARK: - StoredPaymentMethodManagement Tests

    @Test
    func presentStoredPaymentMethodManagement_shouldPushAndRetainManagementRouter() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        let managementRouter = RouterMock()
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: managementRouter)
        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: nil,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock(),
            storedPaymentMethodManagementAssembler: managementAssembler,
            storedPaymentMethodManagementCapability: .init(remove: { _ in }),
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { _ in }
        )

        // When
        sut.presentStoredPaymentMethodManagement()

        // Then
        #expect(managementAssembler.resolveCallsCount == 1)
        #expect(sut.childRouter === managementRouter)
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 1)
        #expect(navigationControllerSpy.capturedPushedViewController === managementRouter.rootViewController)
    }

    @Test
    func presentStoredPaymentMethodManagement_withoutCapability_shouldNotRoute() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: RouterMock())
        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: nil,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock(),
            storedPaymentMethodManagementAssembler: managementAssembler,
            storedPaymentMethodManagementCapability: nil,
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { _ in }
        )

        // When
        sut.presentStoredPaymentMethodManagement()

        // Then
        #expect(managementAssembler.resolveCallsCount == 0)
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 0)
        #expect(sut.childRouter == nil)
    }

    @Test
    func didRemoveStoredPaymentMethod_shouldForwardToParentList() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        var removedIdentifier: String?
        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: nil,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock(),
            storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerSpy(router: RouterMock()),
            storedPaymentMethodManagementCapability: .init(remove: { _ in }),
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { removedIdentifier = $0.identifier }
        )
        let paymentMethod = StoredPaymentMethodMock(
            identifier: "stored-payment-method-id",
            supportedShopperInteractions: [.shopperPresent],
            type: .scheme,
            name: "Stored Card"
        )

        // When
        sut.didRemoveStoredPaymentMethod(paymentMethod)

        // Then
        #expect(removedIdentifier == paymentMethod.identifier)
    }

    @Test
    func didRequestPaymentOptions_shouldPopAndReleaseChildRouter() throws {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        let managementRouter = RouterMock()
        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: nil,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock(),
            storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerSpy(router: managementRouter),
            storedPaymentMethodManagementCapability: .init(remove: { _ in }),
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { _ in }
        )
        sut.presentStoredPaymentMethodManagement()
        try #require(sut.childRouter != nil)

        // When
        sut.didRequestPaymentOptions()

        // Then
        #expect(navigationControllerSpy.popViewControllerCallsCount == 1)
        #expect(sut.childRouter == nil)
    }

    @Test
    func didDismissStoredPaymentMethodManagement_shouldReleaseChildRouter() throws {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.setNavigationController(navigationControllerSpy)
        let managementRouter = RouterMock()
        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: nil,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock(),
            storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerSpy(router: managementRouter),
            storedPaymentMethodManagementCapability: .init(remove: { _ in }),
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { _ in }
        )
        sut.presentStoredPaymentMethodManagement()
        try #require(sut.childRouter != nil)

        // When
        sut.didDismissStoredPaymentMethodManagement()

        // Then
        #expect(sut.childRouter == nil)
    }

    // MARK: - ComponentContainerRouterListener Tests

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
        let storedPaymentMethodManagementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: RouterMock())

        let sut = PaymentMethodListRouter(
            viewController: viewControllerSpy,
            navigationController: navigationControllerSpy,
            listener: listenerMock,
            componentContainerAssembler: componentContainerAssemblerMock,
            storedPaymentMethodManagementAssembler: storedPaymentMethodManagementAssembler,
            storedPaymentMethodManagementCapability: .init(remove: { _ in }),
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: { _ in }
        )

        return (sut, viewControllerSpy, navigationControllerSpy, listenerMock, componentContainerAssemblerMock)
    }

    private func makePaymentComponentMock() -> PresentablePaymentComponentMock {
        let paymentMethodMock = PaymentMethodMock(type: .card, name: "Visa")
        let viewControllerMock = UIViewController()
        return PresentablePaymentComponentMock(
            paymentMethod: paymentMethodMock,
            viewController: viewControllerMock
        )
    }

    private func makeActionComponent() -> UIViewController {
        UIViewController()
    }

    private func makeStoredPaymentComponentMock() -> StoredComponentMock {
        let paymentMethodMock = PaymentMethodMock(type: .scheme, name: "Stored Card")
        let viewControllerMock = UIViewController()
        return StoredComponentMock(
            paymentMethod: paymentMethodMock,
            viewController: viewControllerMock
        )
    }

    private func makeInitiablePaymentComponentMock() -> PaymentComponentMock {
        let paymentMethodMock = PaymentMethodMock(type: .applePay, name: "Apple Pay")
        return PaymentComponentMock(paymentMethod: paymentMethodMock)
    }
}

@MainActor
private final class StoredPaymentMethodManagementAssemblerSpy: StoredPaymentMethodManagementAssemblerProtocol {

    private let router: Router
    private(set) var resolveCallsCount = 0

    init(router: Router) {
        self.router = router
    }

    func resolveStoredPaymentMethodManagementRouter(
        paymentMethods: [any StoredPaymentMethod],
        capability: StoredPaymentMethodManagementCapability,
        listener: StoredPaymentMethodManagementListener
    ) -> Router {
        resolveCallsCount += 1
        return router
    }
}
