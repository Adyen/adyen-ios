//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

final class AnalyticsEventDataSourceTests: XCTestCase {
    
    var sut: AnalyticsEventDataSource!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AnalyticsEventDataSource()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testAddingInfo() {
        XCTAssertNil(sut.allEvents())
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        XCTAssertEqual(sut.allEvents()?.infos.count, 1)
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        XCTAssertEqual(sut.allEvents()?.infos.count, 2)
    }
    
    func testAddingLog() {
        XCTAssertNil(sut.allEvents())
        
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        XCTAssertEqual(sut.allEvents()?.logs.count, 1)
        
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        XCTAssertEqual(sut.allEvents()?.logs.count, 2)
    }
    
    func testAddingError() {
        XCTAssertNil(sut.allEvents())
        
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        XCTAssertEqual(sut.allEvents()?.errors.count, 1)
        
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        XCTAssertEqual(sut.allEvents()?.errors.count, 2)
    }
    
    func testRemoveEvents() {
        XCTAssertNil(sut.allEvents())
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        
        XCTAssertNotNil(sut.allEvents())
        
        sut.removeAllEvents()
        
        XCTAssertNil(sut.allEvents())
    }

}
