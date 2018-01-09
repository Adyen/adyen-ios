//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class InputSelectItemTests: XCTestCase {
    
    func testInitWithDictionary() {
        let item = ["id": "1", "name": "Test Issuer", "imageUrl": "https://image.url"]
        
        let inputItem = InputSelectItem(info: item)
        
        XCTAssertEqual(inputItem?.identifier, "1")
        XCTAssertEqual(inputItem?.name, "Test Issuer")
        XCTAssertEqual(inputItem?.imageURL?.absoluteString, "https://image.url")
    }
}
