//
//  ThreeDS2FingerprintSubmitterTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenCard

extension RedirectAction: Equatable {
    public static func == (lhs: RedirectAction, rhs: RedirectAction) -> Bool {
        lhs.url == rhs.url && lhs.paymentData == rhs.paymentData
    }
}

extension ThreeDS2ChallengeAction: Equatable {
    public static func == (lhs: ThreeDS2ChallengeAction, rhs: ThreeDS2ChallengeAction) -> Bool {
        lhs.token == rhs.token && lhs.paymentData == rhs.paymentData
    }
}

class ThreeDS2FingerprintSubmitterTests: XCTestCase {

    func testRedirect() throws {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 1))
        let sut = ThreeDS2FingerprintSubmitter(apiClient: retryApiClient)
        sut.clientKey = "clientKey"

        let mockedAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")
        let mockedResponse = Submit3DS2FingerprintResponse(action: .redirect(mockedAction))
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(action):
                switch action {
                case let .redirect(redirectAction):
                    XCTAssertEqual(redirectAction, mockedAction)
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testThreeDSChallenge() throws {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 1))
        let sut = ThreeDS2FingerprintSubmitter(apiClient: retryApiClient)
        sut.clientKey = "clientKey"

        let mockedAction = ThreeDS2ChallengeAction(token: "token", paymentData: "data")
        let mockedResponse = Submit3DS2FingerprintResponse(action: .threeDS2Challenge(mockedAction))
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(action):
                switch action {
                case let .threeDS2Challenge(threeDS2Challenge):
                    XCTAssertEqual(threeDS2Challenge, mockedAction)
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testNoAction() throws {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 1))
        let sut = ThreeDS2FingerprintSubmitter(apiClient: retryApiClient)
        sut.clientKey = "clientKey"

        let mockedResponse = Submit3DS2FingerprintResponse(action: nil)
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(action):
                XCTAssertNil(action)
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFailure() throws {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 1))
        let sut = ThreeDS2FingerprintSubmitter(apiClient: retryApiClient)
        sut.clientKey = "clientKey"

        apiClient.mockedResults = [.failure(Dummy.dummyError)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? Dummy, Dummy.dummyError)
            case .success:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
