//
//  SimpleSchedulerTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/11/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import AdyenNetworking
import XCTest

class SimpleSchedulerTests: XCTestCase {

    func testScheduling() {
        var executionCounter = 0
        let closureToSchedule = {
            executionCounter += 1
        }

        let sut = SimpleScheduler(maximumCount: 100)

        for counter in 0...99 {
            XCTAssertFalse(sut.schedule(counter, closure: closureToSchedule))
        }

        XCTAssertTrue(sut.schedule(100, closure: closureToSchedule))

        XCTAssertEqual(executionCounter, 100)
    }

}
