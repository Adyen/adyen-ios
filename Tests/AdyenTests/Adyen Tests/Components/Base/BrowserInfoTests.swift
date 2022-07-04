//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class BrowserInfoTests: XCTestCase {
    
    func testBrowserInfoInitialize() {
        let browserInfoExpectation = expectation(description: "Expect the BrowserInfo.initialize() to return a valid instance")
        BrowserInfo.initialize { info in
            XCTAssertNotNil(info?.userAgent)
            browserInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPaymentComponentDataBrowserInfo() {
        let browserInfoExpectation = expectation(description: "Expect the BrowserInfo.initialize() to return a valid instance")
        let data = PaymentComponentData(paymentMethodDetails: InstantPaymentDetails(type: .payPal), amount: nil, order: nil)
        data.dataByAddingBrowserInfo {
            XCTAssertNotNil($0.browserInfo?.userAgent)
            browserInfoExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInitializePerformance() {
        self.measure {
            BrowserInfo.initialize { _ in }
        }
    }
    
}
