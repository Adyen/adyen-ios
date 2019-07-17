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
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.payload)
        XCTAssertEqual(keyValues[0].1, "some")
    }
    
    func testRedirectResultExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&redirectResult=some&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(keyValues[0].1, "some")
    }
    
    func testPaResAndMDExtractionFromURL() {
        let url = URL(string: "url://?param1=abc&PaRes=some&MD=lorem")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 2)
        // PaRes
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.paymentResponse)
        XCTAssertEqual(keyValues[0].1, "some")
        // MD
        XCTAssertEqual(keyValues[1].0, RedirectDetails.CodingKeys.md)
        XCTAssertEqual(keyValues[1].1, "lorem")
    }
    
    func testPaResExtractionWithoutMDFromURL() {
        let url = URL(string: "url://?param1=abc&PaRes=some")!
        let details = RedirectDetails(returnURL: url)
        
        XCTAssertNil(details.extractKeyValuesFromURL())
    }
    
    func testMDExtractionWithoutPaResFromURL() {
        let url = URL(string: "url://?param1=abc&MD=some")!
        let details = RedirectDetails(returnURL: url)
        
        XCTAssertNil(details.extractKeyValuesFromURL())
    }
    
    func testExtractionFromURLWithInvalidParameters() {
        let url = URL(string: "url://?param1=abc&param2=3")!
        let details = RedirectDetails(returnURL: url)
        
        XCTAssertNil(details.extractKeyValuesFromURL())
    }
    
    func testRedirectResultExtractionFromURLWithEncodedParameter() {
        let url = URL(string: "url://?param1=abc&redirectResult=encoded%21%20%40%20%24&param2=3")!
        let details = RedirectDetails(returnURL: url)
        let keyValues = details.extractKeyValuesFromURL()!
        
        XCTAssertEqual(keyValues.count, 1)
        XCTAssertEqual(keyValues[0].0, RedirectDetails.CodingKeys.redirectResult)
        XCTAssertEqual(keyValues[0].1, "encoded! @ $")
    }
}
