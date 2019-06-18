//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class RedirectDetailsTests: XCTestCase {
    
    func testPayloadExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&payload=some&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let (codingKey, value) = details.extractResultFromURL()!
        
        XCTAssertEqual(codingKey, RedirectDetails.CodingKeys.payload)
        XCTAssertEqual(value, "some")
    }
    
    func testRedirectResultExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&redirectResult=some&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let (codingKey, value) = details.extractResultFromURL()!
        
        XCTAssertEqual(codingKey, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(value, "some")
    }
    
    func testExtractionFromURLWithInvalidParameters() {
        let url = URL(string: "url://?param1=abc&param2=3")!
        let details = RedirectDetails(returnURL: url)
        
        XCTAssertNil(details.extractResultFromURL())
    }
    
    func testRedirectResultExtractionFromURLWithEncodedParameter() {
        let url = URL(string: "url://?param1=abc&redirectResult=encoded%21%20%40%20%24&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let (codingKey, value) = details.extractResultFromURL()!
        
        XCTAssertEqual(codingKey, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(value, "encoded! @ $")
    }
}
