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
