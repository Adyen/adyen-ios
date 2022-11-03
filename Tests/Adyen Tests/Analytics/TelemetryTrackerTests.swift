//
//  TelemetryTrackerTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 4/12/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking

class TelemetryTrackerTests: XCTestCase {

    var apiClient: APIClientMock!
    var sut: TelemetryTrackerProtocol!

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

    func testSendTelemetryEventGivenAnalyticsIsDisabledAndTelemetryIsEnabledShouldNotSendAnyRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = false
        analyticsConfiguration.isTelemetryEnabled = true
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedRequestCalls = 0

        // When
        sut.sendTelemetryEvent(flavor: .components(type: .affirm))

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testSendTelemetryEventGivenTelemetryIsDisabledShouldNotSendAnyRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isTelemetryEnabled = false
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let expectedRequestCalls = 0

        // When
        sut.sendTelemetryEvent(flavor: .components(type: .affirm))

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testSendTelemetryEventGivenTelemetryIsEnabledAndFlavorIsDropInComponentShouldNotSendAnyRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isTelemetryEnabled = true
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let flavor: TelemetryFlavor = .dropInComponent
        let expectedRequestCalls = 0

        // When
        sut.sendTelemetryEvent(flavor: flavor)

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testSendTelemetryEventGivenTelemetryIsEnabledAndFlavorIsComponentsShouldSendTelemetryRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isTelemetryEnabled = true
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let flavor: TelemetryFlavor = .components(type: .affirm)
        let expectedRequestCalls = 2

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        let telemetryResult: Result<Response, Error> = .success(telemetryResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult, telemetryResult]

        // When
        sut.sendTelemetryEvent(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
    }

    func testSendTelemetryEventGivenTelemetryIsEnabledAndFlavorIsDropInShouldSendTelemetryRequest() throws {
        // Given
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isTelemetryEnabled = true
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)

        let flavor: TelemetryFlavor = .dropIn(paymentMethods: ["scheme", "paypal", "affirm"])
        let expectedRequestCalls = 2

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        let telemetryResult: Result<Response, Error> = .success(telemetryResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult, telemetryResult]

        // When
        sut.sendTelemetryEvent(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
    }

    // MARK: - Private

    private var checkoutAttemptIdResponse: CheckoutAttemptIdResponse {
        .init(identifier: "cb3eef98-978e-4f6f-b299-937a4450be1f1648546838056be73d8f38ee8bcc3a65ec14e41b037a59f255dcd9e83afe8c06bd3e7abcad993")
    }

    private let telemetryResponse = TelemetryResponse()
}
