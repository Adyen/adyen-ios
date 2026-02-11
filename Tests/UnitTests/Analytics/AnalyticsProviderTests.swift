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
        let sut = AnalyticsProvider(
            apiClient: APIClientMock(),
            configuration: AnalyticsConfiguration(),
            eventAnalyticsProvider: nil
        )

        // Then
        XCTAssertNil(sut.checkoutAttemptId)
        XCTAssertNil(sut.eventAnalyticsProvider)
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

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)

        wait(for: [analyticsExpectation], timeout: 10)
    }

    func testCheckoutAttemptIdIsIncludedInInitialRequest() {
        // Given
        let apiClient = APIClientMock()
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [analyticsResult]

        let analyticsExpectation = expectation(description: "Initial request includes checkoutAttemptId")
        apiClient.onExecute = { request in
            if let initialRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialRequest.checkoutAttemptId, expectedCheckoutAttemptId)
                analyticsExpectation.fulfill()
            }
        }

        let sut = createSUT(apiClient: apiClient)
        sut.checkoutAttemptId = expectedCheckoutAttemptId
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)

        // Then
        wait(for: [analyticsExpectation], timeout: 10)
    }

    func testCheckoutAttemptIdIsNilWhenNotSetExternally() {
        // Given
        let apiClient = APIClientMock()

        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        apiClient.mockedResults = [analyticsResult]

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        // Then
        XCTAssertNil(sut.checkoutAttemptId, "The checkoutAttemptId should be nil when not set externally.")
    }

    func testInitialRequest() {
        // Given
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertNil(initialAnalyticsdRequest.amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, adyenSdkVersion)
                XCTAssertEqual(initialAnalyticsdRequest.platform, "iOS")
                XCTAssertEqual(initialAnalyticsdRequest.level, "all")
                analyticsExpectation.fulfill()
            }
        }
        
        let analyticsProvider = createSUT(apiClient: apiClient)
        
        // When
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: [analyticsExpectation], timeout: 10)
    }
    
    func testFollowUpEventsWhenEnabled() {
        let eventApiClient = APIClientMock()
        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        eventApiClient.mockedResults = [analyticsResult]
        
        let eventAnalyticsProvider = EventAnalyticsProvider(
            apiClient: eventApiClient,
            context: AnalyticsContext(),
            eventDataSource: AnalyticsEventDataSource()
        )
        let sut = AnalyticsProvider(
            apiClient: APIClientMock(),
            configuration: AnalyticsConfiguration(),
            eventAnalyticsProvider: eventAnalyticsProvider
        )
        
        sut.checkoutAttemptId = checkoutAttemptIdMockValue
        
        let networkRequestExpectation = expectation(description: "send event should not be called")
        eventApiClient.onExecute = { request in
            networkRequestExpectation.fulfill()
        }
        
        let logEvent = AnalyticsEventLog(component: "threeds", type: .submit)
        sut.add(log: logEvent)
        
        wait(for: [networkRequestExpectation], timeout: 1)
    }
    
    func eventsShouldNotBeSentWhenDisabled() throws {
        let apiClient = APIClientMock()

        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [analyticsResult]
        
        let sut = createSUT(apiClient: apiClient)
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
        let infoEvent = AnalyticsEventInfo(component: "card", type: .rendered)
        let logEvent = AnalyticsEventLog(component: "threeds", type: .submit)
        let errorEvent = AnalyticsEventError(component: "card", type: .implementation)
        
        let networkRequestExpectation = expectation(description: "send event should not be called")
        networkRequestExpectation.isInverted = true
        apiClient.onExecute = { request in
            networkRequestExpectation.fulfill()
        }
        
        sut.add(info: infoEvent)
        sut.add(log: logEvent)
        sut.add(error: errorEvent)
        
        wait(for: [networkRequestExpectation], timeout: 1)
    }
    
    func testAdditionalFields() {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialAnalyticsdRequest.amount, amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, "version")
                XCTAssertEqual(initialAnalyticsdRequest.platform, "react-native")
                analyticsExpectation.fulfill()
            }
        }
        
        var configuration = AnalyticsConfiguration()
        configuration.context = AnalyticsContext(version: "version", platform: .reactNative)
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: configuration,
            eventAnalyticsProvider: nil
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: nil)
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [analyticsExpectation], timeout: 10)
    }
    
    func testInitialRequestEncoding() throws {
        
        var configuration = AnalyticsConfiguration()
        configuration.context = AnalyticsContext(version: "version", platform: .flutter)
        
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
            "platform": "flutter",
            "component": "ach",
            "flavor": "components",
            "channel": "iOS",
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
            "version": "version"
        ] as [String: Any]
        
        XCTAssertEqual(
            NSDictionary(dictionary: decodedRequest),
            NSDictionary(dictionary: expectedDecodedRequest)
        )
    }

    // MARK: - Private

    private var checkoutAttemptIdMockValue: String {
        "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993"
    }
    
    private func createSUT(apiClient: APIClientMock) -> AnalyticsProvider {
        AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration(),
            eventAnalyticsProvider: nil
        )
    }
}
