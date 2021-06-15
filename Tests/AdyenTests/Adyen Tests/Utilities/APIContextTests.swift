//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class APIContextTests: XCTestCase {
    
    func testInjection() {
        let environment = Environment(baseURL: URL(string: "https://adyen.com")!)
        let clientKey = "ttest_keykeykeykey"
        
        let sut = APIContext(environment: environment, clientKey: clientKey)
        
        XCTAssertEqual(sut.clientKey, clientKey)
        XCTAssertEqual(sut.environment.baseURL, environment.baseURL)
    }
    
    func testInvalidClientKey() {
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "ClientKey is invalid.")
            expectation.fulfill()
            
            AdyenAssertion.listener = nil
        }
        
        _ = APIContext(environment: Dummy.context.environment, clientKey: "invalid_client_key")
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testQueryParameters() {
        let sut = Dummy.context.queryParameters
        
        XCTAssertEqual(sut.count, 1)
        
        let clientKeyParameter = sut.first
        XCTAssertNotNil(clientKeyParameter)
        XCTAssertEqual(clientKeyParameter!.name, "clientKey")
        XCTAssertEqual(clientKeyParameter!.value, Dummy.context.clientKey)
    }
    
    func testHeaders() {
        let sut = Dummy.context.headers
        
        XCTAssertEqual(sut.count, 1)
        
        let contentTypeHeader = sut.first
        XCTAssertNotNil(contentTypeHeader)
        XCTAssertEqual(contentTypeHeader!.key, "Content-Type")
        XCTAssertEqual(contentTypeHeader!.value, "application/json")
    }
    
}
