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
    func navigationItem_shouldUseActionViewControllerTitleAndShowDoneButton() throws {
        // Given
        let (sut, _, actionViewControllerSpy) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.title == actionViewControllerSpy.title)
        let doneButton = try #require(sut.navigationItem.rightBarButtonItem)
        #expect(doneButton.action != nil)
    }

    @Test
    func doneButton_shouldCallViewModelCancel() throws {
        // Given
        let (sut, viewModelMock, _) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        let doneButton = try #require(sut.navigationItem.rightBarButtonItem)
        _ = try sut.perform(#require(doneButton.action), with: doneButton)

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

    private func makeSUT() -> (
        sut: PaymentActionViewController,
        viewModelMock: PaymentActionViewModelProtocolMock,
        actionViewControllerSpy: ActionViewControllerSpy
    ) {
        let viewModelMock = PaymentActionViewModelProtocolMock()
        let actionViewControllerSpy = ActionViewControllerSpy()
        actionViewControllerSpy.title = "Payment Action"

        let sut = PaymentActionViewController(
            viewModel: viewModelMock,
            actionViewController: actionViewControllerSpy
        )

        return (sut, viewModelMock, actionViewControllerSpy)
    }
}
