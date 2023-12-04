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
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNotNil(receivedCheckoutAttemptId, "The checkoutAttemptId is nil.")
            XCTAssertEqual(expectedCheckoutAttemptId, receivedCheckoutAttemptId, "The received checkoutAttemptId is not the expected one.")
            fetchCheckoutAttemptIdExpection.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotTriggerCheckoutAttemptIdRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        let apiClient = APIClientMock()
        let sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in
            XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
            fetchCheckoutAttemptIdExpection.fulfill()
        }

        waitForExpectations(timeout: 1)
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
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNotNil(receivedCheckoutAttemptId, "The checkoutAttemptId is nil.")
            XCTAssertEqual(expectedCheckoutAttemptId, receivedCheckoutAttemptId, "The received checkoutAttemptId is not the expected one.")
            fetchCheckoutAttemptIdExpection.fulfill()
        }

        waitForExpectations(timeout: 1)
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

        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in

            // Then
            XCTAssertNil(receivedCheckoutAttemptId, "The checkoutAttemptId is not nil.")
            fetchCheckoutAttemptIdExpection.fulfill()
        }

        waitForExpectations(timeout: 1)
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

        // When
        sut.fetchCheckoutAttemptId { _ in

            // Then
            XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId)
        }
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
        sut.fetchCheckoutAttemptId { _ in

            // Then
            XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
        }
    }
    
    func testTelemetryRequest() throws {
        // Given
        
        let checkoutAttemptId = self.checkoutAttemptIdMockValue
        
        let telemetryExpectation = expectation(description: "Telemetry request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(CheckoutAttemptIdResponse(identifier: checkoutAttemptId)),
            .success(TelemetryResponse())
        ]
        apiClient.onExecute = { request in
            if let telemetryRequest = request as? TelemetryRequest {
                XCTAssertNil(telemetryRequest.amount)
                XCTAssertEqual(telemetryRequest.checkoutAttemptId, checkoutAttemptId)
                XCTAssertEqual(telemetryRequest.version, adyenSdkVersion)
                XCTAssertEqual(telemetryRequest.platform, "ios")
                telemetryExpectation.fulfill()
            }
        }
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration()
        )
        
        // When
        
        analyticsProvider.sendTelemetryEvent(flavor: .components(type: .achDirectDebit))
        
        wait(for: [telemetryExpectation], timeout: 1)
    }
    
    func testAdditionalFields() throws {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = self.checkoutAttemptIdMockValue
        
        let telemetryExpectation = expectation(description: "Telemetry request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(CheckoutAttemptIdResponse(identifier: checkoutAttemptId)),
            .success(TelemetryResponse())
        ]
        apiClient.onExecute = { request in
            if let telemetryRequest = request as? TelemetryRequest {
                XCTAssertEqual(telemetryRequest.amount, amount)
                XCTAssertEqual(telemetryRequest.checkoutAttemptId, checkoutAttemptId)
                XCTAssertEqual(telemetryRequest.version, "version")
                XCTAssertEqual(telemetryRequest.platform, "platform")
                telemetryExpectation.fulfill()
            }
        }
        
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.context = .init(version: "version", platform: "platform")
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: analyticsConfiguration
        )
        
        analyticsProvider.additionalFields = {
            .init(amount: amount)
        }
        
        // When
        
        analyticsProvider.sendTelemetryEvent(flavor: .components(type: .achDirectDebit))
        
        wait(for: [telemetryExpectation], timeout: 1)
    }
    
    func testTelemetryRequestEncoding() throws {
        
        let telemetryData = TelemetryData(
            flavor: .dropInComponent,
            amount: .init(value: 1, currencyCode: "EUR"),
            context: .init(
                version: "version",
                platform: "platform"
            )
        )
        
        let request = TelemetryRequest(
            data: telemetryData,
            checkoutAttemptId: checkoutAttemptIdMockValue
        )
        
        let encodedRequest = try JSONEncoder().encode(request)
        let decodedRequest = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedRequest) as? [String: Any])
        
        let expectedDecodedRequest = [
            "locale": "en_US",
            "paymentMethods": telemetryData.paymentMethods,
            "platform": "platform",
            "component": "",
            "flavor": "dropInComponent",
            "channel": "iOS",
            "systemVersion": telemetryData.systemVersion,
            "screenWidth": telemetryData.screenWidth,
            "referrer": telemetryData.referrer,
            "deviceBrand": telemetryData.deviceBrand,
            "amount": [
                "currency": "EUR",
                "value": 1
            ] as [String: Any],
            "checkoutAttemptId": checkoutAttemptIdMockValue,
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
