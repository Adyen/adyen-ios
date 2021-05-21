//
//  InstantPaymentComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 5/20/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen
@testable import AdyenCard

class InstantPaymentComponentTests: XCTestCase {

    var sut: InstantPaymentComponent!

    var paymentMethod: GiftCardPaymentMethod!

    var delegate: PaymentComponentDelegateMock!

    override func setUp() {
        super.setUp()
        paymentMethod = GiftCardPaymentMethod(type: "type", name: "name", brand: "brand")
    }

    func testCustomPaymentData() throws {
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let amount = Amount(value: 34, currencyCode: "EUR")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: amount, order: nil)
        delegate = PaymentComponentDelegateMock()
        sut = InstantPaymentComponent(paymentMethod: paymentMethod, paymentData: paymentData)
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            let details = data.paymentMethod as! GiftCardDetails
            XCTAssertEqual(details.brand, "brand")
            XCTAssertEqual(details.encryptedCardNumber, "card")
            XCTAssertEqual(details.encryptedSecurityCode, "cvc")
            delegateExpectation.fulfill()
        }

        sut.initiatePayment()

        waitForExpectations(timeout: 2, handler: nil)
    }

}
