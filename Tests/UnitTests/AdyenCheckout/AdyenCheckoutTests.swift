//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

final class AdyenCheckoutTests: XCTestCase {
    var mockProvider: AdyenCheckoutProviderMock!
    var configuration: CheckoutConfiguration!
    var paymentMethods: PaymentMethods!
    
    private let paymentMethodsDictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            creditCardDictionary,
            blik
        ]
    ]

    override func setUp() {
        super.setUp()
        mockProvider = AdyenCheckoutProviderMock()
        configuration = CheckoutConfiguration(context: Dummy.context)
        paymentMethods = try! AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }

    func testSetupWithSession_Success() {
        let expectedCheckout = AdyenCheckout(
            configuration: configuration,
            session: nil,
            paymentMethods: nil,
            checkoutAttemptId: "attemptId",
            presentationDelegate: nil
        )
        mockProvider.setupWithSessionResult = .success(expectedCheckout)

        let expectation = expectation(description: "Completion called")
        AdyenCheckout.setup(
            with: "sessionId",
            sessionData: "sessionData",
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        ) { result in
            if case let .success(checkout) = result {
                XCTAssertEqual(checkout.checkoutAttemptId, "attemptId")
                XCTAssertNil(checkout.paymentMethods)
                XCTAssertEqual(checkout.session?.sessionContext.data, "sessionData")
                XCTAssertEqual(checkout.session?.sessionContext.identifier, "sessionId")
            } else {
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockProvider.setupSessionCalled)
    }

    func testSetupWithSession_Failure() {
        mockProvider.setupWithSessionResult = .failure(TestError())
        
        let expectation = expectation(description: "Completion called")
        AdyenCheckout.setup(
            with: "sessionId",
            sessionData: "sessionData",
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        ) { result in
            if case let .failure(error) = result {
                XCTAssertTrue(error is TestError)
            } else {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSetupWithPaymentMethods_Success() {
        let expectedCheckout = AdyenCheckout(
            configuration: configuration,
            session: nil,
            paymentMethods: paymentMethods,
            checkoutAttemptId: "attemptId2",
            presentationDelegate: nil
        )
        
        mockProvider.setupWithPaymentMethodsResult = .success(expectedCheckout)
        
        let expectation = expectation(description: "Completion called")
        AdyenCheckout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        ) { result in
            if case let .success(checkout) = result {
                XCTAssertEqual(checkout.checkoutAttemptId, "attemptId2")
                XCTAssertNil(checkout.session)
                XCTAssertNotNil(checkout.paymentMethods)
            } else {
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockProvider.setupPaymentMethodsCalled)
    }

    func testSetupWithPaymentMethods_Failure() {
        mockProvider.setupWithPaymentMethodsResult = .failure(TestError())
        
        let expectation = expectation(description: "Completion called")
        AdyenCheckout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        ) { result in
            if case let .failure(error) = result {
                XCTAssertTrue(error is TestError)
            } else {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSetupSessionProtocolCall() {
        var didCall = false
        mockProvider.setupSessionHandler = { _, _, completion in
            didCall = true
            completion(.failure(NSError(domain: "test", code: 0)))
        }
        mockProvider.setupSession(with: configuration, order: nil) { _ in }
        XCTAssertTrue(didCall)
    }
    
    func testFetchCheckoutAttemptIdProtocolCall() {
        var didCall = false
        mockProvider.fetchCheckoutAttemptIdHandler = { _, completion in
            didCall = true
            completion(.failure(NSError(domain: "test", code: 0)))
        }
        mockProvider.fetchCheckoutAttemptId(with: configuration) { _ in }
        XCTAssertTrue(didCall)
    }
    
    // MARK: - payment component delegate
    
    func test_didSubmit_callsOnSubmit_whenSet() {
        let expectation = expectation(description: "onSubmit called")
        var didCallSubmit = false
        let blik = paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self)!
        let blikDetails = BLIKDetails(
            paymentMethod: blik,
            blikCode: "code"
        )
        let paymentData = PaymentComponentData(
            paymentMethodDetails: blikDetails,
            amount: nil,
            order: nil
        )
        
        configuration.onSubmit = { data, completion in
            didCallSubmit = true
            XCTAssertEqual(data.checkoutAttemptId, paymentData.checkoutAttemptId)
            let details = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(details.type, blikDetails.type)
            XCTAssertEqual(details.blikCode, blikDetails.blikCode)
            expectation.fulfill()
            
            completion?(CheckoutPaymentsResponse(resultCode: .authorised))
        }
        
        let sut = AdyenCheckout(
            configuration: configuration,
            checkoutAttemptId: "attemptId",
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(didCallSubmit)
    }
    
}

struct TestError: Error {}

