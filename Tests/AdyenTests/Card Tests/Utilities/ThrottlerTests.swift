//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class ThrottlerTests: XCTestCase {

    func test() {
        let sut = Throttler(minimumDelay: 1)
        
        var lastExecution = Date.distantPast
        
        let xctExpectation = expectation(description: "wait for last block execution")
        
        let tries = 100
        
        (0..<tries).forEach { index in
            sut.throttle {
                let timeSinceLastExecution = -lastExecution.timeIntervalSinceNow
                XCTAssertGreaterThanOrEqual(timeSinceLastExecution, 1)
                
                lastExecution = Date()
                
                if index == tries - 1 {
                    xctExpectation.fulfill()
                }
            }
            wait(for: .milliseconds(100))
        }
        
        waitForExpectations(timeout: 100, handler: nil)
    }

}
