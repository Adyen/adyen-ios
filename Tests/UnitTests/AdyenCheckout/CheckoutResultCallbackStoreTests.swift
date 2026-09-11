//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCheckout
import XCTest

/// Tests that ``SessionCheckoutCallbackStore/handleCompletion(resultCode:sessionId:sessionResult:)``
/// always notifies the merchant's `onComplete` handler, even when `sessionResult` is legitimately
/// unavailable (e.g. the shopper cancels, or checkout errors, before any `/payments` or
/// `/payments/details` call completes).
@MainActor
final class CheckoutResultCallbackStoreTests: XCTestCase {

    override func tearDown() {
        AdyenAssertion.listener = nil
        super.tearDown()
    }

    func test_handleCompletion_withSessionIdAndSessionResult_shouldCallOnCompleteWithBothValues() {
        let sut = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")

        sut.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            XCTAssertEqual(result.sessionId, "session_id")
            XCTAssertEqual(result.sessionResult, "session_result")
            onCompleteExpectation.fulfill()
        }

        sut.handleCompletion(resultCode: .authorised, sessionId: "session_id", sessionResult: "session_result")

        waitForExpectations(timeout: 1)
    }

    func test_handleCompletion_withCancelledResultCodeAndMissingSessionResult_shouldCallOnCompleteWithEmptySessionResultAndNotAssert() {
        let sut = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        AdyenAssertion.listener = { message in
            XCTFail("Assertion should not fire for a cancelled result with no sessionResult: \(message)")
        }

        sut.onComplete = { result in
            XCTAssertEqual(result.resultCode, .cancelled)
            XCTAssertEqual(result.sessionId, "session_id")
            XCTAssertEqual(result.sessionResult, "")
            onCompleteExpectation.fulfill()
        }

        sut.handleCompletion(resultCode: .cancelled, sessionId: "session_id", sessionResult: nil)

        waitForExpectations(timeout: 1)
    }

    func test_handleCompletion_withErrorResultCodeAndMissingSessionResult_shouldCallOnCompleteWithEmptySessionResultAndNotAssert() {
        let sut = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        AdyenAssertion.listener = { message in
            XCTFail("Assertion should not fire for an error result with no sessionResult: \(message)")
        }

        sut.onComplete = { result in
            XCTAssertEqual(result.resultCode, .error)
            XCTAssertEqual(result.sessionId, "session_id")
            XCTAssertEqual(result.sessionResult, "")
            onCompleteExpectation.fulfill()
        }

        sut.handleCompletion(resultCode: .error, sessionId: "session_id", sessionResult: nil)

        waitForExpectations(timeout: 1)
    }

    func test_handleCompletion_withAuthorisedResultCodeAndMissingSessionResult_shouldCallOnCompleteAndAssert() {
        let sut = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let assertionExpectation = expectation(description: "assertion fired")
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "Session completion called without a sessionResult.")
            assertionExpectation.fulfill()
        }

        sut.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            XCTAssertEqual(result.sessionId, "session_id")
            XCTAssertEqual(result.sessionResult, "")
            onCompleteExpectation.fulfill()
        }

        sut.handleCompletion(resultCode: .authorised, sessionId: "session_id", sessionResult: nil)

        waitForExpectations(timeout: 1)
    }

    func test_handleCompletion_withMissingSessionId_shouldCallOnCompleteWithEmptySessionIdAndAssert() {
        let sut = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let assertionExpectation = expectation(description: "assertion fired")
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "Session completion called without a sessionId.")
            assertionExpectation.fulfill()
        }

        sut.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            XCTAssertEqual(result.sessionId, "")
            XCTAssertEqual(result.sessionResult, "session_result")
            onCompleteExpectation.fulfill()
        }

        sut.handleCompletion(resultCode: .authorised, sessionId: nil, sessionResult: "session_result")

        waitForExpectations(timeout: 1)
    }
}
