//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_documentation(visibility: internal) @testable import AdyenActions
import XCTest

class RedirectListenerTests: XCTestCase {

    func testRedirectListenerWithoutThrowing() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        let sampleUrl = URL(string: "www.google.com")!
        RedirectListener.registerForURL { url in

            XCTAssertEqual(url, sampleUrl)
            dummyExpectation.fulfill()
        }

        XCTAssertTrue(try RedirectListener.applicationDidOpen(from: sampleUrl))
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRedirectListenerWithThrowing() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        let sampleUrl = URL(string: "www.google.com")!
        RedirectListener.registerForURL { url in

            XCTAssertEqual(url, sampleUrl)
            dummyExpectation.fulfill()
            throw Dummy.error
        }

        XCTAssertThrowsError(try RedirectListener.applicationDidOpen(from: sampleUrl))
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testUnregisteredRedirectListener() {
        let sampleUrl = URL(string: "www.google.com")!
        XCTAssertFalse(try RedirectListener.applicationDidOpen(from: sampleUrl))
    }

}
