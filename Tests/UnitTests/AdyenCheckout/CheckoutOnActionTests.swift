//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCheckout
import UIKit
import XCTest

@MainActor
final class CheckoutOnActionTests: XCTestCase {

    private var configuration: CheckoutConfiguration!

    override func setUp() {
        super.setUp()
        configuration = CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
    }

    override func tearDown() {
        AdyenAssertion.listener = nil
        configuration = nil
        super.tearDown()
    }

    func test_onAction_isAvailableOnEveryFlow_andStoresTheHandlerOnTheCallbackStore() {
        let sessionStore = SessionCheckoutCallbackStore()
        let advancedStore = AdvancedCheckoutCallbackStore()
        let actionOnlyStore = ActionOnlyCheckoutCallbackStore()

        _ = SessionCheckout(core: makeCore(resultCallbacks: sessionStore), callbackStore: sessionStore)
            .onAction { _, _ in }
        _ = AdvancedCheckout(core: makeCore(resultCallbacks: advancedStore), callbackStore: advancedStore)
            .onAction { _, _ in }
        _ = ActionOnlyCheckout(core: makeCore(resultCallbacks: actionOnlyStore), callbackStore: actionOnlyStore)
            .onAction { _, _ in }

        XCTAssertNotNil(sessionStore.onAction)
        XCTAssertNotNil(advancedStore.onAction)
        XCTAssertNotNil(actionOnlyStore.onAction)
    }

    func test_present_withHandler_shouldForwardActionDataAndViewController() {
        // Given
        let callbackStore = AdvancedCheckoutCallbackStore()
        let sut = makeCore(resultCallbacks: callbackStore)
        let actionViewController = UIViewController()

        var receivedActionData: ActionData?
        var receivedViewController: UIViewController?
        callbackStore.onAction = { actionData, viewController in
            receivedActionData = actionData
            receivedViewController = viewController
        }

        // When
        sut.present(actionViewController: actionViewController, actionData: ActionData(type: .qrCode))

        // Then
        XCTAssertEqual(receivedActionData?.type, .qrCode)
        XCTAssertTrue(receivedViewController === actionViewController)
    }

    func test_present_withoutHandler_shouldPresentOnThePendingPaymentComponent() {
        // Given
        let sut = makeCore(resultCallbacks: AdvancedCheckoutCallbackStore())
        let presentingViewController = PresentRecordingViewController()
        let paymentComponent = PresentablePaymentComponentMock(
            paymentMethod: PaymentMethodMock(type: .scheme, name: "Card"),
            viewController: presentingViewController
        )
        sut.pendingPaymentComponent = paymentComponent
        let actionViewController = UIViewController()

        // When
        sut.present(actionViewController: actionViewController, actionData: ActionData(type: .voucher))

        // Then
        XCTAssertEqual(presentingViewController.presentedViewControllers.count, 1)
        XCTAssertTrue(presentingViewController.presentedViewControllers.first === actionViewController)
    }

    func test_present_withHandler_shouldNotPresentOnThePendingPaymentComponent() {
        // Given
        let callbackStore = AdvancedCheckoutCallbackStore()
        let sut = makeCore(resultCallbacks: callbackStore)
        let presentingViewController = PresentRecordingViewController()
        let paymentComponent = PresentablePaymentComponentMock(
            paymentMethod: PaymentMethodMock(type: .scheme, name: "Card"),
            viewController: presentingViewController
        )
        sut.pendingPaymentComponent = paymentComponent
        callbackStore.onAction = { _, _ in }

        // When
        sut.present(actionViewController: UIViewController(), actionData: ActionData(type: .threeDS2))

        // Then
        XCTAssertTrue(presentingViewController.presentedViewControllers.isEmpty)
    }

    func test_present_withoutHandlerAndWithoutPendingComponent_shouldAssert() {
        // Given
        let sut = makeCore(resultCallbacks: ActionOnlyCheckoutCallbackStore())
        let assertionExpectation = expectation(description: "Expect the assertion to be raised.")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(
                message,
                "No onAction handler is set and no payment component is available to present the action on."
            )
            assertionExpectation.fulfill()
        }

        // When
        sut.present(actionViewController: UIViewController(), actionData: ActionData(type: .await))

        // Then
        wait(for: [assertionExpectation], timeout: 10)
    }

    // MARK: - Private

    private func makeCore(resultCallbacks: any CheckoutResultCallbackStore) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            resultCallbacks: resultCallbacks,
            callbackHandler: ActionOnlyCallbackHandler(callbackStore: ActionOnlyCheckoutCallbackStore())
        )
    }
}

private final class PresentRecordingViewController: UIViewController {

    fileprivate var presentedViewControllers: [UIViewController] = []

    override func present(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentedViewControllers.append(viewControllerToPresent)
        completion?()
    }
}
