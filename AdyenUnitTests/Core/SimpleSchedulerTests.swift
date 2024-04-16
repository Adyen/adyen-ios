//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import AdyenNetworking
import XCTest

class SimpleSchedulerTests: XCTestCase {

    func testScheduling() {
        var executionCounter = 0
        let closureToSchedule = {
            executionCounter += 1
        }

        let sut = SimpleScheduler(maximumCount: 100)

        (0...99).forEach { counter in
            XCTAssertFalse(sut.schedule(counter, closure: closureToSchedule))
        }

        XCTAssertTrue(sut.schedule(100, closure: closureToSchedule))

        XCTAssertEqual(executionCounter, 100)
    }

}
