//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Combine
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct ComponentContainerViewControllerTests {

    // MARK: - Tests

    @Test
    func viewDidDisappear_shouldCallViewModelCancel() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()

        // When
        sut.viewDidDisappear(true)

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
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

    @Test("A sheet with the container as its root cannot be swiped away, so a submitted payment is never dismissed.")
    func init_shouldPreventTheInteractiveDismissal() async {
        // When
        let (sut, _, _) = await makeSUT()

        // Then
        #expect(sut.isModalInPresentation)
    }

    @Test("The container keeps the system back button, so swiping back works while no payment is in progress.")
    func navigationItem_shouldKeepTheSystemBackButton() async {
        // Given
        let (sut, _, _) = await makeSUT()

        // When
        let navigationController = makeNavigationController(pushing: sut)

        // Then
        #expect(sut.navigationItem.leftBarButtonItem == nil)
        #expect(!sut.navigationItem.hidesBackButton)
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
    }

    @Test("A submitted payment cannot be cancelled, so the shopper cannot navigate away from it.")
    func paymentInProgress_shouldLockTheNavigation() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = makeNavigationController(pushing: sut)

        // When
        viewModelMock.paymentInProgressSubject.send(true)

        // Then
        #expect(!navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
    }

    @Test
    func paymentInProgress_whenEnded_shouldUnlockTheNavigation() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = makeNavigationController(pushing: sut)
        viewModelMock.paymentInProgressSubject.send(true)

        // When
        viewModelMock.paymentInProgressSubject.send(false)

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
    }

    #if compiler(>=6.2)
        @Test("From iOS 26 swiping anywhere in the content pops too, so that gesture is locked as well.")
        func paymentInProgress_shouldLockTheContentPopGesture() async throws {
            guard #available(iOS 26.0, *) else { return }

            // Given
            let (sut, viewModelMock, _) = await makeSUT()
            let navigationController = makeNavigationController(pushing: sut)
            let contentPopGestureRecognizer = try #require(navigationController.interactiveContentPopGestureRecognizer)

            // When
            viewModelMock.paymentInProgressSubject.send(true)

            // Then
            #expect(!contentPopGestureRecognizer.isEnabled)

            // When
            viewModelMock.paymentInProgressSubject.send(false)

            // Then
            #expect(contentPopGestureRecognizer.isEnabled)
        }
    #endif

    @Test("A screen pushed during the payment, such as an action, gets an interactive bar and keeps its own pop gesture state.")
    func pushingAScreen_whilePaymentInProgress_shouldHandOverTheNavigation() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let navigationController = makeNavigationController(pushing: sut)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false
        window.layoutIfNeeded()
        viewModelMock.paymentInProgressSubject.send(true)

        // When
        navigationController.pushViewController(PopGestureLockingViewController(), animated: false)
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)

        // When
        viewModelMock.paymentInProgressSubject.send(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        window.isHidden = true
    }

    // MARK: - Mocks

    private class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {
        var componentViewController: UIViewController = .init()
        var theme: CheckoutTheme = .init()
        let paymentInProgressSubject = CurrentValueSubject<Bool, Never>(false)
        var paymentInProgressPublisher: AnyPublisher<Bool, Never> {
            paymentInProgressSubject.eraseToAnyPublisher()
        }

        var cancelCallsCount = 0

        func cancel() {
            cancelCallsCount += 1
        }
    }

    private final class PopGestureLockingViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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

    private func makeNavigationController(pushing sut: ComponentContainerViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.loadViewIfNeeded()
        navigationController.pushViewController(sut, animated: false)
        sut.loadViewIfNeeded()
        return navigationController
    }
}
