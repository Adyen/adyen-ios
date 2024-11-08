//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

final class EventAnalyticsProviderTests: XCTestCase {
    
    var eventDataSource = AnalyticsEventDataSource()

    func testShouldNotSendEventsWhenNoAttemptId() {
        let apiClient = APIClientMock()
        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [analyticsResult]
        
        let expectation = expectation(description: "should not be called")
        expectation.isInverted = true
        
        apiClient.onExecute = { _ in
            expectation.fulfill()
        }
        
        let sut = createSUT(apiClient: apiClient)

        sut.sendEventsIfNeeded()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testShouldNotSendEventsWhenNoEvents() {
        let apiClient = APIClientMock()
        let sut = createSUT(apiClient: apiClient)
        sut.checkoutAttemptId = checkoutAttemptIdMockValue
        
        let expectation = expectation(description: "should not be called")
        expectation.isInverted = true
        
        apiClient.onExecute = { request in
            if request is AnalyticsRequest {
                expectation.fulfill()
            }
        }
        
        sut.sendEventsIfNeeded()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testEventShouldSendWhenAttemptIdAndEventsExist() {
        let apiClient = APIClientMock()
        let sut = createSUTWithSuccessMock(apiClient: apiClient)
        
        let infoEvent = AnalyticsEventInfo(component: "card", type: .rendered)
        sut.add(info: infoEvent)
        
        let shouldSendExpectation = expectation(description: "send event is called")
        let expectedId = infoEvent.id
        apiClient.onExecute = { request in
            if let analyticsRequest = request as? AnalyticsRequest,
               let capturedId = analyticsRequest.infos.first?.id {
                XCTAssertEqual(capturedId, expectedId, "Expected event ID does not match the sent event id")
                shouldSendExpectation.fulfill()
            }
        }
        
        sut.sendEventsIfNeeded()
        wait(for: [shouldSendExpectation], timeout: 1)
    }
    
    func testDeinitShouldAttemptToSendEvents() {
        let apiClient = APIClientMock()
        var sut: EventAnalyticsProvider? = createSUTWithSuccessMock(apiClient: apiClient)
        
        for _ in 0...2 {
            sut?.add(info: AnalyticsEventInfo(component: "card", type: .rendered))
        }
        
        let shouldSendExpectation = expectation(description: "send event is called")
        apiClient.onExecute = { request in
            if let analyticsRequest = request as? AnalyticsRequest {
                XCTAssertEqual(analyticsRequest.infos.count, 3)
                shouldSendExpectation.fulfill()
            }
        }
        
        sut = nil
        
        wait(for: [shouldSendExpectation], timeout: 1)
    }
    
    func testAddingInfoEventShouldNotTriggerSend() {
        let apiClient = APIClientMock()
        let sut = createSUTWithSuccessMock(apiClient: apiClient)
        
        let networkRequestExpectation = expectation(description: "send event should not be called")
        networkRequestExpectation.isInverted = true
        apiClient.onExecute = { request in
            networkRequestExpectation.fulfill()
        }
        
        let infoEvent = AnalyticsEventInfo(component: "card", type: .rendered)
        sut.add(info: infoEvent)
        
        wait(for: [networkRequestExpectation], timeout: 1)
    }
    
    func testAddingLogEventShouldTriggerSend() {
        let apiClient = APIClientMock()
        let sut = createSUTWithSuccessMock(apiClient: apiClient)
        
        let logEvent = AnalyticsEventLog(component: "card", type: .submit, subType: .sdk)
        
        let expectation = expectation(description: "send event is called")
        apiClient.onExecute = { request in
            if let analyticsRequest = request as? AnalyticsRequest {
                XCTAssertEqual(analyticsRequest.logs.first?.id, logEvent.id)
                expectation.fulfill()
            }
        }
        
        sut.add(log: logEvent)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testAddingErrorEventShouldTriggerSend() {
        let apiClient = APIClientMock()
        let sut = createSUTWithSuccessMock(apiClient: apiClient)
        
        let errorEvent = AnalyticsEventError(component: "card", type: .implementation)
        
        let expectation = expectation(description: "send event is called")
        apiClient.onExecute = { request in
            if let analyticsRequest = request as? AnalyticsRequest {
                XCTAssertEqual(analyticsRequest.errors.first?.id, errorEvent.id)
                expectation.fulfill()
            }
        }
        
        sut.add(error: errorEvent)
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Private

    private var checkoutAttemptIdMockValue: String {
        "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993"
    }
    
    private func createSUT(apiClient: APIClientMock) -> EventAnalyticsProvider {
        
        let sut = EventAnalyticsProvider(
            apiClient: apiClient,
            context: AnalyticsContext(),
            eventDataSource: eventDataSource
        )
        
        return sut
    }
    
    private func createSUTWithSuccessMock(apiClient: APIClientMock) -> EventAnalyticsProvider {
        let sut = createSUT(apiClient: apiClient)
        
        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [analyticsResult]
        
        sut.checkoutAttemptId = checkoutAttemptIdMockValue
        
        return sut
    }
}
