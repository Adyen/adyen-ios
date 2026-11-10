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

    func test_checkoutHandle_shouldForwardActionAndRetainCoreUntilReleased() {
        var checkout: Checkout? = Checkout(core: makeCore(resultCallbacks: CheckoutCallbacks.test()))
        weak var core = checkout?.core as? CheckoutCore
        let actionHandler = ActionHandlingComponentMock()
        var receivedRedirect = false
        actionHandler.onAction = { action in
            guard case .redirect = action else { return XCTFail("Expected a redirect action") }
            receivedRedirect = true
        }
        core?.actionHandlingComponent = actionHandler

        XCTAssertNotNil(core)
        checkout?.handle(action: Dummy.redirectAction)

        XCTAssertTrue(receivedRedirect)
        checkout = nil
        XCTAssertNil(core)
    }

    func test_actionOnlyHandle_shouldForwardActionAndRetainCoreUntilReleased() {
        var checkout: ActionOnlyCheckout? = ActionOnlyCheckout(core: makeCore(resultCallbacks: ActionOnlyCheckoutCallbacks.test()))
        weak var core = checkout?.core as? CheckoutCore
        let actionHandler = ActionHandlingComponentMock()
        var receivedRedirect = false
        actionHandler.onAction = { action in
            guard case .redirect = action else { return XCTFail("Expected a redirect action") }
            receivedRedirect = true
        }
        core?.actionHandlingComponent = actionHandler

        XCTAssertNotNil(core)
        checkout?.handle(action: Dummy.redirectAction)

        XCTAssertTrue(receivedRedirect)
        checkout = nil
        XCTAssertNil(core)
    }

    func test_onAction_isAvailableOnEveryCallbacksValue_andDoesNotChangeTheOriginal() {
        let session = CheckoutCallbacks.test()
        let advanced = AdvancedCheckoutCallbacks.test()
        let actionOnly = ActionOnlyCheckoutCallbacks.test()

        XCTAssertNotNil(session.onAction { _, _ in }.onAction)
        XCTAssertNotNil(advanced.onAction { _, _ in }.onAction)
        XCTAssertNotNil(actionOnly.onAction { _, _ in }.onAction)
        XCTAssertNil(session.onAction)
        XCTAssertNil(advanced.onAction)
        XCTAssertNil(actionOnly.onAction)
    }

    func test_present_withHandler_shouldForwardActionDataAndViewController() {
        // Given
        let actionViewController = UIViewController()

        var receivedActionData: ActionData?
        var receivedViewController: UIViewController?
        let callbacks = AdvancedCheckoutCallbacks.test().onAction { actionData, viewController in
            receivedActionData = actionData
            receivedViewController = viewController
        }

        let sut = makeCore(resultCallbacks: callbacks)

        // When
        sut.present(actionViewController: actionViewController, actionData: ActionData(type: .qrCode))

        // Then
        XCTAssertEqual(receivedActionData?.type, .qrCode)
        XCTAssertTrue(receivedViewController === actionViewController)
    }

    func test_present_withoutHandler_shouldPresentOnThePendingPaymentComponent() {
        // Given
        let sut = makeCore(resultCallbacks: AdvancedCheckoutCallbacks.test())
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
        let presentingViewController = PresentRecordingViewController()
        let paymentComponent = PresentablePaymentComponentMock(
            paymentMethod: PaymentMethodMock(type: .scheme, name: "Card"),
            viewController: presentingViewController
        )
        let callbacks = AdvancedCheckoutCallbacks.test().onAction { _, _ in }

        let sut = makeCore(resultCallbacks: callbacks)
        sut.pendingPaymentComponent = paymentComponent

        // When
        sut.present(actionViewController: UIViewController(), actionData: ActionData(type: .threeDS2))

        // Then
        XCTAssertTrue(presentingViewController.presentedViewControllers.isEmpty)
    }

    func test_present_withoutHandlerAndWithoutPendingComponent_shouldAssert() {
        // Given
        let sut = makeCore(resultCallbacks: ActionOnlyCheckoutCallbacks.test())
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

    private func makeCore(resultCallbacks: any CheckoutResultCallbacks) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            resultCallbacks: resultCallbacks,
            callbackHandler: ActionOnlyCallbackHandler(callbacks: ActionOnlyCheckoutCallbacks.test())
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
