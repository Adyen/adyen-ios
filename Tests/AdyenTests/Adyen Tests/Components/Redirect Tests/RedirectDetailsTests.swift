//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import XCTest

class RedirectDetailsTests: XCTestCase {
    
    func testPayloadExtractionFromURL() throws {
        let url = URL(string: "url://?param1=abc&payload=some&param2=3")!
        let details = try RedirectDetails(returnURL: url)
        XCTAssertEqual(details.payload, "some")
        XCTAssertNil(details.queryString)
        XCTAssertNil(details.merchantData)
        XCTAssertNil(details.paymentResponse)
        XCTAssertNil(details.redirectResult)

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testRedirectResultExtractionFromURL() throws {
        let url = URL(string: "url://?param1=abc&redirectResult=some&param2=3")!
        let details = try RedirectDetails(returnURL: url)
        XCTAssertEqual(details.redirectResult, "some")
        XCTAssertNil(details.queryString)
        XCTAssertNil(details.merchantData)
        XCTAssertNil(details.paymentResponse)
        XCTAssertNil(details.payload)

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testPaResAndMDExtractionFromURL() throws {
        let url = URL(string: "url://?param1=abc&PaRes=some&MD=lorem")!
        let details = try RedirectDetails(returnURL: url)
        XCTAssertEqual(details.paymentResponse, "some")
        XCTAssertEqual(details.merchantData, "lorem")
        XCTAssertNil(details.queryString)
        XCTAssertNil(details.redirectResult)
        XCTAssertNil(details.payload)

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }
    
    func testRedirectResultExtractionFromURLWithEncodedParameter() throws {
        let url = URL(string: "url://?param1=abc&redirectResult=encoded%21%20%40%20%24&param2=3")!
        let details = try RedirectDetails(returnURL: url)
        XCTAssertEqual(details.redirectResult, "encoded! @ $")
        XCTAssertNil(details.queryString)
        XCTAssertNil(details.merchantData)
        XCTAssertNil(details.paymentResponse)
        XCTAssertNil(details.payload)

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }

    func testQueryStringExtractionFromURL() throws {
        let url = URL(string: "url://?param1=abc&pp=H7j5+pwnbNk8uKpS/m67rDp/K+AiJbQ==&param2=3")!
        let details = try RedirectDetails(returnURL: url)
        XCTAssertEqual(details.queryString, "param1=abc&pp=H7j5+pwnbNk8uKpS/m67rDp/K+AiJbQ==&param2=3")
        XCTAssertNil(details.redirectResult)
        XCTAssertNil(details.merchantData)
        XCTAssertNil(details.paymentResponse)
        XCTAssertNil(details.payload)

        XCTAssertNotNil(try? JSONEncoder().encode(details))
    }

    func testExtractionFromURLWithoutQuery() throws {
        let url = URL(string: "url://")!
        XCTAssertThrowsError(try RedirectDetails(returnURL: url), "") { error in
            XCTAssertTrue(error is RedirectDetails.Error)
            XCTAssertEqual(error.localizedDescription, "Couldn't find payload, redirectResult or PaRes/md keys in the query parameters.")
        }
    }

    func testEncoding() throws {
        let url = URL(string: "badURL")!
        XCTAssertThrowsError(try RedirectDetails(returnURL: url), "") { error in
            XCTAssertTrue(error is RedirectDetails.Error)
            XCTAssertEqual(error.localizedDescription, "Couldn't find payload, redirectResult or PaRes/md keys in the query parameters.")
        }

    }
}
