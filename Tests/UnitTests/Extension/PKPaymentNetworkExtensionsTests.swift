//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenComponents
import PassKit
import XCTest

final class PKPaymentNetworkExtensionsTests: XCTestCase {

    /// Note: Edge case where we transform `masterCard` into `mc`
    func test_txVariantName_givenMastercard_shouldReturnMC() {
        // Given
        let expectedVariantName = "mc"
        let sut = PKPaymentNetwork.masterCard

        // When
        let receivedVariantName = sut.txVariantName

        // Then
        XCTAssertEqual(expectedVariantName, receivedVariantName)
    }

    /// Note: Edge case where we transform `cartesBancaires` into `cartebancaire`
    func test_txVariantName_givenCartesBancaires_shouldReturnCartebancaire() {
        // Given
        let expectedVariantName = "cartebancaire"
        let sut = PKPaymentNetwork.cartesBancaires

        // When
        let receivedVariantName = sut.txVariantName

        // Then
        XCTAssertEqual(expectedVariantName, receivedVariantName)
    }

    func test_txVariantName_givenUppercasedNetwork_shouldReturnVariantNameLowercased() {
        // Given
        let sut = PKPaymentNetwork.JCB
        let expectedVariantName = "jcb"

        // When
        let receivedVariantName = sut.txVariantName

        // Then
        XCTAssertEqual(expectedVariantName, receivedVariantName)
    }

    func test_txVariantName_givenLowercasedNetwork_shouldReturnSame() {
        // Given
        let sut = PKPaymentNetwork.amex
        let expectedVariantName = "amex"

        // When
        let receivedVariantName = sut.txVariantName

        // Then
        XCTAssertEqual(expectedVariantName, receivedVariantName)
    }

    func test_txVariantName_givenMixedCasedNetwork_shouldReturnVariantNameLowercased() {
        // Given
        let sut = PKPaymentNetwork(rawValue: "DiSCover")
        let expectedVariantName = "discover"

        // When
        let receivedVariantName = sut.txVariantName

        // Then
        XCTAssertEqual(expectedVariantName, receivedVariantName)
    }
}
