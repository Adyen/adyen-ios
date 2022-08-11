//
//  ThreeDS2ComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import AdyenActions
@testable import AdyenCard
import XCTest

extension ThreeDSResult: Equatable {
    public static func == (lhs: ThreeDSResult, rhs: ThreeDSResult) -> Bool {
        lhs.payload == rhs.payload
    }
}

class ThreeDS2ComponentTests: XCTestCase {

    func testFullFlowRedirectSuccess() throws {

        let mockedAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")

        let mockedDetails = try RedirectDetails(returnURL: URL(string: "https://google.com?redirectResult=some")!)
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")

        let threeDSActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDSActionHandler.mockedFingerprintResult = .success(.action(.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data"))))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent = redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)

            redirectComponent.delegate?.didProvide(mockedData, from: redirectComponent)
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDSActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, mockedData.paymentData)
            let details = data.details as! RedirectDetails
            XCTAssertEqual(details.redirectResult, "some")

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testFullFlowRedirectFailure() throws {
        let mockedAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.redirect(mockedAction)))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent = redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)

            redirectComponent.delegate?.didFail(with: Dummy.error, from: redirectComponent)

        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowChallengeSuccess() throws {

        let mockedAction = ThreeDS2ChallengeAction(challengeToken: "token",
                                                   authorisationToken: "AuthToken",
                                                   paymentData: "data")

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.threeDS2(.challenge(mockedAction))))
        threeDS2ActionHandler.mockedChallengeResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNil(data.paymentData)
            XCTAssertNotNil(data.details as? ThreeDS2Details)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowChallengeWrongAction() throws {

        let mockedAction = ThreeDS2ChallengeAction(challengeToken: "token",
                                                   authorisationToken: "AuthToken",
                                                   paymentData: "data")

        let mockedDetails = ThreeDS2Details.challengeResult(ThreeDSResult(payload: "payload"))

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.threeDS2Challenge(mockedAction)))
        threeDS2ActionHandler.mockedChallengeResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        delegate.onDidProvide = { data, component in
            XCTFail("didProvide should never be called")
        }
        let delegateExpectation = expectation(description: "Expect delegate didFail(with:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)

            let error = error as! ThreeDS2Component.Error
            XCTAssertEqual(error, .unexpectedAction)
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowChallengeFailure() throws {

        let mockedAction = ThreeDS2ChallengeAction(challengeToken: "token",
                                                   authorisationToken: "AuthToken",
                                                   paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.threeDS2(.challenge(mockedAction))))
        threeDS2ActionHandler.mockedChallengeResult = .failure(Dummy.error)

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowFingerprintFailure() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .failure(Dummy.error)

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFingerprintSuccess() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedDetails = ThreeDS2Details.fingerprint("fingerprint")
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")
        threeDS2ActionHandler.mockedFingerprintResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    threeDS2ClassicFlowHandler: threeDS2ActionHandler,
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, mockedData.paymentData)

            let threeDS2Details = data.details as! ThreeDS2Details

            switch threeDS2Details {
            case let .fingerprint(fingerprint):
                XCTAssertEqual(fingerprint, "fingerprint")
            default:
                XCTFail()
            }

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data"))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChallengeSuccess() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedResult = try! ThreeDSResult(authenticated: true, authorizationToken: "AuthToken")
        let mockedDetails = ThreeDS2Details.challengeResult(mockedResult)
        threeDS2ActionHandler.mockedChallengeResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    threeDS2ClassicFlowHandler: threeDS2ActionHandler,
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, "data")

            let threeDS2Details = data.details as! ThreeDS2Details

            switch threeDS2Details {
            case let .challengeResult(result):
                let data = Data(base64Encoded: result.payload)
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
                XCTAssertEqual(json?["transStatus"], "Y")
                XCTAssertEqual(json?["authorisationToken"], "AuthToken")
            default:
                XCTFail()
            }

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2ChallengeAction(challengeToken: "token", authorisationToken: "AuthToken", paymentData: "data"))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowFrictionless() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        threeDS2ActionHandler.mockedFingerprintResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(apiContext: Dummy.context,
                                    threeDS2CompactFlowHandler: threeDS2ActionHandler,
                                    threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandlerMock(),
                                    redirectComponent: redirectComponent)
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            let details = data.details as! ThreeDS2Details

            switch details {
            case let .completed(result):
                XCTAssertEqual(result, ThreeDSResult(payload: "payload"))
            default:
                XCTFail("Any other type of ThreeDS2Details should never happen.")
            }

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

}
