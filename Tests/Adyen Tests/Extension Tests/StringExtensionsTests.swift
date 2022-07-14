//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class StringExtensionsTests: XCTestCase {
    
    func testTruncateString() {
        XCTAssertEqual("".adyen.truncate(to: 2), "")
        XCTAssertEqual("a".adyen.truncate(to: 2), "a")
        XCTAssertEqual("a".adyen.truncate(to: 0), "")
        XCTAssertEqual("ab".adyen.truncate(to: 2), "ab")
        XCTAssertEqual("abcde".adyen.truncate(to: 2), "ab")
    }
    
    func testStringComponentsWithLength() {
        XCTAssertEqual("".adyen.components(withLength: 0), [])
        XCTAssertEqual("".adyen.components(withLength: 3), [])
        XCTAssertEqual("a".adyen.components(withLength: 3), ["a"])
        XCTAssertEqual("abcabc".adyen.components(withLength: 3), ["abc", "abc"])
        XCTAssertEqual("abcabca".adyen.components(withLength: 3), ["abc", "abc", "a"])
    }
    
    func testStringComponentsWithLengths() {
        XCTAssertEqual("".adyen.components(withLengths: [2, 1]), [])
        XCTAssertEqual("ab".adyen.components(withLengths: [2, 1]), ["ab"])
        XCTAssertEqual("abc".adyen.components(withLengths: [2, 1]), ["ab", "c"])
        XCTAssertEqual("abcde".adyen.components(withLengths: [2, 1]), ["ab", "c"])
        XCTAssertEqual("abcde".adyen.components(withLengths: [1, 1, 3]), ["a", "b", "cde"])
    }
    
    func testStringSubscriptWithPostion() {
        XCTAssertEqual("".adyen[1], "")
        XCTAssertEqual("abc".adyen[4], "")
        XCTAssertEqual("abc".adyen[-1], "")
        XCTAssertEqual("abc".adyen[0], "a")
        XCTAssertEqual("abc".adyen[1], "b")
        XCTAssertEqual("abc".adyen[2], "c")
    }
    
    func testStringSubscriptWithOpenRange() {
        XCTAssertEqual("abc".adyen[0..<2], "ab")
        XCTAssertEqual("abc".adyen[1..<2], "b")
    }
    
    func testStringSubscriptWithClosedRange() {
        XCTAssertEqual("abc".adyen[0...1], "ab")
        XCTAssertEqual("abc".adyen[0...2], "abc")
        XCTAssertEqual("abc".adyen[1...2], "bc")
    }
    
    func testClosedRanges() {
        let testString = "012345"
        XCTAssertEqual(testString.adyen[0...2], "012")
        XCTAssertEqual(testString.adyen[0...5], "012345")
        XCTAssertEqual(testString.adyen[3...6], "345")
        XCTAssertEqual(testString.adyen[2...3], "23")
        XCTAssertEqual(testString.adyen[2...2], "2")
        XCTAssertEqual(testString.adyen[1...4], "1234")
        XCTAssertEqual(testString.adyen[6...8], "")
        XCTAssertEqual(testString.adyen[-6...8], "012345")
        
        let empty = ""
        XCTAssertEqual(empty.adyen[0...2], "")
        XCTAssertEqual(empty.adyen[0...5], "")
        XCTAssertEqual(empty.adyen[3...6], "")
        XCTAssertEqual(empty.adyen[2...3], "")
        XCTAssertEqual(empty.adyen[2...2], "")
        XCTAssertEqual(empty.adyen[1...4], "")
        XCTAssertEqual(empty.adyen[6...8], "")
        XCTAssertEqual(empty.adyen[-6...8], "")
    }
    
    func testOpenRanges() {
        let testString = "012345"
        XCTAssertEqual(testString.adyen[0..<2], "01")
        XCTAssertEqual(testString.adyen[0..<5], "01234")
        XCTAssertEqual(testString.adyen[3..<6], "345")
        XCTAssertEqual(testString.adyen[2..<3], "2")
        XCTAssertEqual(testString.adyen[2..<2], "")
        XCTAssertEqual(testString.adyen[1..<4], "123")
        XCTAssertEqual(testString.adyen[6..<8], "")
        XCTAssertEqual(testString.adyen[-6..<8], "012345")
        
        let empty = ""
        XCTAssertEqual(empty.adyen[0..<2], "")
        XCTAssertEqual(empty.adyen[0..<5], "")
        XCTAssertEqual(empty.adyen[3..<6], "")
        XCTAssertEqual(empty.adyen[2..<3], "")
        XCTAssertEqual(empty.adyen[2..<2], "")
        XCTAssertEqual(empty.adyen[1..<4], "")
        XCTAssertEqual(empty.adyen[6..<8], "")
        XCTAssertEqual(empty.adyen[-6..<8], "")
    }
    
}
