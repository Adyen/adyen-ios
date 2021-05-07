//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import XCTest

class RedirectListnerTests: XCTestCase {

    func testRedirectListner() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        let sampleUrl = URL(string: "www.google.com")!
        RedirectListener.registerForURL { url in

            XCTAssertEqual(url, sampleUrl)
            dummyExpectation.fulfill()
        }

        XCTAssertTrue(RedirectListener.applicationDidOpen(from: sampleUrl))
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testUnregisteredRedirectListner() {
        let sampleUrl = URL(string: "www.google.com")!
        XCTAssertFalse(RedirectListener.applicationDidOpen(from: sampleUrl))
    }

}
