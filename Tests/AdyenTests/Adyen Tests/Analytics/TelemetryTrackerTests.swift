//
//  TelemetryTrackerTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 4/12/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen
@testable import AdyenNetworking


class TelemetryTrackerTests: XCTestCase {

    var apiClient: APIClientMock!
    var analyticsConfiguration: AnalyticsConfiguration!
    var sut: TelemetryTrackerProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = APIClientMock()
        analyticsConfiguration = .init()
        sut = AnalyticsProvider(apiClient: apiClient, configuration: analyticsConfiguration)
    }

    override func tearDownWithError() throws {
        apiClient = nil
        analyticsConfiguration = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testTrackTelemetryEventGivenAnalyticsIsDisabledAndTelemetryIsEnabledShouldNotSendAnyRequest() throws {
        // Given
        let expectedRequestCalls = 0
        analyticsConfiguration.isEnabled = false
        analyticsConfiguration.isTelemetryEnabled = true

        // When
        sut.trackTelemetryEvent(flavor: .components(type: .affirm))

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testTrackTelemetryEventGivenTelemetryIsDisabledShouldNotSendAnyRequest() throws {
        // Given
        let expectedRequestCalls = 0
        analyticsConfiguration.isTelemetryEnabled = false

        // When
        sut.trackTelemetryEvent(flavor: .components(type: .affirm))

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testTrackTelemetryEventGivenTelemetryIsEnabledAndFlavorIsDropInComponentShouldNotSendAnyRequest() throws {
        // Given
        let expectedRequestCalls = 0
        analyticsConfiguration.isTelemetryEnabled = true
        let flavor: TelemetryFlavor = .dropInComponent

        // When
        sut.trackTelemetryEvent(flavor: flavor)

        // Then
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "One or more telemetry requests were sent.")
    }

    func testTrackTelemetryEventGivenTelemetryIsEnabledAndFlavorIsComponentsShouldSendTelemetryRequest() throws {
        // Given
        let expectedRequestCalls = 2
        analyticsConfiguration.isTelemetryEnabled = true
        let flavor: TelemetryFlavor = .components(type: .affirm)

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        let telemetryResult: Result<Response, Error> = .success(telemetryResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult, telemetryResult]

        // When
        sut.trackTelemetryEvent(flavor: flavor)

        // Then
        wait(for: .milliseconds(1))
        XCTAssertEqual(expectedRequestCalls, apiClient.counter, "Invalid request number made.")
    }

    func testTrackTelemetryEventGivenTelemetryIsEnabledAndFlavorIsDropInShouldSendTelemetryRequest() throws {
        // Given
        let expectedRequestCalls = 2
        analyticsConfiguration.isTelemetryEnabled = true
        let flavor: TelemetryFlavor = .dropIn(paymentMethods: ["scheme", "paypal", "affirm"])

        let checkoutAttemptIdResult: Result<Response, Error> = .success(checkoutAttemptIdResponse)
        let telemetryResult: Result<Response, Error> = .success(telemetryResponse)
        apiClient.mockedResults = [checkoutAttemptIdResult, telemetryResult]

        // When
        sut.trackTelemetryEvent(flavor: flavor)

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
