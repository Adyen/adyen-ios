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

    var apiClient: APIClientMock!
    var sut: AnalyticsProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = APIClientMock()
        sut = AnalyticsProvider(apiClient: apiClient, configuration: .init())
    }

    override func tearDownWithError() throws {
        apiClient = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testAnalyticsProviderIsInitializedWithCorrectDefaultConfigurationValues() throws {
        // Given
        let analyticsConfiguration = AnalyticsConfiguration()
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // Then
        XCTAssertTrue(sut.configuration.isEnabled)
        XCTAssertTrue(sut.configuration.isTelemetryEnabled)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldTriggerRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")
        
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.fetchCheckoutAttemptId(with: .components(type: .achDirectDebit), additionalFields: nil)
        fetchCheckoutAttemptIdExpection.fulfill()
        
        wait(for: .milliseconds(200))
        
        XCTAssertNotNil(sut.checkoutAttemptId, "The checkoutAttemptId is nil.")
        XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId, "The received checkoutAttemptId is not the expected one.")
        
        waitForExpectations(timeout: 1)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsDisabledShouldNotTriggerCheckoutAttemptIdRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.fetchCheckoutAttemptId(with: .components(type: .affirm), additionalFields: nil)
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }

    func testFetchCheckoutAttemptIdWhenRequestSucceedShouldCallCompletionWithNonNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")
        
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.fetchCheckoutAttemptId(with: .components(type: .achDirectDebit), additionalFields: nil)
        fetchCheckoutAttemptIdExpection.fulfill()
        
        wait(for: .milliseconds(200))
        
        // Then
        XCTAssertNotNil(sut.checkoutAttemptId, "The checkoutAttemptId is nil.")
        XCTAssertEqual(expectedCheckoutAttemptId, sut.checkoutAttemptId, "The received checkoutAttemptId is not the expected one.")
        
        waitForExpectations(timeout: 1)
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledGivenFailureShouldCallCompletionWithNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])
        let checkoutAttemptIdResult: Result<Response, Error> = .failure(error)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.fetchCheckoutAttemptId(with: .dropInComponent, additionalFields: nil)
        // Then
        XCTAssertNil(sut.checkoutAttemptId, "The checkoutAttemptId is not nil.")
    }

    func testFetchCheckoutAttemptIdWhenAnalyticsIsEnabledShouldSetCheckoutAttemptIdProperty() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]
        
        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")
        
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        // When
        sut.fetchCheckoutAttemptId(with: .components(type: .atome), additionalFields: nil)
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
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: checkoutAttemptIdMockValue)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.fetchCheckoutAttemptId(with: .components(type: .affirm), additionalFields: nil)
        // Then
        XCTAssertEqual(sut.checkoutAttemptId, "do-not-track")
    }
    
    func testAdditionalFields() throws {
     
        // Given
        
        let amount = Amount(value: 1, currencyCode: "EUR")
        let checkoutAttemptId = self.checkoutAttemptIdMockValue
        
        let telemetryExpectation = expectation(description: "Telemetry request is triggered")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(CheckoutAttemptIdResponse(identifier: checkoutAttemptId))
        ]
        apiClient.onExecute = { request in
            if let checkoutAttemptIdRequest = request as? CheckoutAttemptIdRequest {
                XCTAssertEqual(checkoutAttemptIdRequest.amount, amount)
                telemetryExpectation.fulfill()
            }
        }
        
        let analyticsProvider = AnalyticsProvider(
            apiClient: apiClient,
            configuration: AnalyticsConfiguration()
        )
        
        // When
        let additionalFields = AdditionalAnalyticsFields(amount: amount)
        analyticsProvider.fetchCheckoutAttemptId(with: .components(type: .achDirectDebit), additionalFields: additionalFields)
        
        wait(for: [telemetryExpectation], timeout: 1)
    }

    // MARK: - Private

    private var checkoutAttemptIdMockValue: String {
        "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993"
    }
}
