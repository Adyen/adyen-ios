//
//  ThreeDS2FingerprintSubmitterTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

extension RedirectAction: Equatable {
    public static func == (lhs: RedirectAction, rhs: RedirectAction) -> Bool {
        lhs.url == rhs.url && lhs.paymentData == rhs.paymentData
    }
}

extension ThreeDS2ChallengeAction: Equatable {
    public static func == (lhs: ThreeDS2ChallengeAction, rhs: ThreeDS2ChallengeAction) -> Bool {
        lhs.challengeToken == rhs.challengeToken && lhs.paymentData == rhs.paymentData
    }
}

class ThreeDS2FingerprintSubmitterTests: XCTestCase {

    func testRedirect() throws {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(apiContext: Dummy.apiContext, apiClient: apiClient)

        let mockedRedirectAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")
        let mockedAction = Action.redirect(mockedRedirectAction)
        let mockedResponse = Submit3DS2FingerprintResponse(result: .action(mockedAction))
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(result):
                switch result {
                case let .action(action):
                    switch action {
                    case let .redirect(redirectAction):
                        XCTAssertEqual(redirectAction, mockedRedirectAction)
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }

            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testThreeDSChallenge() throws {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(apiContext: Dummy.apiContext, apiClient: apiClient)

        let mockedChallengeAction = ThreeDS2ChallengeAction(challengeToken: "token", authorisationToken: "authToken", paymentData: "data")
        let mockedAction = Action.threeDS2Challenge(mockedChallengeAction)
        let mockedResponse = Submit3DS2FingerprintResponse(result: .action(mockedAction))
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(result):
                switch result {
                case let .action(action):
                    switch action {
                    case let .threeDS2Challenge(challengeAction):
                        XCTAssertEqual(challengeAction, mockedChallengeAction)
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testNoAction() throws {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(apiContext: Dummy.apiContext, apiClient: apiClient)

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        let mockedResponse = Submit3DS2FingerprintResponse(result: .details(mockedDetails))
        apiClient.mockedResults = [.success(mockedResponse)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case .failure:
                XCTFail()
            case let .success(result):
                switch result {
                case let .details(details):
                    XCTAssertTrue(details is ThreeDS2Details)
                    let details = details as! ThreeDS2Details
                    switch details {
                    case let .completed(threeDSResult):
                        XCTAssertEqual(threeDSResult.payload, "payload")
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFailure() throws {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(apiContext: Dummy.apiContext, apiClient: apiClient)

        apiClient.mockedResults = [.failure(Dummy.error)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? Dummy, Dummy.error)
            case .success:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
