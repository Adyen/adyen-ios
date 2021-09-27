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
        
        let triesCount = 15
        
        let delays = (0..<triesCount).map { _ in Int.random(in: 100...1500) }
        
        delays.enumerated().forEach { iterator in
            sut.throttle {
                let timeSinceLastExecution = -lastExecution.timeIntervalSinceNow
                XCTAssertGreaterThanOrEqual(timeSinceLastExecution, 1)
                if iterator.offset > 0 {
                    XCTAssertLessThan(timeSinceLastExecution, 2)
                }
                
                lastExecution = Date()
                
                if iterator.offset == triesCount - 1 {
                    xctExpectation.fulfill()
                }
            }
            wait(for: .milliseconds(iterator.element))
        }
        
        waitForExpectations(timeout: 100, handler: nil)
    }

}
