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
        let expectedViewController = ViewControllerSpy()
        let sut = makeSUT(viewController: expectedViewController)

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
        let listenerMock = PaymentMethodListRouterListenerMock()
        let sut = makeSUT(listener: listenerMock)

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(listenerMock.didDismissPaymentMethodListCompletionCallsCount == 1)
    }

    @Test
    func dismiss_shouldDeallocate_childRouter() throws {
        // Given
        let sut = makeSUT()
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
    func presentComponent_should_pushComponentContainerViewController() {
        // Given
        let navigationControllerSpy = NavigationControllerSpy()
        let componentContainerRouter = RouterMock()
        let componentContainerAssemblerMock = makeComponentContainerAssembler(router: componentContainerRouter)
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            componentContainerAssembler: componentContainerAssemblerMock
        )
        let paymentComponent = makePaymentComponentMock()
        let expectedComponentContainerViewController = componentContainerRouter.rootViewController

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
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(navigationController: navigationControllerSpy)
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
        let managementRouter = RouterMock()
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: managementRouter)
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            storedPaymentMethodManagementAssembler: managementAssembler
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
    func presentStoredPaymentMethodManagement_whenAlreadyPresented_shouldNotPushAgain() {
        // Given
        let managementRouter = RouterMock()
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: managementRouter)
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            storedPaymentMethodManagementAssembler: managementAssembler
        )
        sut.presentStoredPaymentMethodManagement()

        // When
        sut.presentStoredPaymentMethodManagement()

        // Then
        #expect(managementAssembler.resolveCallsCount == 1)
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 1)
        #expect(sut.childRouter === managementRouter)
    }

    @Test
    func presentStoredPaymentMethodManagement_withoutCapability_shouldNotRoute() {
        // Given
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: RouterMock())
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            storedPaymentMethodManagementAssembler: managementAssembler,
            supportsStoredPaymentMethodManagement: false
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
        var removedIdentifier: String?
        let sut = makeSUT(
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
        let managementRouter = RouterMock()
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: managementRouter)
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            storedPaymentMethodManagementAssembler: managementAssembler
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
        let managementAssembler = StoredPaymentMethodManagementAssemblerSpy(router: RouterMock())
        let sut = makeSUT(
            storedPaymentMethodManagementAssembler: managementAssembler
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let navigationControllerSpy = NavigationControllerSpy()
        let componentContainerRouter = RouterMock()
        let componentContainerAssemblerMock = makeComponentContainerAssembler(router: componentContainerRouter)
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            componentContainerAssembler: componentContainerAssemblerMock
        )
        let storedPaymentComponent = makeStoredPaymentComponentMock()

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
        let navigationControllerSpy = NavigationControllerSpy()
        let componentContainerAssemblerMock = makeComponentContainerAssembler()
        let sut = makeSUT(
            navigationController: navigationControllerSpy,
            componentContainerAssembler: componentContainerAssemblerMock
        )
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
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = makeSUT(navigationController: navigationControllerSpy)
        let viewControllerToPresent = UIViewController()

        // When
        sut.present(viewController: viewControllerToPresent)

        // Then
        #expect(navigationControllerSpy.presentCallsCount == 1)
        #expect(navigationControllerSpy.capturedPresentedViewController === viewControllerToPresent)
    }

    // MARK: - Helpers

    private func makeSUT(
        viewController: ViewControllerSpy = ViewControllerSpy(),
        navigationController: NavigationControllerSpy = NavigationControllerSpy(),
        listener: PaymentMethodListRouterListenerMock? = nil,
        componentContainerAssembler: ComponentContainerAssemblerProtocolMock? = nil,
        storedPaymentMethodManagementAssembler: StoredPaymentMethodManagementAssemblerProtocol? = nil,
        supportsStoredPaymentMethodManagement: Bool = true,
        onStoredPaymentMethodRemoved: @escaping (any StoredPaymentMethod) -> Void = { _ in }
    ) -> PaymentMethodListRouter {
        viewController.setNavigationController(navigationController)
        let componentContainerAssembler = componentContainerAssembler ?? makeComponentContainerAssembler()
        let storedPaymentMethodManagementAssembler = storedPaymentMethodManagementAssembler
            ?? StoredPaymentMethodManagementAssemblerSpy(router: RouterMock())
        let storedPaymentMethodManagementCapability = supportsStoredPaymentMethodManagement
            ? StoredPaymentMethodManagementCapability(remove: { _ in })
            : nil

        return PaymentMethodListRouter(
            viewController: viewController,
            navigationController: navigationController,
            listener: listener,
            componentContainerAssembler: componentContainerAssembler,
            storedPaymentMethodManagementAssembler: storedPaymentMethodManagementAssembler,
            storedPaymentMethodManagementCapability: storedPaymentMethodManagementCapability,
            storedPaymentMethodsProvider: { [] },
            onStoredPaymentMethodRemoved: onStoredPaymentMethodRemoved
        )
    }

    private func makeComponentContainerAssembler(
        router: RouterMock? = nil
    ) -> ComponentContainerAssemblerProtocolMock {
        let assembler = ComponentContainerAssemblerProtocolMock()
        assembler.resolveComponentContainerRouterForListenerReturnValue = router ?? RouterMock()
        return assembler
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
