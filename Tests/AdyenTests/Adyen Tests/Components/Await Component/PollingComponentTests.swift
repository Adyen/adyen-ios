//
//  PollingComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenActions
import AdyenNetworking
import XCTest

class PollingComponentTests: XCTestCase {

    func testRetryWhenResultIsReceived() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .received))

        apiClient.mockedResults = [result, result, result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 3)
    }

    func testRetryWhenResultIsPending() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .pending))

        apiClient.mockedResults = [result, result, result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 3)
    }

    func testRetryWhenResultFails() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 5))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let resultPending = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .pending))
        let resultError = MockedResult.failure(Dummy.error)

        apiClient.mockedResults = [resultPending, resultError, resultPending, resultError, resultPending]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(apiClient.counter, 5)
    }

    func testFailsWhenTwoRequestsFails() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 4))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()

        let onDidFailExpectation = expectation(description: "ActionComponentDelegate.didFail must be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(error as? Dummy, Dummy.error)

            onDidFailExpectation.fulfill()
        }

        delegate.onDidProvide = { _, _ in
            XCTFail()
        }

        sut.delegate = delegate

        let resultPending = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .pending))
        let resultError = MockedResult.failure(Dummy.error)

        apiClient.mockedResults = [resultPending, resultError, resultError, resultPending]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 3)
    }

    func testNotRetryWhenResultIsRefused() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .refused))

        apiClient.mockedResults = [result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsCancelled() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .cancelled))

        apiClient.mockedResults = [result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsError() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .error))

        apiClient.mockedResults = [result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsAuthorized() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .authorised))

        apiClient.mockedResults = [result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testStopRetryingWhenUserCancels() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingComponent(apiContext: Dummy.context, apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()

        let onDidFailExpectation = expectation(description: "ActionComponentDelegate.didFail must be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(error as? ComponentError, ComponentError.cancelled)

            onDidFailExpectation.fulfill()
        }

        delegate.onDidProvide = { _, _ in
            XCTFail()
        }

        sut.delegate = delegate

        let result = MockedResult.success(PaymentStatusResponse(payload: "pay load", resultCode: .pending))

        apiClient.mockedResults = [result, result, result]

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        sut.cancelIfNeeded()

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }
}
