//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LazyOptionalTests: XCTestCase {
    
    func testExpectedBehaviour() {
        var counter = 0
        var object: NSObject?
        
        let sut = LazyOptional(initialize: { () -> NSObject in
            object = NSObject()
            
            counter += 1
            
            return object!
        }())
        
        // Make sure its only initialized when its first called.
        XCTAssertEqual(counter, 0)
        
        // Make sure its only initialized once.
        XCTAssertTrue(sut.wrappedValue === object)
        XCTAssertTrue(sut.wrappedValue === object)
        XCTAssertEqual(counter, 1)
        
        sut.reset()
        
        // Make sure its initialized again after reseting.
        XCTAssertTrue(sut.wrappedValue === object)
        XCTAssertEqual(counter, 2)
        
    }
    
}
