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
                              billingAddress: AddressInfo(city: "city",
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

        let addressDictionary = dictionary["billingAddress"] as! [String: String]
        XCTAssertEqual(addressDictionary["city"], "city")
        XCTAssertEqual(addressDictionary["country"], "country")
        XCTAssertEqual(addressDictionary["houseNumberOrName"], "numer apartment")
        XCTAssertEqual(addressDictionary["postalCode"], "postal")
        XCTAssertEqual(addressDictionary["stateOrProvince"], "state")
        XCTAssertEqual(addressDictionary["street"], "street")
        XCTAssertEqual(addressDictionary["apartment"], nil)
    }
    
    func testSerializeDeditCard() throws {
        let paymenthMethod = CardPaymentMethodMock(fundingSource: .debit, type: "test_type", name: "test name", brands: ["barnd_1", "barnd_2"])
        let sut = CardDetails(paymentMethod: paymenthMethod,
                              encryptedCard: EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year"),
                              billingAddress: AddressInfo(postalCode: "postal"))
        let data = try JSONEncoder().encode(sut)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        XCTAssertEqual(dictionary["fundingSource"] as! String, "debit")
        XCTAssertEqual(dictionary["type"] as! String, "test_type")
        XCTAssertEqual(dictionary["encryptedExpiryYear"] as! String, "year")
        XCTAssertEqual(dictionary["encryptedCardNumber"] as! String, "number")
        XCTAssertEqual(dictionary["encryptedSecurityCode"] as! String, "code")
        XCTAssertEqual(dictionary["encryptedExpiryMonth"] as! String, "month")

        let addressDictionary = dictionary["billingAddress"] as! [String: String]
        XCTAssertEqual(addressDictionary["city"], "null")
        XCTAssertEqual(addressDictionary["country"], "ZZ")
        XCTAssertEqual(addressDictionary["houseNumberOrName"], "null")
        XCTAssertEqual(addressDictionary["postalCode"], "postal")
        XCTAssertEqual(addressDictionary["stateOrProvince"], "null")
        XCTAssertEqual(addressDictionary["street"], "null")
        XCTAssertEqual(addressDictionary["apartment"], nil)
    }
    
}
