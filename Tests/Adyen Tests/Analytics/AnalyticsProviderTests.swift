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
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

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
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let fetchCheckoutAttemptIdExpection = expectation(description: "checkoutAttemptId completion")

        // When
        sut.fetchCheckoutAttemptId { receivedCheckoutAttemptId in
            XCTAssertNil(receivedCheckoutAttemptId)
            fetchCheckoutAttemptIdExpection.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchCheckoutAttemptIdWhenRequestSucceedShouldCallCompletionWithNonNilValue() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

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
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

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
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedCheckoutAttemptId = checkoutAttemptIdMockValue

        let checkoutAttemptIdResponse = CheckoutAttemptIdResponse(identifier: expectedCheckoutAttemptId)
        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult]

        // When
        sut.fetchCheckoutAttemptId { _ in

            // Then
            XCTAssertEqual(expectedCheckoutAttemptId, self.sut.checkoutAttemptId)
        }
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
        sut.fetchCheckoutAttemptId { _ in

            // Then
            XCTAssertNil(self.sut.checkoutAttemptId)
        }
    }

    // MARK: - Private

    private var checkoutAttemptIdMockValue: String {
        "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993"
    }
}
