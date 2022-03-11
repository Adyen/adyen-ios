//
//  SessionTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/8/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenSession
import Adyen
import AdyenActions
import AdyenComponents
import AdyenDropIn

class SessionTests: XCTestCase {

    func testInitialization() throws {
        let apiClient = APIClientMock()
        let dictionary = [
            "storedPaymentMethods": [
                storedCreditCardDictionary,
                storedCreditCardDictionary,
                storedPayPalDictionary,
                storedBcmcDictionary
            ],
            "paymentMethods": [
                creditCardDictionary,
                issuerListDictionary
            ]
        ]
        let expectedPaymentMethods = try Coder.decode(dictionary) as PaymentMethods
        apiClient.mockedResults = [.success(SessionSetupResponse(countryCode: "US",
                                                                 shopperLocale: "US",
                                                                 paymentMethods: expectedPaymentMethods,
                                                                 amount: .init(value: 220, currencyCode: "USD"),
                                                                 sessionData: "session_data_1"))]
        let expectation = expectation(description: "Expect session object to be initialized")
        Session.initialize(with: .init(sessionIdentifier: "session_id",
                                       initialSessionData: "session_data_0",
                                       apiContext: Dummy.context),
                           baseAPIClient: apiClient) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(session):
                XCTAssertEqual(session.sessionContext.identifier, "session_id")
                XCTAssertEqual(session.sessionContext.data, "session_data_1")
                XCTAssertEqual(session.sessionContext.shopperLocale, "US")
                XCTAssertEqual(session.sessionContext.countryCode, "US")
                XCTAssertEqual(session.sessionContext.paymentMethods, expectedPaymentMethods)
                XCTAssertEqual(session.sessionContext.amount, .init(value: 220, currencyCode: "USD"))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithNoActionAndNoOrder() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: .init(
                value: 20,
                currencyCode: "USD",
                localeIdentifier: nil
            ),
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       apiContext: Dummy.context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        apiClient.mockedResults = [.success(PaymentsResponse(resultCode: .authorised,
                                                             action: nil,
                                                             order: nil,
                                                             sessionData: "session_data"))]
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    private let paymentMethodsDictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            creditCardDictionary,
            issuerListDictionary,
            mbway
        ]
    ]
    
    func testDidSubmitWithActionAndNoOrder() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: .init(
                value: 20,
                currencyCode: "USD",
                localeIdentifier: nil
            ),
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       apiContext: Dummy.context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        let expectedAction = RedirectAction(
            url: URL(string: "https://google.com")!,
            paymentData: "payment_data"
        )
        apiClient.mockedResults = [.success(PaymentsResponse(resultCode: .authorised,
                                                             action: .redirect(
                                                                expectedAction
                                                             ),
                                                             order: nil,
                                                             sessionData: "session_data"))]
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        
        let actionExpectation = expectation(description: "Expect action to be handled")
        let actionComponent = ActionHandlingComponentMock()
        actionComponent.onAction = { action in
            switch action {
            case let .redirect(redirect):
                XCTAssertEqual(redirect.paymentData, expectedAction.paymentData)
                XCTAssertEqual(redirect.url, expectedAction.url)
            default:
                XCTFail()
            }
            actionExpectation.fulfill()
        }
        sut.actionComponent = actionComponent
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithOrderAndNoAction() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: .init(
                value: 20,
                currencyCode: "USD",
                localeIdentifier: nil
            ),
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       apiContext: Dummy.context)
        let dropInComponent = DropInComponent(paymentMethods: expectedPaymentMethods,
                                              configuration: .init(apiContext: Dummy.context),
                                              title: nil)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        let expectedOrder = PartialPaymentOrder(pspReference: "pspReference",
                                                orderData: "order_data",
                                                reference: "reference",
                                                amount: .init(
                                                    value: 220,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                remainingAmount: .init(
                                                    value: 20,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                expiresAt: Date())
        let expectedAmount = Amount(
            value: 440,
            currencyCode: "EGP",
            localeIdentifier: nil
        )
        apiClient.mockedResults = [
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: nil,
                    order: expectedOrder,
                    sessionData: "session_data"
                )
            ),
            .success(
                SessionSetupResponse(countryCode: "EG",
                                     shopperLocale: "EG",
                                     paymentMethods: expectedPaymentMethods,
                                     amount: expectedAmount,
                                     sessionData: "session_data_xxx")
            )
        ]
        let apiCallsExpectation = expectation(description: "Expect two API calls to be made")
        apiCallsExpectation.expectedFulfillmentCount = 2
        apiClient.onExecute = {
            apiCallsExpectation.fulfill()
        }
        sut.didSubmit(data, from: component, in: dropInComponent)
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(sut.sessionContext.amount, expectedAmount)
        XCTAssertEqual(sut.sessionContext.countryCode, "EG")
        XCTAssertEqual(sut.sessionContext.shopperLocale, "EG")
        XCTAssertEqual(sut.sessionContext.data, "session_data_xxx")
    }
    
    private func initializeSession(expectedPaymentMethods: PaymentMethods) throws -> Session {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(
                SessionSetupResponse(
                    countryCode: "US",
                    shopperLocale: "US",
                    paymentMethods: expectedPaymentMethods,
                    amount: .init(
                        value: 220,
                        currencyCode: "USD"
                    ),
                    sessionData: "session_data_1"
                )
            )
        ]
        var sut: Session! = nil
        let initializationExpectation = expectation(description: "Expect session object to be initialized")
        Session.initialize(with: .init(sessionIdentifier: "session_id",
                                             initialSessionData: "session_data_0",
                                             apiContext: Dummy.context),
                                 baseAPIClient: apiClient) { result in
            switch result {
            case let .success(session):
                sut = session
                initializationExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
        return sut
    }

}

extension PaymentMethods: Equatable {
    public static func == (lhs: PaymentMethods, rhs: PaymentMethods) -> Bool {
        guard lhs.regular.count == rhs.regular.count else  { return false }
        guard lhs.stored.count == rhs.stored.count else  { return false }
        for (paymentMethod1, paymentMethod2) in zip(lhs.regular, rhs.regular)  {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        for (paymentMethod1, paymentMethod2) in zip(lhs.stored, rhs.stored)  {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        return true
    }
}
