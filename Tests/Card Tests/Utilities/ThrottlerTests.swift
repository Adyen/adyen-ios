//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class ThrottlerTests: XCTestCase {

    func test() {
        let sut = Throttler(minimumDelay: 0.3)
        
        let lastBlockExpectation = expectation(description: "wait for last block execution")
        
        let triesCount = 25

        var counter = 0
        
        (0..<triesCount).forEach { index in
            sut.throttle {
                
                counter += 1
                
                if index == triesCount - 1 {
                    lastBlockExpectation.fulfill()
                }
            }
            
            wait(for: .milliseconds(5))
        }
        
        wait(for: [lastBlockExpectation], timeout: 100)
        XCTAssertEqual(counter, 1) // Making sure the code was only executed once
    }

}
