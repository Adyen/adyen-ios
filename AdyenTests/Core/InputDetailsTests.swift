//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class InputDetailsTests: XCTestCase {
    
    func testInitWithApplePayType() {
        let info = ["type": "applePayToken", "key": "someKey"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.applePayToken)
        XCTAssertEqual(detail?.key, "someKey")
    }
    
    func testInitWithCvcType() {
        let info = ["type": "cvc", "key": "someKey"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.cvc)
        XCTAssertEqual(detail?.key, "someKey")
    }
    
    func testInitWithTextType() {
        let info = ["type": "text", "key": "sepa.ownerName"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.text)
        XCTAssertEqual(detail?.key, "sepa.ownerName")
    }
    
    func testInitWithCardTokenType() {
        let info = ["type": "cardToken", "key": "encryptedToken"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.cardToken(cvcOptional: false))
        XCTAssertEqual(detail?.key, "encryptedToken")
    }
    
    func testInitWithBooleanType() {
        let info = ["type": "boolean", "key": "someKey"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.boolean)
        XCTAssertEqual(detail?.key, "someKey")
    }
    
    func testInitWithIbanType() {
        let info = ["type": "iban", "key": "someKey"]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.iban)
        XCTAssertEqual(detail?.key, "someKey")
    }
    
    func testInitWithSelectType() {
        let firstItem = ["id": "1", "name": "Test Issuer", "imageUrl": "https://image.url"]
        let secondItem = ["id": "2", "name": "Test Issuer 2", "imageUrl": "https://image2.url"]
        let info = ["type": "select", "key": "someKey", "items": [firstItem, secondItem]] as [String: Any]
        
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.select)
        XCTAssertEqual(detail?.key, "someKey")
        
        XCTAssertEqual(detail?.items?[0].identifier, "1")
        XCTAssertEqual(detail?.items?[0].name, "Test Issuer")
        XCTAssertEqual(detail?.items?[0].imageURL, URL(string: "https://image.url"))
        
        XCTAssertEqual(detail?.items?[1].identifier, "2")
        XCTAssertEqual(detail?.items?[1].name, "Test Issuer 2")
        XCTAssertEqual(detail?.items?[1].imageURL, URL(string: "https://image2.url"))
    }
    
    func testInitWithOptionalValueTrue() {
        let info = ["type": "boolean", "key": "someKey", "optional": "true"] as [String: Any]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.boolean)
        XCTAssertEqual(detail?.key, "someKey")
        XCTAssertEqual(detail?.optional, true)
    }
    
    func testInitWithOptionalValueFalse() {
        let info = ["type": "boolean", "key": "someKey", "optional": "false"] as [String: Any]
        let detail = InputDetail(info: info)
        
        XCTAssertEqual(detail?.type, InputType.boolean)
        XCTAssertEqual(detail?.key, "someKey")
        XCTAssertEqual(detail?.optional, false)
    }
    
    func testSetStringShouldSetValue() {
        let detail = InputDetail(type: .text, key: "")
        
        detail.stringValue = "someValue"
        
        XCTAssertEqual(detail.value, "someValue")
    }
    
    func testSetBoolShouldSetValue() {
        let detail = InputDetail(type: .text, key: "")
        
        detail.boolValue = true
        
        XCTAssertEqual(detail.value, "true")
    }
    
    func testGetBoolValueWithTrue() {
        let detail = InputDetail(type: .text, key: "")
        
        detail.value = "true"
        
        XCTAssertEqual(detail.boolValue, true)
    }
}
