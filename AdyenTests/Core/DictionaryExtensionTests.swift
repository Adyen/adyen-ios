//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class DictionaryExtensionsTests: XCTestCase {
    
    func testDictionaryUnion() {
        var dictionary = ["first": "1", "second": "2"]
        let secondDictionary = ["third": "3", "fourth": "4"]
        
        dictionary.formUnion(secondDictionary)
        
        XCTAssertEqual(dictionary["first"], "1")
        XCTAssertEqual(dictionary["second"], "2")
        XCTAssertEqual(dictionary["third"], "3")
        XCTAssertEqual(dictionary["fourth"], "4")
    }

    func testConvertingDictionaryNSAttributedStringKeyNSObjectToStringAny() {
        let dictionary: [NSAttributedStringKey: NSObject] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)
        ]

        let expectation: [String: Any] = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 18)]

        XCTAssertEqual(dictionary.stringAny.description, expectation.description)
    }

}
