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

    @Test("A submitted payment cannot be cancelled, so the shopper cannot navigate away from it.")
    func paymentInProgress_shouldLockTheNavigation() async throws {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        _ = makeNavigationController(pushing: sut)

        // When
        viewModelMock.paymentInProgressSubject.send(true)

        // Then
        #expect(try #require(sut.navigationItem.leftBarButtonItem).isEnabled == false)
        #expect(sut.isModalInPresentation)
    }

    @Test
    func paymentInProgress_whenEnded_shouldUnlockTheNavigation() async throws {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        _ = makeNavigationController(pushing: sut)
        viewModelMock.paymentInProgressSubject.send(true)

        // When
        viewModelMock.paymentInProgressSubject.send(false)

        // Then
        #expect(try #require(sut.navigationItem.leftBarButtonItem).isEnabled)
        #expect(!sut.isModalInPresentation)
    }

    @Test("The system back button cannot be disabled, so the container shows its own one that pops it.")
    func backButton_whenTapped_shouldPopTheContainer() async throws {
        // Given
        let (sut, _, _) = await makeSUT()
        let navigationController = makeNavigationController(pushing: sut)
        let backButtonItem = try #require(sut.navigationItem.leftBarButtonItem)
        #expect(sut.navigationItem.hidesBackButton)
        #expect(backButtonItem.isEnabled)

        // When
        let action = try #require(backButtonItem.action)
        _ = backButtonItem.target?.perform(action)

        // Then
        #expect(!navigationController.viewControllers.contains(sut))
    }

    @Test
    func backButton_shouldUseThemePrimaryColor() async throws {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(primary: .magenta))
        let (sut, _, _) = await makeSUT(theme: theme)

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(try #require(sut.navigationItem.leftBarButtonItem).tintColor == theme.colors.primary)
    }

    @Test("A module presenting the container as its root can provide its own back button, which is kept and disabled.")
    func paymentInProgress_withACustomBackButton_shouldDisableIt() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()
        let customBackButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: nil, action: nil)
        sut.navigationItem.leftBarButtonItem = customBackButtonItem
        _ = makeNavigationController(pushing: sut)

        // When
        viewModelMock.paymentInProgressSubject.send(true)

        // Then
        #expect(sut.navigationItem.leftBarButtonItem === customBackButtonItem)
        #expect(!customBackButtonItem.isEnabled)

        // When
        viewModelMock.paymentInProgressSubject.send(false)

        // Then
        #expect(sut.navigationItem.leftBarButtonItem === customBackButtonItem)
        #expect(customBackButtonItem.isEnabled)
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
