//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class StringExtensionsTests: XCTestCase {
    
    func testTruncateString() {
        XCTAssertEqual("".truncate(to: 2), "")
        XCTAssertEqual("a".truncate(to: 2), "a")
        XCTAssertEqual("a".truncate(to: 0), "")
        XCTAssertEqual("ab".truncate(to: 2), "ab")
        XCTAssertEqual("abcde".truncate(to: 2), "ab")
    }
    
    func testStringComponentsWithLength() {
        XCTAssertEqual("".components(withLength: 0), [])
        XCTAssertEqual("".components(withLength: 3), [])
        XCTAssertEqual("a".components(withLength: 3), ["a"])
        XCTAssertEqual("abcabc".components(withLength: 3), ["abc", "abc"])
        XCTAssertEqual("abcabca".components(withLength: 3), ["abc", "abc", "a"])
    }
    
    func testStringComponentsWithLengths() {
        XCTAssertEqual("".components(withLengths: [2, 1]), [])
        XCTAssertEqual("ab".components(withLengths: [2, 1]), ["ab"])
        XCTAssertEqual("abc".components(withLengths: [2, 1]), ["ab", "c"])
        XCTAssertEqual("abcde".components(withLengths: [2, 1]), ["ab", "c"])
        XCTAssertEqual("abcde".components(withLengths: [1, 1, 3]), ["a", "b", "cde"])
    }
    
    func testStringSubscriptWithPostion() {
        XCTAssertEqual(""[1], "")
        XCTAssertEqual("abc"[4], "")
        XCTAssertEqual("abc"[-1], "")
        XCTAssertEqual("abc"[0], "a")
        XCTAssertEqual("abc"[1], "b")
        XCTAssertEqual("abc"[2], "c")
    }
    
    func testStringSubscriptWithOpenRange() {
        XCTAssertEqual("abc"[0..<2], "ab")
        XCTAssertEqual("abc"[1..<2], "b")
    }
    
    func testStringSubscriptWithClosedRange() {
        XCTAssertEqual("abc"[0...1], "ab")
        XCTAssertEqual("abc"[0...2], "abc")
        XCTAssertEqual("abc"[1...2], "bc")
    }
    
}
