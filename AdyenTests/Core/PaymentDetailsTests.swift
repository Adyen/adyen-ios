//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentDetailsTests: XCTestCase {
    
    var paymentDetails: PaymentDetails = PaymentDetails(details: [])
    
    override func setUp() {
        super.setUp()
        paymentDetails.list = [
            InputDetail(type: .cardToken, key: "additionalData.card.encrypted.json"),
            InputDetail(type: .applePayToken, key: "additionalData.applepay.token"),
            InputDetail(type: .boolean, key: "storeDetails"),
            InputDetail(type: .select, key: "idealIssuer"),
            InputDetail(type: .text, key: "sepa.ownerName"),
            InputDetail(type: .text, key: "sepa.ibanNumber"),
            InputDetail(type: .cvc, key: "cardDetails.cvc")
        ]
    }
    
    func testApplePayPaymentDetailFill() {
        let testToken = "this is a fake token"
        
        paymentDetails.fillApplePay(token: testToken)
        
        XCTAssertEqual(paymentDetails.list[1].value, testToken)
    }
    
    func testApplePayPaymentDetailFillWithNoApplePayDetail() {
        let details = PaymentDetails(details: [InputDetail(type: .text, key: "test")])
        let testToken = "this is a fake token"
        
        details.fillApplePay(token: testToken)
        
        XCTAssertEqual(details.list[0].value, nil)
    }
    
    func testCardPaymentDetailFillWithStoreTrue() {
        let testToken = "fake card token"
        
        paymentDetails.fillCard(token: testToken, storeDetails: true)
        
        XCTAssertEqual(paymentDetails.list[0].value, testToken)
        XCTAssertEqual(paymentDetails.list[2].value, "true")
    }
    
    func testCardPaymentDetailFillWithStoreFalse() {
        let testToken = "fake card token!"
        
        paymentDetails.fillCard(token: testToken, storeDetails: false)
        
        XCTAssertEqual(paymentDetails.list[0].value, testToken)
        XCTAssertEqual(paymentDetails.list[2].value, "false")
    }
    
    func testCardPaymentDetailFillWithCvcOnly() {
        let cvc = "123"
        
        paymentDetails.fillCard(cvc: cvc)
        
        XCTAssertEqual(paymentDetails.list[6].value, cvc)
    }
    
    func testIdealPaymentDetailFill() {
        let issuerId = "1234"
        
        paymentDetails.fillIdeal(issuerIdentifier: issuerId)
        
        XCTAssertEqual(paymentDetails.list[3].value, issuerId)
    }
    
    func testSepaPaymentDetailFill() {
        let name = "John Doe"
        let iban = "NL JOHN 000 00 000 00"
        
        paymentDetails.fillSepa(name: name, iban: iban)
        
        XCTAssertEqual(paymentDetails.list[4].value, name)
        XCTAssertEqual(paymentDetails.list[5].value, iban)
    }
}
