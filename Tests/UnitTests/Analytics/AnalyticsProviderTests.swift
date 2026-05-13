//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

class AnalyticsProviderTests: XCTestCase {
    
    func testAnalyticsProviderIsInitializedWithCorrectDefaultConfigurationValues() {
        // Given
        let eventApiClient = APIClientMock()
        let eventAnalyticsProvider = EventAnalyticsProvider(
            apiClient: eventApiClient,
            eventDataSource: AnalyticsEventDataSource(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId
        )

        let sut = AnalyticsProvider(
            apiClient: APIClientMock(),
            configuration: AnalyticsConfiguration(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: eventAnalyticsProvider
        )

        // Then
        XCTAssertEqual(sut.checkoutAttemptId, AnalyticsProviderMock.testCheckoutAttemptId)
    }

    func testSendInitialAnalyticsShouldTriggerRequest() {
        // Given
        let apiClient = APIClientMock()

        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [analyticsResult]

        let analyticsExpectation = expectation(description: "Initial analytics request is triggered")
        apiClient.onExecute = { request in
            if request is InitialAnalyticsRequest {
                analyticsExpectation.fulfill()
            }
        }

        let sut = createSUT(apiClient: apiClient, eventAnalyticsProvider: AnyEventAnalyticsProviderMock())
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)

        wait(for: [analyticsExpectation], timeout: 0.1)
    }

    func testCheckoutAttemptIdIsIncludedInInitialRequest() {
        // Given
        let apiClient = APIClientMock()

        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [analyticsResult]

        let analyticsExpectation = expectation(description: "Initial request includes checkoutAttemptId")
        apiClient.onExecute = { request in
            if let initialRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialRequest.checkoutAttemptId, AnalyticsProviderMock.testCheckoutAttemptId)
                analyticsExpectation.fulfill()
            }
        }

        let sut = createSUT(apiClient: apiClient, eventAnalyticsProvider: AnyEventAnalyticsProviderMock())
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)

        // Then
        wait(for: [analyticsExpectation], timeout: 0.1)
    }

    func testInitialRequest() {
        // Given
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertNil(initialAnalyticsdRequest.amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, adyenSdkVersion)
                XCTAssertEqual(initialAnalyticsdRequest.platform, "ios")
                XCTAssertEqual(initialAnalyticsdRequest.level, "all")
                analyticsExpectation.fulfill()
            }
        }
        
        let analyticsProvider = createSUT(apiClient: apiClient, eventAnalyticsProvider: AnyEventAnalyticsProviderMock())

        // When
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: [analyticsExpectation], timeout: 0.1)
    }
    
    func testFollowUpEventsWhenEnabled() {
        let eventApiClient = APIClientMock()
        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        eventApiClient.mockedResults = [analyticsResult]
        
        let eventAnalyticsProvider = EventAnalyticsProvider(
            apiClient: eventApiClient,
            eventDataSource: AnalyticsEventDataSource(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId
        )
        let sut = createSUT(apiClient: APIClientMock(), eventAnalyticsProvider: eventAnalyticsProvider)
        
        let networkRequestExpectation = expectation(description: "send event should be called")
        eventApiClient.onExecute = { request in
            networkRequestExpectation.fulfill()
        }
        
        let logEvent = AnalyticsEventLog(component: "threeds", type: .submit)
        sut.add(log: logEvent)
        
        wait(for: [networkRequestExpectation], timeout: 0.1)
    }

    func testAdditionalFields() {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialAnalyticsdRequest.amount, amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, adyenSdkVersion)
                XCTAssertEqual(initialAnalyticsdRequest.platform, "ios")
                analyticsExpectation.fulfill()
            }
        }
        
        let configuration = AnalyticsConfiguration()
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: configuration,
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: AnyEventAnalyticsProviderMock()
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: nil)
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [analyticsExpectation], timeout: 1)
    }
    
    func testInitialRequestEncoding() throws {
        
        let configuration = AnalyticsConfiguration()

        let analyticsData = AnalyticsData(
            flavor: .components(type: .achDirectDebit),
            additionalFields: AdditionalAnalyticsFields(amount: .init(value: 1, currencyCode: "EUR"), sessionId: "test_session_id"),
            configuration: configuration,
            checkoutAttemptId: nil
        )
        
        let request = InitialAnalyticsRequest(data: analyticsData)
        
        let encodedRequest = try JSONEncoder().encode(request)
        let decodedRequest = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedRequest) as? [String: Any])
        
        let expectedDecodedRequest = [
            "locale": "en_US",
            "paymentMethods": analyticsData.paymentMethods,
            "platform": "ios",
            "component": "ach",
            "flavor": "components",
            "channel": "ios",
            "systemVersion": analyticsData.systemVersion,
            "screenWidth": analyticsData.screenWidth,
            "referrer": analyticsData.referrer,
            "deviceBrand": analyticsData.deviceBrand,
            "deviceModel": analyticsData.deviceModel,
            "level": analyticsData.level.rawValue,
            "amount": [
                "currency": "EUR",
                "value": 1
            ] as [String: Any],
            "sessionId": "test_session_id",
            "version": adyenSdkVersion
        ] as [String: Any]
        
        XCTAssertEqual(
            NSDictionary(dictionary: decodedRequest),
            NSDictionary(dictionary: expectedDecodedRequest)
        )
    }

    // MARK: - Private
    
    private func createSUT(
        apiClient: APIClientMock,
        eventAnalyticsProvider: AnyEventAnalyticsProvider?
    ) -> AnalyticsProvider {
        AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration(),
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            eventAnalyticsProvider: eventAnalyticsProvider
        )
    }
}
