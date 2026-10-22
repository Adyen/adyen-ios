//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCheckout
import UIKit
import XCTest

@MainActor
final class CheckoutCallbacksTests: XCTestCase {

    override func tearDown() {
        AdyenAssertion.listener = nil
        super.tearDown()
    }

    func test_sessionCompletion_shouldForwardResultAndSessionIdentifiers() {
        var received: CheckoutResult?
        let callbacks = CheckoutCallbacks(onComplete: { received = $0 }, onFailure: { _ in XCTFail("Unexpected failure") })

        callbacks.handleCompletion(resultCode: .authorised, sessionId: "session-id", sessionResult: "session-result")

        XCTAssertEqual(received?.resultCode, .authorised)
        XCTAssertEqual(received?.sessionId, "session-id")
        XCTAssertEqual(received?.sessionResult, "session-result")
    }

    func test_sessionCompletion_withoutSessionIdentifiers_shouldAssertWithoutCallingCompletion() {
        let asserted = expectation(description: "Missing session identifiers")
        asserted.expectedFulfillmentCount = 2
        AdyenAssertion.listener = { _ in asserted.fulfill() }
        let callbacks = CheckoutCallbacks.test(onComplete: { _ in XCTFail("Unexpected completion") })

        callbacks.handleCompletion(resultCode: .authorised, sessionId: nil, sessionResult: "result")
        callbacks.handleCompletion(resultCode: .authorised, sessionId: "id", sessionResult: nil)

        wait(for: [asserted], timeout: 1)
    }

    func test_beforeSubmitModifier_shouldLeaveTheOriginalUnchanged() async {
        let original = CheckoutCallbacks.test()
        let updated = original.onBeforeSubmit { _ in .abort }

        XCTAssertNil(original.onBeforeSubmit)
        let result = await updated.onBeforeSubmit?(BeforeSubmitData())
        guard case .abort = result else { return XCTFail("Expected abort") }
    }

    func test_beforeSubmitModifier_whenRepeated_shouldUseTheLastHandler() async {
        let callbacks = CheckoutCallbacks.test()
            .onBeforeSubmit { _ in XCTFail("Replaced handler"); return .abort }
            .onBeforeSubmit { data in .proceed(data: data, sessionData: "updated") }

        let result = await callbacks.onBeforeSubmit?(BeforeSubmitData())

        guard case let .proceed(_, sessionData) = result else { return XCTFail("Expected proceed") }
        XCTAssertEqual(sessionData, "updated")
    }

    func test_failureCallbacks_shouldForwardTheSameCheckoutErrorForEveryFlow() {
        let failed = expectation(description: "Failure for every flow")
        failed.expectedFulfillmentCount = 3
        let error = CheckoutError(code: .cancelled, message: "Cancelled")
        let onFailure: CheckoutFailureHandler = { received in
            XCTAssertEqual(received.code, error.code)
            XCTAssertEqual(received.localizedDescription, error.localizedDescription)
            failed.fulfill()
        }
        let callbacks: [any CheckoutResultCallbacks] = [
            CheckoutCallbacks.test(onFailure: onFailure),
            AdvancedCheckoutCallbacks.test(onFailure: onFailure),
            ActionOnlyCheckoutCallbacks.test(onFailure: onFailure)
        ]

        callbacks.forEach { $0.onFailure(error) }

        wait(for: [failed], timeout: 1)
    }

    func test_advancedCompletion_shouldNotRequireSessionIdentifiers() {
        var received: AdvancedCheckoutResult?
        let callbacks = AdvancedCheckoutCallbacks.test(onComplete: { received = $0 })

        callbacks.handleCompletion(resultCode: .authorised, sessionId: nil, sessionResult: nil)

        XCTAssertEqual(received?.resultCode, .authorised)
    }

    func test_actionOnlyCompletionModifier_shouldLeaveTheOriginalUnchanged() {
        let original = ActionOnlyCheckoutCallbacks.test()
        var received: AdvancedCheckoutResult?
        let updated = original.onComplete { received = $0 }

        original.handleCompletion(resultCode: .refused, sessionId: nil, sessionResult: nil)
        XCTAssertNil(received)
        updated.handleCompletion(resultCode: .authorised, sessionId: nil, sessionResult: nil)

        XCTAssertNil(original.onComplete)
        XCTAssertEqual(received?.resultCode, .authorised)
    }

    func test_actionModifier_whenRepeated_shouldUseTheLastHandler() {
        var receivedType: ActionType?
        let callbacks = CheckoutCallbacks.test()
            .onAction { _, _ in XCTFail("Replaced handler") }
            .onAction { data, _ in receivedType = data.type }

        callbacks.onAction?(ActionData(type: .voucher), UIViewController())

        XCTAssertEqual(receivedType, .voucher)
    }
}
