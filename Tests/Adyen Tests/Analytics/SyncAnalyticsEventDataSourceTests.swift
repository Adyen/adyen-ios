//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

final class SyncAnalyticsEventDataSourceTests: XCTestCase {
    
    var eventDataSource: AnalyticsEventDataSource!
    var sut: SyncAnalyticsEventDataSource!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        eventDataSource = AnalyticsEventDataSource()
        sut = SyncAnalyticsEventDataSource(dataSource: eventDataSource)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        eventDataSource = nil
    }

    func testAddingInfo() {
        
    }

}
