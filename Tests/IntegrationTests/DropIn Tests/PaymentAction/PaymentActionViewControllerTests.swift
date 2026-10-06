//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct PaymentActionViewControllerTests {

    // MARK: - Tests

    @Test("Verify the action view controller is added to the container")
    func viewDidLoad_shouldSetActionViewControllerAsChild() throws {
        // Given
        let (sut, _, actionViewControllerSpy) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.children.count == 1)

        let childViewController = try #require(sut.children.first)
        #expect(childViewController === actionViewControllerSpy)
    }

    @Test("Verify the containment life cycle is not called more than once per move")
    func viewDidLoad_shouldMoveActionViewControllerToParentOnce() throws {
        // Given
        let (sut, _, actionViewControllerSpy) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(actionViewControllerSpy.willMoveToParentInvocations.count == 1)
        #expect(actionViewControllerSpy.didMoveToParentInvocations.count == 1)

        let willMoveParent = try #require(actionViewControllerSpy.willMoveToParentInvocations.first)
        let didMoveParent = try #require(actionViewControllerSpy.didMoveToParentInvocations.first)
        #expect(willMoveParent === sut)
        #expect(didMoveParent === sut)
    }

    @Test
    func navigationItem_shouldUseActionViewControllerTitleAndShowCancelButton() throws {
        // Given
        let (sut, _, actionViewControllerSpy) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.title == actionViewControllerSpy.title)
        let cancelButton = try #require(sut.navigationItem.leftBarButtonItem)
        #expect(cancelButton.action != nil)
    }

    @Test("The injected theme is applied to the view and the navigation items.")
    func viewDidLoad_shouldApplyTheTheme() throws {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(background: .magenta, primary: .cyan))
        let (sut, _, _) = makeSUT(theme: theme)

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.view.backgroundColor == theme.colors.background)

        let cancelButton = try #require(sut.navigationItem.leftBarButtonItem)
        #expect(cancelButton.tintColor == theme.colors.primary)
    }

    @Test
    func cancelButton_shouldCallViewModelCancel() throws {
        // Given
        let (sut, viewModelMock, _) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        let cancelButton = try #require(sut.navigationItem.leftBarButtonItem)
        _ = try sut.perform(#require(cancelButton.action), with: cancelButton)

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
    }

    @Test
    func presentationControllerDidDismiss_shouldCallViewModelCancel() {
        // Given
        let (sut, viewModelMock, _) = makeSUT()

        // When
        sut.presentationControllerDidDismiss(UIPresentationController(presentedViewController: sut, presenting: nil))

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
    }

    @Test("The shopper cannot navigate back to the payment details once an action is in flight.")
    func navigationItem_shouldHideTheBackButton() {
        // Given
        let (sut, _, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.hidesBackButton)
    }

    @Test("The interactive pop gesture is disabled, so the action cannot be swiped away.")
    func viewWillAppear_shouldDisableTheInteractivePopGesture() {
        // Given
        let (sut, _, _) = makeSUT()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(sut, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true

        // When
        sut.viewWillAppear(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
    }

    @Test("The navigation controller is shared, so the pop gesture is restored on disappear.")
    func viewWillDisappear_shouldRestoreTheEnabledInteractivePopGesture() {
        // Given
        let (sut, _, _) = makeSUT()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(sut, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        sut.viewWillAppear(false)

        // When
        sut.viewWillDisappear(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
    }

    @Test("A pop gesture that was already disabled stays disabled after the action is gone.")
    func viewWillDisappear_shouldRestoreTheDisabledInteractivePopGesture() {
        // Given
        let (sut, _, _) = makeSUT()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(sut, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        sut.viewWillAppear(false)

        // When
        sut.viewWillDisappear(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
    }

    @Test("Disappearing without having appeared leaves the navigation controller untouched.")
    func viewWillDisappear_shouldNotChangeTheInteractivePopGestureWithoutAppearing() {
        // Given
        let (sut, _, _) = makeSUT()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(sut, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false

        // When
        sut.viewWillDisappear(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
    }

    // MARK: - Spies

    private class ActionViewControllerSpy: UIViewController {
        var willMoveToParentInvocations: [UIViewController?] = []
        var didMoveToParentInvocations: [UIViewController?] = []

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            willMoveToParentInvocations.append(parent)
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            didMoveToParentInvocations.append(parent)
        }
    }

    // MARK: - Helpers

    private func makeSUT(theme: CheckoutTheme = CheckoutTheme()) -> (
        sut: PaymentActionViewController,
        viewModelMock: PaymentActionViewModelProtocolMock,
        actionViewControllerSpy: ActionViewControllerSpy
    ) {
        let viewModelMock = PaymentActionViewModelProtocolMock()
        viewModelMock.theme = theme
        let actionViewControllerSpy = ActionViewControllerSpy()
        actionViewControllerSpy.title = "Payment Action"

        let sut = PaymentActionViewController(
            viewModel: viewModelMock,
            actionViewController: actionViewControllerSpy
        )

        return (sut, viewModelMock, actionViewControllerSpy)
    }
}
