//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class ApplePayDetailsTest: XCTestCase {
    
    func testSerialisation() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let sut = ApplePayDetails(paymentMethod: paymentMethod, token: "test_token", network: "test_network")
        
        let expectedJson = [
            "applepay.token": "test_token",
            "applePayCardNetwork": "test_network",
            "type": "test_type"
        ]
        XCTAssertEqual(expectedJson["applepay.token"], sut.dictionaryRepresentation["applepay.token"] as? String)
        XCTAssertEqual(expectedJson["applePayCardNetwork"], sut.dictionaryRepresentation["applePayCardNetwork"] as? String)
        XCTAssertEqual(expectedJson["type"], sut.dictionaryRepresentation["type"] as? String)
    }
    
}
