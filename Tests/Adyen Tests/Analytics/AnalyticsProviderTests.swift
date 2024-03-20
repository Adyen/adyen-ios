//
//  AnalyticsProviderTests.swift
//  Adyen
//
//  Created by Naufal Aros on 4/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

class AnalyticsProviderTests: XCTestCase {

    var eventDataSource = AnalyticsEventDataSource()
    
    func testAnalyticsProviderIsInitializedWithCorrectDefaultConfigurationValues() throws {
        // Given
        let analyticsConfiguration = AnalyticsConfiguration()
        let sut = AnalyticsProvider(
            apiClient: APIClientMock(),
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        // Then
        XCTAssertTrue(sut.configuration.isEnabled)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldTriggerRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, 
                                    configuration: analyticsConfiguration,
                                    eventDataSource: eventDataSource)

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotTriggerCheckoutAttemptIdRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        // When
        sut.sendInitialAnalytics(with: .components(type: .affirm), additionalFields: nil)
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }

    func testFetchCheckoutAttemptIdWhenRequestSucceedShouldCallCompletionWithNonNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        // Then
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledGivenFailureShouldCallCompletionWithNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])
        let checkoutAttemptIdResult: Result<Response, Error> = .failure(error)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        // Then
        XCTAssertNil(sut.checkoutAttemptId, "The checkoutAttemptId is not nil.")
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldSetCheckoutAttemptIdProperty() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        
        // Then
        wait(until: sut, at: \.checkoutAttemptId, is: expectedCheckoutAttemptId)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotSetCheckoutAttemptIdProperty() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .affirm), additionalFields: nil)
        // Then
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }
    
    func testInitialRequest() throws {
        // Given
        
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptId)),
        ]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertNil(initialAnalyticsdRequest.amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, adyenSdkVersion)
                XCTAssertEqual(initialAnalyticsdRequest.platform, "ios")
                analyticsExpectation.fulfill()
            }
        }
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration(),
            eventDataSource: eventDataSource
        )
        
        // When
        
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        wait(for: [analyticsExpectation], timeout: 10)
    }
    
    func testShouldNotSendEventsWhenNoAttemptId() {
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [analyticsResult]
        
        let expectation = expectation(description: "should not be called")
        expectation.isInverted = true
        
        apiClient.onExecute = { _ in
            expectation.fulfill()
        }

        sut.sendEventsIfNeeded()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testShouldNotSendEventWhenAttemptIdButNoEvents() {
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        let expectation = expectation(description: "should not be called")
        expectation.isInverted = true
        
        apiClient.onExecute = { request in
            if request is AnalyticsRequest {
                expectation.fulfill()
            }
        }
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
        sut.sendEventsIfNeeded()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testEventShouldSendWhenAttemptIdAndEventsExist() {
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
        let infoEvent = AnalyticsEventInfo(component: "card", type: .rendered)
        sut.add(info: infoEvent)
        
        let shouldSendExpectation = expectation(description: "send event is called")
        apiClient.onExecute = { request in
            if let analyticsRequest = request as? AnalyticsRequest {
                XCTAssertEqual(analyticsRequest.infos.first?.id, infoEvent.id)
                shouldSendExpectation.fulfill()
            }
        }
        
        sut.sendEventsIfNeeded()
        wait(for: [shouldSendExpectation], timeout: 1)
    }
    
    func testDeinitShouldAttemptToSendEvents() {
        let apiClient = APIClientMock()
        var sut: AnalyticsProvider? = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        sut?.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
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
    
    func testAddingInfoShouldNotTriggerSend() {
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
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
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
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
        let sut = AnalyticsProvider(apiClient: apiClient,
                                    configuration: AnalyticsConfiguration(),
                                    eventDataSource: eventDataSource)

        let initialAnalyticsResponse = InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(initialAnalyticsResponse)
        
        let analyticsResponse = AnalyticsResponse()
        let analyticsResult: Result<Response, Error> = .success(analyticsResponse)
        
        apiClient.mockedResults = [checkoutAttemptIdResult, analyticsResult]
        
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        wait(for: .milliseconds(100))
        
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
    
    func testAdditionalFields() throws {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let analyticsExpectation = expectation(description: "Initial request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(InitialAnalyticsResponse(checkoutAttemptId: checkoutAttemptId))
        ]
        apiClient.onExecute = { request in
            if let initialAnalyticsdRequest = request as? InitialAnalyticsRequest {
                XCTAssertEqual(initialAnalyticsdRequest.amount, amount)
                XCTAssertEqual(initialAnalyticsdRequest.version, "version")
                XCTAssertEqual(initialAnalyticsdRequest.platform, "react-native")
                analyticsExpectation.fulfill()
            }
        }
        
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.context = .init(version: "version", platform: .reactNative)
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration,
            eventDataSource: eventDataSource
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount, sessionId: nil)
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [analyticsExpectation], timeout: 10)
    }
    
    func testInitialRequestEncoding() throws {
        
        let analyticsData = AnalyticsData(flavor: .components(type: .achDirectDebit),
                                          additionalFields: AdditionalAnalyticsFields(amount: .init(value: 1, currencyCode: "EUR"), sessionId: "test_session_id"),
                                          context: AnalyticsContext(version: "version", platform: .flutter))
        
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
}
