//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentStatusTests: XCTestCase {
    
    func testInitialization() {
        XCTAssertEqual(PaymentStatus(rawValue: "received"), .received)
        XCTAssertEqual(PaymentStatus(rawValue: "authorised"), .authorised)
        XCTAssertEqual(PaymentStatus(rawValue: "error"), .error)
        XCTAssertEqual(PaymentStatus(rawValue: "refused"), .refused)
        XCTAssertEqual(PaymentStatus(rawValue: "cancelled"), .cancelled)
    }
    
}
