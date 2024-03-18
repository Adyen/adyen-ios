//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

final class AnalyticsEventHandlerTests: XCTestCase {
    
    var apiClient: APIClientMock!
    var sut: AnalyticsEventHandler!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiClient = APIClientMock()
        sut = AnalyticsEventHandler(apiClient: apiClient)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let result: Result<Response, Error> = .success(AnalyticsResponse())
        apiClient.mockedResults = [result]
        
        sut = nil
    }

    func testNoRequestWhenNoAttemptId() {
        XCTAssertNil(sut.requestWithAllEvents())
    }
    
    func testNoRequestWhenCEmptyEvents() {
        sut.update(checkoutAttemptId: "test_id")
        XCTAssertNil(sut.requestWithAllEvents())
    }
    
    func testNoRequestWhenNoAttemptIdButFullEvents() {
        let info = AnalyticsEventInfo(component: "card", type: .focus)
        for _ in 0...10 {
            // adding same event for testing does not matter
            sut.add(info: info)
        }
        XCTAssertNil(sut.requestWithAllEvents())
    }
    
    func testRequestShouldExistWhenAttemptIdAndFullEvents() {
        sut.update(checkoutAttemptId: "test_id")
        let info = AnalyticsEventInfo(component: "card", type: .focus)
        for _ in 0...10 {
            // adding same event for testing does not matter
            sut.add(info: info)
        }
        XCTAssertNotNil(sut.requestWithAllEvents())
    }
    
    func testAddingInfoShouldNotTriggerSend() throws {
        sut.update(checkoutAttemptId: "test_id")
        
        let analyticsResponse = AnalyticsResponse()
        let result: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [result]
        
        let expectation = expectation(description: "should not be called")
        expectation.isInverted = true
        
        let info = AnalyticsEventInfo(component: "card", type: .rendered)
        sut.add(info: info)
        
        apiClient.onExecute = { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testAddingLogShouldTriggerSend() throws {
        sut.update(checkoutAttemptId: "test_id")
        
        let analyticsResponse = AnalyticsResponse()
        let result: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [result]
        
        let log = AnalyticsEventLog(component: "card", type: .submit, subType: .qrCode)
        sut.add(log: log)
        
        wait(until: apiClient, at: \.mockedResults.isEmpty, is: true)
    }
    
    func testAddingErrorShouldTriggerSend() throws {
        sut.update(checkoutAttemptId: "test_id")
        
        let analyticsResponse = AnalyticsResponse()
        let result: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [result]
        
        let error = AnalyticsEventError(component: "card", type: .generic)
        sut.add(error: error)
        
        wait(until: apiClient, at: \.mockedResults.isEmpty, is: true)
    }

}
