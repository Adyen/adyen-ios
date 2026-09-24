//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct DropInRouterTests {

    // MARK: - Root ViewController Tests

    @Test("The drop in embeds the module it starts with in a navigation controller, so the modules can push onto it.")
    func rootViewController_shouldEmbedTheRootModuleInANavigationController() throws {
        // Given
        let paymentMethodListRouter = RouterMock()
        let sut = makeSUT(paymentMethodListRouter: paymentMethodListRouter)

        // When
        let rootViewController = sut.rootViewController

        // Then
        let navigationController = try #require(rootViewController as? UINavigationController)
        #expect(navigationController.viewControllers == [paymentMethodListRouter.rootViewController])
    }

    @Test
    func rootViewController_givenPaymentMethodListRoot_shouldRetainPaymentMethodListRouter() {
        // Given
        let paymentMethodListRouter = RouterMock()
        let sut = makeSUT(paymentMethodListRouter: paymentMethodListRouter)

        // When
        _ = sut.rootViewController

        // Then
        #expect(sut.childRouter === paymentMethodListRouter)
    }

    @Test
    func rootViewController_givenPreselectedRoot_shouldRetainPreselectedPaymentMethodRouter() throws {
        // Given
        let paymentComponent = makePaymentComponent()
        let preselectedRouter = RouterMock()
        let preselectedAssembler = PreselectedPaymentMethodAssemblerProtocolMock()
        preselectedAssembler.resolvePreselectedPaymentMethodRouterListenerComponentTitleReturnValue = preselectedRouter
        let sut = makeSUT(
            root: .preselected(paymentComponent),
            preselectedPaymentMethodAssembler: preselectedAssembler
        )

        // When
        _ = sut.rootViewController

        // Then
        #expect(sut.childRouter === preselectedRouter)
        let receivedArguments = try #require(preselectedAssembler.resolvePreselectedPaymentMethodRouterListenerComponentTitleReceivedArguments)
        #expect(receivedArguments.component === paymentComponent)
        #expect(receivedArguments.title == "Test Title")
    }

    @Test
    func rootViewController_givenComponentRoot_shouldRetainComponentContainerRouter() throws {
        // Given
        let paymentComponent = makePaymentComponent()
        let componentContainerRouter = RouterMock()
        let componentContainerAssembler = ComponentContainerAssemblerProtocolMock()
        componentContainerAssembler.resolveComponentContainerRouterForListenerReturnValue = componentContainerRouter
        let sut = makeSUT(
            root: .component(paymentComponent),
            componentContainerAssembler: componentContainerAssembler
        )

        // When
        _ = sut.rootViewController

        // Then
        #expect(sut.childRouter === componentContainerRouter)
        let receivedArguments = try #require(componentContainerAssembler.resolveComponentContainerRouterForListenerReceivedArguments)
        #expect(receivedArguments.component === paymentComponent)
    }

    // MARK: - Drop In Dismissal Tests

    @Test("Dismissing the root itself only tears down what is presented on top of it, so the presenting view controller dismisses.")
    func dismissDropIn_shouldDismissThroughThePresentingViewController() {
        // Given
        let sut = makeSUT()
        let presentation = present(sut.rootViewController)

        // When
        sut.dismissDropIn(completion: nil)

        // Then
        #expect(presentation.presenter.dismissCallsCount == 1)
    }

    @Test
    func dismissDropIn_shouldReleaseTheModuleHierarchyAndCallCompletion() throws {
        // Given
        let sut = makeSUT()
        let presentation = present(sut.rootViewController)
        try #require(sut.childRouter != nil)
        var completionCalled = false

        // When
        sut.dismissDropIn { completionCalled = true }

        // Then
        #expect(sut.childRouter == nil)
        #expect(completionCalled)
    }

    // MARK: - PaymentMethodListRouterListener Tests

    @Test("Dismissing the payment method list dismisses the drop in it is the root of.")
    func didDismissPaymentMethodList_shouldDismissTheDropIn() {
        // Given
        let sut = makeSUT()
        let presentation = present(sut.rootViewController)

        // When
        sut.didDismissPaymentMethodList(completion: nil)

        // Then
        #expect(presentation.presenter.dismissCallsCount == 1)
    }

    @Test
    func didDismissPaymentMethodList_shouldReleaseChildRouterAndCallCompletion() throws {
        // Given
        let sut = makeSUT()
        let presentation = present(sut.rootViewController)
        try #require(sut.childRouter != nil)
        var completionCalled = false

        // When
        sut.didDismissPaymentMethodList { completionCalled = true }

        // Then
        #expect(sut.childRouter == nil)
        #expect(completionCalled)
    }

    // MARK: - PreselectedPaymentMethodRouterListener Tests

    @Test("The preselected module dismisses itself, so the drop in only releases it.")
    func didDismissPreselectedPaymentMethod_shouldReleaseChildRouterAndCallCompletion() throws {
        // Given
        let preselectedAssembler = PreselectedPaymentMethodAssemblerProtocolMock()
        preselectedAssembler.resolvePreselectedPaymentMethodRouterListenerComponentTitleReturnValue = RouterMock()
        let sut = makeSUT(
            root: .preselected(makePaymentComponent()),
            preselectedPaymentMethodAssembler: preselectedAssembler
        )
        _ = sut.rootViewController
        try #require(sut.childRouter != nil)
        var completionCalled = false

        // When
        sut.didDismissPreselectedPaymentMethod { completionCalled = true }

        // Then
        #expect(sut.childRouter == nil)
        #expect(completionCalled)
    }

    // MARK: - ComponentContainerRouterListener Tests

    @Test
    func didDismissComponentContainer_shouldReleaseChildRouterAndCallCompletion() throws {
        // Given
        let componentContainerAssembler = ComponentContainerAssemblerProtocolMock()
        componentContainerAssembler.resolveComponentContainerRouterForListenerReturnValue = RouterMock()
        let sut = makeSUT(
            root: .component(makePaymentComponent()),
            componentContainerAssembler: componentContainerAssembler
        )
        _ = sut.rootViewController
        try #require(sut.childRouter != nil)
        var completionCalled = false

        // When
        sut.didDismissComponentContainer { completionCalled = true }

        // Then
        #expect(sut.childRouter == nil)
        #expect(completionCalled)
    }

    // MARK: - Spies

    /// Presents the drop in, so that its dismissal can be observed on the presenting view controller.
    private final class PresentingViewControllerSpy: UIViewController {
        var dismissCallsCount = 0

        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCallsCount += 1
            completion?()
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        root: DropInRoot = .paymentMethodList,
        paymentMethodListRouter: RouterMock? = nil,
        preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocolMock? = nil,
        componentContainerAssembler: ComponentContainerAssemblerProtocolMock? = nil
    ) -> DropInRouter {
        let paymentMethodListAssembler = PaymentMethodListAssemblerProtocolMock()
        paymentMethodListAssembler.resolvePaymentMethodListRouterListenerReturnValue = paymentMethodListRouter
            ?? makeRouterMock(rootViewController: makeViewControllerInNavigation())

        return DropInRouter(
            viewModel: DropInViewModelStub(root: root),
            preselectedPaymentMethodAssembler: preselectedPaymentMethodAssembler ?? PreselectedPaymentMethodAssemblerProtocolMock(),
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: componentContainerAssembler ?? ComponentContainerAssemblerProtocolMock()
        )
    }

    private func makeRouterMock(rootViewController: UIViewController) -> RouterMock {
        let router = RouterMock()
        router.rootViewController = rootViewController
        return router
    }

    private func makeViewControllerInNavigation() -> ViewControllerSpy {
        let viewController = ViewControllerSpy()
        viewController.setNavigationController(NavigationControllerSpy())
        return viewController
    }

    private func makePaymentComponent() -> PaymentComponentMock {
        PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .other("genericPaymentMethod"), name: "Generic"))
    }

    /// The window is returned alongside the presenter, as the presentation only holds while the window does.
    private func present(
        _ viewController: UIViewController
    ) -> (window: UIWindow, presenter: PresentingViewControllerSpy) {
        let presenter = PresentingViewControllerSpy()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = presenter
        window.isHidden = false
        presenter.present(viewController, animated: false)

        return (window, presenter)
    }
}

@MainActor
private struct DropInViewModelStub: DropInViewModelProtocol {
    let root: DropInRoot
    let title: String = "Test Title"
}
