//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class StringExtensionsTests: XCTestCase {
    
    func testStringToBoolConversion() {
        let string: String? = nil
        
        XCTAssertEqual("true".boolValue(), true)
        XCTAssertEqual("false".boolValue(), false)
        XCTAssertEqual("dog".boolValue(), nil)
        XCTAssertEqual(string?.boolValue(), nil)
    }
    
    func testSubscriptWithValidPosition() {
        let string = "abcdef"
        
        XCTAssertEqual(string[0], "a")
        XCTAssertEqual(string[2], "c")
        XCTAssertEqual(string[5], "f")
    }
    
    func testSubscriptWithInvalidPosition() {
        let string = "abcdef"
        
        XCTAssertEqual(string[-1], "")
        XCTAssertEqual(string[6], "")
    }
    
    func testSubscriptWithValidRange() {
        let string = "abcdef"
        
        XCTAssertEqual(string[0..<2], "ab")
        XCTAssertEqual(string[2..<4], "cd")
        XCTAssertEqual(string[3..<6], "def")
    }
    
    func testSubscriptWithValidClosedRange() {
        let string = "abcdef"
        
        XCTAssertEqual(string[0...1], "ab")
        XCTAssertEqual(string[2...3], "cd")
        XCTAssertEqual(string[3...5], "def")
    }
    
}
