//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
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
        let sut = ThreeDS2FingerprintSubmitter(context: Dummy.context, apiClient: apiClient)

        let mockedRedirectAction = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "data")
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

    func testThreeDSChallenge() {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(context: Dummy.context, apiClient: apiClient)

        let mockedChallengeAction = ThreeDS2ChallengeAction(challengeToken: "token", authorisationToken: "authToken", paymentData: "data")
        let mockedAction = Action.threeDS2(.challenge(mockedChallengeAction))
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
                    case let .threeDS2(.challenge(challengeAction)):
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

    func testNoAction() {
        let apiClient = APIClientMock()
        let sut = ThreeDS2FingerprintSubmitter(context: Dummy.context, apiClient: apiClient)

        let mockedDetails = ThreeDSResult(payload: "payload")
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
                case let .details(result):
                    guard let details = result as? ThreeDSResult else {
                        XCTFail("result is not ThreeDSResult")
                        return
                    }
                    XCTAssertEqual(details.payload, "payload")
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFailure() {
        let apiClient = APIClientMock()
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = ThreeDS2FingerprintSubmitter(context: Dummy.context(analyticsProvider: analyticsProviderMock), apiClient: apiClient)

        apiClient.mockedResults = [.failure(Dummy.error)]

        let submitExpectation = expectation(description: "Expect the submit completion handler to be called.")
        sut.submit(fingerprint: "fingerprint", paymentData: "data") { result in
            submitExpectation.fulfill()
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? Dummy, Dummy.error)
                XCTAssertEqual(analyticsProviderMock.errors[0].errorType, .api)
            case .success:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
