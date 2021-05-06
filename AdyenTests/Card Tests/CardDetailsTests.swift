//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardDetailsTests: XCTestCase {
    
    func testSerializeCreditCard() throws {
        let paymenthMethod = CardPaymentMethodMock(fundingSource: .credit, type: "test_type", name: "test name", brands: ["barnd_1", "barnd_2"])
        let sut = CardDetails(paymentMethod: paymenthMethod, encryptedCard: CardEncryptor.EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year"))
        let data = try JSONEncoder().encode(sut)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
        
        XCTAssertEqual(dictionary["fundingSource"], "credit")
        XCTAssertEqual(dictionary["type"], "test_type")
        XCTAssertEqual(dictionary["encryptedExpiryYear"], "year")
        XCTAssertEqual(dictionary["encryptedCardNumber"], "number")
        XCTAssertEqual(dictionary["encryptedSecurityCode"], "code")
        XCTAssertEqual(dictionary["encryptedExpiryMonth"], "month")
    }
    
    func testSerializeDeditCard() throws {
        let paymenthMethod = CardPaymentMethodMock(fundingSource: .debit, type: "test_type", name: "test name", brands: ["barnd_1", "barnd_2"])
        let sut = CardDetails(paymentMethod: paymenthMethod, encryptedCard: CardEncryptor.EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year"))
        let data = try JSONEncoder().encode(sut)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
        
        XCTAssertEqual(dictionary["fundingSource"], "debit")
        XCTAssertEqual(dictionary["type"], "test_type")
        XCTAssertEqual(dictionary["encryptedExpiryYear"], "year")
        XCTAssertEqual(dictionary["encryptedCardNumber"], "number")
        XCTAssertEqual(dictionary["encryptedSecurityCode"], "code")
        XCTAssertEqual(dictionary["encryptedExpiryMonth"], "month")
    }

    func testBillingAddress() throws {
        let data = try JSONEncoder().encode(AddressInfo(postalCode: "12345"))
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]

        XCTAssertEqual(dictionary["postalCode"], "12345")
        XCTAssertEqual(dictionary["country"], "ZZ")
        XCTAssertEqual(dictionary["street"], "null")
        XCTAssertEqual(dictionary["houseNumberOrName"], "null")
        XCTAssertEqual(dictionary["city"], "null")
        XCTAssertEqual(dictionary["stateOrProvince"], "null")
    }
    
}
