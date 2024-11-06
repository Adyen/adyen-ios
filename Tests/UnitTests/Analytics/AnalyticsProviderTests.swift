//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

class AnalyticsProviderTests: XCTestCase {
    
    func testAnalyticsProviderIsInitializedWithCorrectDefaultConfigurationValues() throws {
        // Given
        let analyticsConfiguration = AnalyticsConfiguration()
        let sut = AnalyticsProvider(
            apiClient: APIClientMock(),
            context: AnalyticsContext(),
            eventAnalyticsProvider: nil
        )

        // Then
        XCTAssertNil(sut.checkoutAttemptId)
        XCTAssertNil(sut.eventAnalyticsProvider)
    }

    func testFetchCheckoutAttemptIdShouldTriggerRequest() throws {
        // Given
        let apiClient = APIClientMock()
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }

    func testFetchCheckoutAttemptIdWhenRequestSucceedShouldCallCompletionWithNonNilValue() throws {
        // Given
        let apiClient = APIClientMock()
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        // Then
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }

    func testFetchCheckoutAttemptIdGivenFailureShouldCallCompletionWithNilValue() throws {
        // Given
        let apiClient = APIClientMock()

        let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])
        let checkoutAttemptIdResult: Result<Response, Error> = .failure(error)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        // Then
        XCTAssertNil(sut.checkoutAttemptId, "The checkoutAttemptId is not nil.")
    }

    func testFetchCheckoutAttemptIdShouldSetCheckoutAttemptIdProperty() throws {
        // Given
        let apiClient = APIClientMock()
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        let sut = createSUT(apiClient: apiClient)
        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        
        // Then
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }
    
    func testInitialRequest() throws {
        // Given
        
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptId))]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertNil(initialAnalyticsdRequest.amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, adyenSdkVersion)
                XCTAssertEqual(initialAnalyticsdRequest.platform, "iOS")
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
            context: AnalyticsContext(),
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

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = EmptyResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
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
    
    func testAdditionalFields() throws {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptId))]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialAnalyticsdRequest.amount, amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, "version")
                XCTAssertEqual(initialAnalyticsdRequest.platform, "react-native")
                analyticsExpectation.fulfill()
            }
        }
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            context: .init(version: "version", platform: .reactNative),
            eventAnalyticsProvider: nil
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: nil)
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [analyticsExpectation], timeout: 10)
    }
    
    func testInitialRequestEncoding() throws {
        
        let analyticsData = AnalyticsData(
            flavor: .components(type: .achDirectDebit),
            additionalFields: AdditionalAnalyticsFields(amount: .init(value: 1, currencyCode: "EUR"), sessionId: "test_session_id"),
            context: AnalyticsContext(version: "version", platform: .flutter)
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
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            context: AnalyticsContext(),
            eventAnalyticsProvider: nil
        )
        
        return sut
    }
}
