//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class ThrottlerTests: XCTestCase {

    func test() {
        let sut = Throttler(minimumDelay: 0.5)

        var counter = 0

        let expectation = XCTestExpectation(description: "Waiting for callback")
        for index in 0...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(index * 100)) {
                sut.throttle { counter += 1 }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(counter, 1)
    }

}
