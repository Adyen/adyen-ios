//
//  AnalyticsFlavorTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 4/13/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

class AnalyticsFlavorTests: XCTestCase {

    var sut: AnalyticsFlavor!

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testAnalyticsFlavorValueWhenFlavorIsComponentsMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "components"

        // When
        sut = .components(type: .affirm)

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }

    func testAnalyticsFlavorValueWhenFlavorIsDropInMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "dropin"

        // When
        sut = .dropIn(paymentMethods: ["scheme", "affirm", "atome"])

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }

    func testAnalyticsFlavorValueWhenFlavorIsDropInComponentMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "dropInComponent"

        // When
        sut = .dropInComponent

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }
}
