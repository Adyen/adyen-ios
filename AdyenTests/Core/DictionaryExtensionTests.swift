//
// Copyright (c) 2018 Adyen B.V.
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
}
