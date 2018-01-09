//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class ArrayExtensionsTests: XCTestCase {
    func testGroupByWithString() {
        let array = ["a1", "b1", "a2", "c1", "a3", "c2"]
        let grouped = array.groupBy { $0.first! }
        
        XCTAssertEqual(grouped[0].count, 3)
        XCTAssertEqual(grouped[0][0], "a1")
        XCTAssertEqual(grouped[0][1], "a2")
        XCTAssertEqual(grouped[0][2], "a3")
        
        XCTAssertEqual(grouped[1].count, 1)
        XCTAssertEqual(grouped[1][0], "b1")
        
        XCTAssertEqual(grouped[2].count, 2)
        XCTAssertEqual(grouped[2][0], "c1")
        XCTAssertEqual(grouped[2][1], "c2")
    }
}
