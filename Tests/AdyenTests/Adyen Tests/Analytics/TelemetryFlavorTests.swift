//
//  TelemetryFlavorTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 4/13/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

class TelemetryFlavorTests: XCTestCase {

    var sut: TelemetryFlavor!

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testTelemetryFlavorValueWhenFlavorIsComponentsMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "components"

        // When
        sut = .components(type: .affirm)

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }

    func testTelemetryFlavorValueWhenFlavorIsDropInMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "dropin"

        // When
        sut = .dropIn(paymentMethods: ["scheme", "affirm", "atome"])

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }

    func testTelemetryFlavorValueWhenFlavorIsDropInComponentMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "dropInComponent"

        // When
        sut = .dropInComponent

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }
}
