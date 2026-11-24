//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCheckout
@preconcurrency import AdyenNetworking
import XCTest

final class CheckoutLogLevelTests: XCTestCase {

    private var initialSDKLoggingEnabled = false
    private var initialNetworkingLoggingEnabled = false

    override func setUp() {
        super.setUp()
        initialSDKLoggingEnabled = AdyenLogging.isEnabled
        initialNetworkingLoggingEnabled = AdyenNetworking.Logging.isEnabled
        AdyenLogging.isEnabled = false
    }

    override func tearDown() {
        AdyenLogging.isEnabled = initialSDKLoggingEnabled
        AdyenNetworking.Logging.isEnabled = initialNetworkingLoggingEnabled
        super.tearDown()
    }

    func test_setLogLevel_withVerbose_shouldEnableSDKAndNetworkingLogging() {
        Checkout.setLogLevel(.verbose)

        XCTAssertTrue(AdyenLogging.isEnabled)
        XCTAssertTrue(AdyenNetworking.Logging.isEnabled)
    }

    func test_setLogLevel_withOffAfterVerbose_shouldDisableSDKAndNetworkingLogging() {
        Checkout.setLogLevel(.verbose)

        Checkout.setLogLevel(.off)

        XCTAssertFalse(AdyenLogging.isEnabled)
        XCTAssertFalse(AdyenNetworking.Logging.isEnabled)
    }
}
