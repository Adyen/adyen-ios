//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class ApplePayDetailsTest: XCTestCase {
    
    func testSerialisation() throws {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let sut = ApplePayDetails(paymentMethod: paymentMethod,
                                  token: "test_token",
                                  network: "test_network",
                                  billingContact: nil,
                                  shippingContact: nil)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(sut.encodable)
        
        let resultJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]
        
        let expectedJson = [
            "applepay.token": "test_token",
            "applePayCardNetwork": "test_network",
            "type": "test_type"
        ]
        XCTAssertEqual(expectedJson["applepay.token"], resultJson?["applepay.token"] as? String)
        XCTAssertEqual(expectedJson["applePayCardNetwork"], resultJson?["applePayCardNetwork"] as? String)
        XCTAssertEqual(expectedJson["type"], resultJson?["type"] as? String)
    }
    
}
