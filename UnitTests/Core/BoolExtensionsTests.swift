//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class BoolExtensionsTests: XCTestCase {
    
    func testBoolToStringConversion() {
        let bool: Bool? = nil
        
        XCTAssertEqual(true.stringValue(), "true")
        XCTAssertEqual(false.stringValue(), "false")
        XCTAssertEqual(bool?.stringValue(), nil)
    }
}
