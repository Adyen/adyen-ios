//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentInitiationTests: XCTestCase {
    
    func testDecodingRedirectState() {
        let dictionary = [
            "type": "redirect",
            "url": "https://adyen.com"
        ]
        
        let paymentInitiation = PaymentInitiation(dictionary: dictionary)!
        XCTAssertEqual(paymentInitiation.state, .redirect(URL(string: "https://adyen.com")!))
    }
    
    func testDecodingCompletedState() {
        let dictionary = [
            "type": "complete",
            "resultCode": "authorised",
            "payload": "payload123"
        ]
        
        let paymentInitiation = PaymentInitiation(dictionary: dictionary)!
        XCTAssertEqual(paymentInitiation.state, .completed(.authorised, "payload123"))
    }
    
    func testDecodingErrorState() {
        let dictionary = [
            "type": "error",
            "errorMessage": "Hello world"
        ]
        
        let paymentInitiation = PaymentInitiation(dictionary: dictionary)!
        XCTAssertEqual(paymentInitiation.state, .error(.serverError("Hello world")))
    }
    
}
