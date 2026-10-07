//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct ComponentContainerViewControllerTests {

    // MARK: - Tests

    @Test("Pushing an action on top hides the container without leaving it, so the component must not be cancelled.")
    func viewDidDisappear_whenCoveredByAPushedViewController_shouldNotCallViewModelCancel() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = UINavigationController(rootViewController: sut)
        let window = show(navigationController)
        await waitUntil { sut.view.window != nil }
        let pushedViewController = UIViewController()

        // When
        navigationController.pushViewController(pushedViewController, animated: true)

        // Then
        await waitUntil { pushedViewController.viewIfLoaded?.window != nil && sut.view.window == nil }
        #expect(viewModelMock.cancelCallsCount == 0)
        withExtendedLifetime(window) {}
    }

    @Test
    func viewDidDisappear_whenPoppedFromTheNavigationStack_shouldCallViewModelCancel() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = UINavigationController()
        navigationController.setViewControllers([UIViewController(), sut], animated: false)
        let window = show(navigationController)
        await waitUntil { sut.view.window != nil }

        // When
        navigationController.popViewController(animated: false)

        // Then
        await waitUntil { viewModelMock.cancelCallsCount > 0 }
        #expect(viewModelMock.cancelCallsCount == 1)
        withExtendedLifetime(window) {}
    }

    @Test("Dismissing the sheet the container is shown in, for example by swiping it down, cancels the component.")
    func viewDidDisappear_whenItsNavigationControllerIsDismissed_shouldCallViewModelCancel() async throws {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = UINavigationController(rootViewController: sut)
        let window = show(UIViewController())
        let presenter = try #require(window.rootViewController)
        presenter.present(navigationController, animated: false)
        await waitUntil { sut.view.window != nil }

        // When
        presenter.dismiss(animated: false)

        // Then
        await waitUntil { viewModelMock.cancelCallsCount > 0 }
        #expect(viewModelMock.cancelCallsCount == 1)
        withExtendedLifetime(window) {}
    }

    @Test
    func componentView_shouldMatchViewModelComponentViewController() async {
        // Given
        let (sut, _, expectedComponentViewController) = await makeSUT()

        // When
        let receivedComponentViewController = sut.componentViewController

        // Then
        #expect(expectedComponentViewController === receivedComponentViewController)
    }

    @Test("Verify component is added to the container")
    func viewDidLoad_shouldSetComponentViewControllerAsChild() async throws {
        // Given
        let (sut, _, componentViewControllerMock) = await makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.children.count == 1)

        let childViewController = try #require(sut.children.first)
        #expect(childViewController === componentViewControllerMock)
    }

    @Test
    func navigationItem() async {
        // Given
        let (sut, _, componentViewControllerMock) = await makeSUT()
        let expectedNavigationItemTitle = componentViewControllerMock.title

        // When
        sut.loadViewIfNeeded()
        let receivedNavigationItemTitle = sut.navigationItem.title

        // Then
        #expect(expectedNavigationItemTitle == receivedNavigationItemTitle)
        #expect(sut.navigationItem.largeTitleDisplayMode == .always)
    }

    @Test("The injected theme is applied to the container.")
    func viewDidLoad_shouldApplyTheTheme() async {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(background: .magenta))
        let (sut, _, _) = await makeSUT(theme: theme)

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.view.backgroundColor == theme.colors.background)
    }

    // MARK: - Mocks

    private class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {
        var componentViewController: UIViewController = .init()
        var theme: CheckoutTheme = .init()
        var cancelCallsCount = 0

        func cancel() {
            cancelCallsCount += 1
        }
    }

    // MARK: - Helper

    private func makeSUT(theme: CheckoutTheme = CheckoutTheme()) async -> (
        sut: ComponentContainerViewController,
        viewModelMock: ComponentContainerViewModelProtocolMock,
        componentViewControllerMock: UIViewController
    ) {
        let viewModelMock = ComponentContainerViewModelProtocolMock()
        viewModelMock.theme = theme
        let componentViewControllerMock = UIViewController()
        componentViewControllerMock.title = "Payment Component"
        viewModelMock.componentViewController = componentViewControllerMock

        let sut = ComponentContainerViewController(viewModel: viewModelMock)

        return (sut, viewModelMock, componentViewControllerMock)
    }

    private func show(_ viewController: UIViewController) -> UIWindow {
        let windowScene = UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
        let window = windowScene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.isHidden = false
        return window
    }

    private func waitUntil(timeout: TimeInterval = 3, _ condition: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try? await Task.sleep(nanoseconds: 10000000)
        }
        #expect(condition())
    }
}
