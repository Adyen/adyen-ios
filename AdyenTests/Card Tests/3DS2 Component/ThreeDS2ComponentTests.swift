//
//  ThreeDS2ComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenCard

extension ThreeDS2Component.ChallengeResult: Equatable {
    public static func == (lhs: ThreeDS2Component.ChallengeResult, rhs: ThreeDS2Component.ChallengeResult) -> Bool {
        lhs.payload == rhs.payload && lhs.isAuthenticated == rhs.isAuthenticated
    }
}

class ThreeDS2ComponentTests: XCTestCase {

    func testFullFlowRedirectSuccess() throws {

        let mockedAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")

        let mockedDetails = RedirectDetails(returnURL: URL(string: "https://www.adyen.com")!)
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")

        let threeDSActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDSActionHandler.mockedFullFlowResult = .success(.redirect(mockedAction))


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent = redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)


            redirectComponent.delegate?.didProvide(mockedData, from: redirectComponent)

        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDSActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, mockedData.paymentData)
            let details = data.details as! RedirectDetails
            XCTAssertEqual(details.returnURL, mockedDetails.returnURL)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowRedirectFailure() throws {
        let mockedAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFullFlowResult = .success(.redirect(mockedAction))


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent = redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)


            redirectComponent.delegate?.didFail(with: Dummy.dummyError, from: redirectComponent)

        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.dummyError)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowChallengeSuccess() throws {

        let mockedAction = ThreeDS2ChallengeAction(token: "token", paymentData: "data")

        let mockedDetails = ThreeDS2Details.challengeResult(try ThreeDS2Component.ChallengeResult(isAuthenticated: true))
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFullFlowResult = .success(.threeDS2Challenge(mockedAction))
        threeDS2ActionHandler.mockedChallengeResult = .success(mockedData)


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, mockedData.paymentData)
            XCTAssertNotNil(data.details as? ThreeDS2Details)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowChallengeFailure() throws {

        let mockedAction = ThreeDS2ChallengeAction(token: "token", paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFullFlowResult = .success(.threeDS2Challenge(mockedAction))
        threeDS2ActionHandler.mockedChallengeResult = .failure(Dummy.dummyError)


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.dummyError)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowFingerprintFailure() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFullFlowResult = .failure(Dummy.dummyError)


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.dummyError)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFingerprintSuccess() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedDetails = ThreeDS2Details.fingerprint("fingerprint")
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")
        threeDS2ActionHandler.mockedFingerprintResult = .success(mockedData)


        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
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

        sut.handle(ThreeDS2FingerprintAction(token: "token", paymentData: "data"))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFullFlowFrictionless() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFullFlowResult = .success(.threeDS2Authenticated(ThreeDS2AuthenticatedAction(token: "token", paymentData: "data")))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = ThreeDS2Component(threeDS2ActionHandler: threeDS2ActionHandler, redirectComponent: redirectComponent)
        sut.clientKey = "client_key"
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            let details = data.details as! ThreeDS2Details

            switch details {
            case let .challengeResult(result):
                XCTAssertEqual(result, try? ThreeDS2Component.ChallengeResult(isAuthenticated: true))
            default:
                XCTFail("Any other type of ThreeDS2Details should never happen.")
            }

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(token: "token", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

}
