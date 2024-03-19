//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

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
        XCTAssertEqual(sut.infos.count, 0)
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        XCTAssertEqual(sut.infos.count, 1)
        XCTAssertEqual(sut.wrappedEvents()?.infos.count, 1)
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        XCTAssertEqual(sut.infos.count, 2)
        XCTAssertEqual(sut.wrappedEvents()?.infos.count, 2)
    }
    
    func testAddingLog() {
        XCTAssertEqual(sut.logs.count, 0)
        
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        XCTAssertEqual(sut.logs.count, 1)
        XCTAssertEqual(sut.wrappedEvents()?.logs.count, 1)
        
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        XCTAssertEqual(sut.logs.count, 2)
        XCTAssertEqual(sut.wrappedEvents()?.logs.count, 2)
    }
    
    func testAddingError() {
        XCTAssertEqual(sut.errors.count, 0)
        
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        XCTAssertEqual(sut.errors.count, 1)
        XCTAssertEqual(sut.wrappedEvents()?.errors.count, 1)
        
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        XCTAssertEqual(sut.errors.count, 2)
        XCTAssertEqual(sut.wrappedEvents()?.errors.count, 2)
    }
    
    func testRemoveEvents() {
        XCTAssertNil(sut.wrappedEvents())
        
        sut.add(info: AnalyticsEventInfo(component: "test", type: .rendered))
        sut.add(log: AnalyticsEventLog(component: "card", type: .action, subType: .redirect))
        sut.add(error: AnalyticsEventError(component: "card", type: .internal))
        
        XCTAssertNotNil(sut.wrappedEvents())
        
        sut.removeAllEvents()
        
        XCTAssertNil(sut.wrappedEvents())
    }

}
