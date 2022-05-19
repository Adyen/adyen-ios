//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class TimeIntervalExtensionsTests: XCTestCase {
    
    func testTimeLeftLessThan60Min() {
        let sut: TimeInterval = 60 * 29 + 1
        
        XCTAssertEqual(sut.adyen.timeLeftString(), "29:01")
    }
    
    func testTimeLeftLessMore60Min() {
        let sut: TimeInterval = 60 * 61 + 1
        
        XCTAssertEqual(sut.adyen.timeLeftString(), "01:01:01")
    }
    
}
