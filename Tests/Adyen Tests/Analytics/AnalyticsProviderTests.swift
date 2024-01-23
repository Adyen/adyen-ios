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

    func testAnalyticsProviderIsInitializedWithCorrectDefaultConfigurationValues() throws {
        // Given
        let analyticsConfiguration = AnalyticsConfiguration()
        let sut = AnalyticsProvider(apiClient: APIClientMock(), configuration: analyticsConfiguration)

        // Then
        XCTAssertTrue(sut.configuration.isEnabled)
        XCTAssertTrue(sut.configuration.isTelemetryEnabled)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldTriggerRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        fetchCheckoutAttemptIdExpection.fulfill()
        
        wait(for: .milliseconds(200))
        
        XCTAssertNotNil(sut.checkoutAttemptId, "The checkoutAttemptId is nil.")
        XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId, "The received checkoutAttemptId is not the expected one.")
        
        waitForExpectations(timeout: 10)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotTriggerCheckoutAttemptIdRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.sendInitialAnalytics(with: .components(type: .affirm), additionalFields: nil)
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }

    func testFetchCheckoutAttemptIdWhenRequestSucceedShouldCallCompletionWithNonNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        fetchCheckoutAttemptIdExpection.fulfill()
        
        wait(for: .milliseconds(200))
        
        // Then
        XCTAssertNotNil(sut.checkoutAttemptId, "The checkoutAttemptId is nil.")
        XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId, "The received checkoutAttemptId is not the expected one.")
        
        waitForExpectations(timeout: 10)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledGivenFailureShouldCallCompletionWithNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])
        let checkoutAttemptIdResult: Result<Response, Error> = .failure(error)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .dropInComponent, additionalFields: nil)
        // Then
        XCTAssertNil(sut.checkoutAttemptId, "The checkoutAttemptId is not nil.")
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldSetCheckoutAttemptIdProperty() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.sendInitialAnalytics(with: .components(type: .atome), additionalFields: nil)
        fetchCheckoutAttemptIdExpection.fulfill()
        
        wait(for: .milliseconds(200))
        
        // Then
        XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId)
        
        waitForExpectations(timeout: 1)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotSetCheckoutAttemptIdProperty() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.sendInitialAnalytics(with: .components(type: .affirm), additionalFields: nil)
        // Then
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }
    
    func testTelemetryRequest() throws {
        // Given
        
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let telemetryExpectation = expectation(description: "Telemetry request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(CheckoutAttemptIdResponse(identifier: checkoutAttemptId)),
        ]
        apiClient.onExecute = { request in
            if let checkoutAttemptIdRequest = request as? CheckoutAttemptIdRequest {
                XCTAssertNil(checkoutAttemptIdRequest.amount)
                XCTAssertEqual(checkoutAttemptIdRequest.version, adyenSdkVersion)
                XCTAssertEqual(checkoutAttemptIdRequest.platform, "ios")
                telemetryExpectation.fulfill()
            }
        }
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration()
        )
        
        // When
        
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: nil)
        
        wait(for: [telemetryExpectation], timeout: 10)
    }
    
    func testAdditionalFields() throws {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = checkoutAttemptIdMockValue
        
        let telemetryExpectation = expectation(description: "Telemetry request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(CheckoutAttemptIdResponse(identifier: checkoutAttemptId))
        ]
        apiClient.onExecute = { request in
            if let checkoutAttemptIdRequest = request as? CheckoutAttemptIdRequest {
                XCTAssertEqual(checkoutAttemptIdRequest.amount, amount)
                XCTAssertEqual(checkoutAttemptIdRequest.version, "version")
                XCTAssertEqual(checkoutAttemptIdRequest.platform, "react-native")
                telemetryExpectation.fulfill()
            }
        }
        
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.context = .init(version: "version", platform: .reactNative)
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount)
        analyticsProvider.sendInitialAnalytics(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [telemetryExpectation], timeout: 10)
    }
    
    func testTelemetryRequestEncoding() throws {
        
        let telemetryData = TelemetryData(flavor: .dropInComponent,
                                          additionalFields: AdditionalAnalyticsFields(amount: .init(value: 1, currencyCode: "EUR")),
                                          context: TelemetryContext(version: "version", platform: .flutter))
        
        let request = CheckoutAttemptIdRequest(data: telemetryData)
        
        let encodedRequest = try JSONEncoder().encode(request)
        let decodedRequest = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedRequest) as? [String: Any])
        
        let expectedDecodedRequest = [
            "locale": "en_US",
            "paymentMethods": telemetryData.paymentMethods,
            "platform": "flutter",
            "component": "",
            "flavor": "dropInComponent",
            "channel": "iOS",
            "systemVersion": telemetryData.systemVersion,
            "screenWidth": telemetryData.screenWidth,
            "referrer": telemetryData.referrer,
            "deviceBrand": telemetryData.deviceBrand,
            "deviceModel": telemetryData.deviceModel,
            "amount": [
                "currency": "EUR",
                "value": 1
            ] as [String: Any],
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
