//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
@testable import AdyenEncryption
import XCTest

class CardDetailsTests: XCTestCase {
    
    func testSerializeCreditCard() throws {
        let paymenthMethod = CardPaymentMethodMock(fundingSource: .credit, type: "test_type", name: "test name", brands: ["barnd_1", "barnd_2"])
        let sut = CardDetails(paymentMethod: paymenthMethod,
                              encryptedCard: EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year"),
                              holderName: "holder",
                              billingAddress: PostalAddress(city: "city",
                                                          country: "country",
                                                          houseNumberOrName: "numer",
                                                          postalCode: "postal",
                                                          stateOrProvince: "state",
                                                          street: "street",
                                                          apartment: "apartment"))
        let data = try JSONEncoder().encode(sut)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        XCTAssertEqual(dictionary["fundingSource"] as! String, "credit")
        XCTAssertEqual(dictionary["type"] as! String, "test_type")
        XCTAssertEqual(dictionary["encryptedExpiryYear"] as! String, "year")
        XCTAssertEqual(dictionary["encryptedCardNumber"] as! String, "number")
        XCTAssertEqual(dictionary["encryptedSecurityCode"] as! String, "code")
        XCTAssertEqual(dictionary["holderName"] as! String, "holder")

        XCTAssertNil(dictionary["billingAddress"])
    }
    
    func testSerializeDeditCard() throws {
        let paymenthMethod = CardPaymentMethodMock(fundingSource: .debit, type: "test_type", name: "test name", brands: ["barnd_1", "barnd_2"])
        let sut = CardDetails(paymentMethod: paymenthMethod,
                              encryptedCard: EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year"),
                              billingAddress: PostalAddress(postalCode: "postal"))
        let data = try JSONEncoder().encode(sut)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        XCTAssertEqual(dictionary["fundingSource"] as! String, "debit")
        XCTAssertEqual(dictionary["type"] as! String, "test_type")
        XCTAssertEqual(dictionary["encryptedExpiryYear"] as! String, "year")
        XCTAssertEqual(dictionary["encryptedCardNumber"] as! String, "number")
        XCTAssertEqual(dictionary["encryptedSecurityCode"] as! String, "code")
        XCTAssertEqual(dictionary["encryptedExpiryMonth"] as! String, "month")

        XCTAssertNil(dictionary["billingAddress"])
    }

    func testEncodingFullAddress() {
        let data = try! JSONEncoder().encode(PostalAddress(city: "city",
                                                        country: "country",
                                                        houseNumberOrName: "numer",
                                                        postalCode: "postal",
                                                        stateOrProvince: "state",
                                                        street: "street",
                                                        apartment: "apartment"))
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String]

        XCTAssertEqual(dictionary["city"], "city")
        XCTAssertEqual(dictionary["country"], "country")
        XCTAssertEqual(dictionary["houseNumberOrName"], "numer apartment")
        XCTAssertEqual(dictionary["postalCode"], "postal")
        XCTAssertEqual(dictionary["stateOrProvince"], "state")
        XCTAssertEqual(dictionary["street"], "street")
        XCTAssertEqual(dictionary["apartment"], nil)
    }

    func testEncodingPostCode() {
        let data = try! JSONEncoder().encode(PostalAddress(postalCode: "postal"))
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String]

        XCTAssertEqual(dictionary["city"], "null")
        XCTAssertEqual(dictionary["country"], "ZZ")
        XCTAssertEqual(dictionary["houseNumberOrName"], "null")
        XCTAssertEqual(dictionary["postalCode"], "postal")
        XCTAssertEqual(dictionary["stateOrProvince"], "null")
        XCTAssertEqual(dictionary["street"], "null")
        XCTAssertEqual(dictionary["apartment"], nil)
    }
    
}
