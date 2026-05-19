//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class URLExtensionsTests: XCTestCase {
    
    func testQueryParametersWithNoParameters() throws {
        let url = try XCTUnwrap(URL(string: "url://"))
        let parameters = url.adyen.queryParameters
        
        XCTAssertEqual(parameters.isEmpty, true)
    }
    
    func testQueryParametersWithMultipleParameters() throws {
        let url = try XCTUnwrap(URL(string: "url://?a=aParameter&b=2&c=c"))
        let parameters = url.adyen.queryParameters
        
        XCTAssertEqual(parameters.count, 3)
        XCTAssertEqual(parameters["a"], "aParameter")
        XCTAssertEqual(parameters["b"], "2")
        XCTAssertEqual(parameters["c"], "c")
    }
}
