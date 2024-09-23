//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class ApplePayDetailsTest: XCTestCase {
    
    func testSerialization() throws {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
        let sut = ApplePayDetails(
            paymentMethod: paymentMethod,
            token: "test_token",
            network: "test_network",
            billingContact: nil,
            shippingContact: nil,
            shippingMethod: nil
        )
        
        let data = try AdyenCoder.encode(sut.encodable) as Data
        
        let resultJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]
        
        let expectedJson = [
            "applePayToken": "test_token",
            "type": "applepay"
        ]
        XCTAssertEqual(expectedJson["applePayToken"], resultJson?["applePayToken"] as? String)
        XCTAssertEqual(expectedJson["type"], resultJson?["type"] as? String)
    }
    
}
