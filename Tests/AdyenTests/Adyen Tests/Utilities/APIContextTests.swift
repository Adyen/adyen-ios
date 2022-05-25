//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class APIContextTests: XCTestCase {

    func testCreateValidClientKey() throws {
        let environment = Environment(baseURL: URL(string: "https://adyen.com")!)
        let clientKey = "ttest_keykeykeykey"
        let sut = try APIContext(environment: environment, clientKey: clientKey)

        XCTAssertEqual(sut.clientKey, clientKey)
        XCTAssertEqual(sut.environment.baseURL, environment.baseURL)
    }
    
    func testCreateInvalidClientKey() {
        let environment = Environment(baseURL: URL(string: "https://adyen.com")!)
        let clientKey = "WrongClientKey"

        XCTAssertThrowsError(try APIContext(environment: environment, clientKey: clientKey),
                             "Testing Invalid client key") { error in
            XCTAssertTrue(error is ClientKeyError)
            XCTAssertEqual(error as! ClientKeyError, ClientKeyError.invalidClientKey)
        }
    }
    
    func testQueryParameters() {
        let sut = Dummy.apiContext.queryParameters
        
        XCTAssertEqual(sut.count, 1)
        
        let clientKeyParameter = sut.first
        XCTAssertNotNil(clientKeyParameter)
        XCTAssertEqual(clientKeyParameter!.name, "clientKey")
        XCTAssertEqual(clientKeyParameter!.value, Dummy.apiContext.clientKey)
    }
    
    func testHeaders() {
        let sut = Dummy.apiContext.headers
        
        XCTAssertEqual(sut.count, 1)
        
        let contentTypeHeader = sut.first
        XCTAssertNotNil(contentTypeHeader)
        XCTAssertEqual(contentTypeHeader!.key, "Content-Type")
        XCTAssertEqual(contentTypeHeader!.value, "application/json")
    }
    
}
