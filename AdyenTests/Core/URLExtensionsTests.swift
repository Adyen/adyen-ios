//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class URLExtensionsTests: XCTestCase {
    
    func testQueryParametersToDictionary() {
        let url = URL(string: "https://test.com/index?title=someTitle&active=true&noValue=&lastParam=1")
        
        let queryParameters = url?.queryParameters()
        
        XCTAssertEqual(queryParameters?["title"], "someTitle")
        XCTAssertEqual(queryParameters?["active"], "true")
        XCTAssertEqual(queryParameters?["noValue"], "")
        XCTAssertEqual(queryParameters?["lastParam"], "1")
    }
}
