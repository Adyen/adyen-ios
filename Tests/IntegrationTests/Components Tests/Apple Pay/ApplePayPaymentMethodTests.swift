//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
import PassKit
import XCTest

final class ApplePayPaymentMethodTests: XCTestCase {

    // MARK: - supportedNetworks tests

    func testSupportedNetworks_givenNilBrands_shouldReturnEmpty() {
        // Given
        let expectedBrands: [String] = []
        let sut = makeSUT(brands: nil)
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.visa, .masterCard]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 0)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenEmptyBrands_shouldReturnEmpty() {
        // Given
        let expectedBrands: [String] = []
        let sut = makeSUT(brands: expectedBrands)
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.visa, .masterCard]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenUnknownBrand_shouldIgnoreIt() {
        // Given
        let expectedBrands = ["visa"]
        let sut = makeSUT(brands: ["unknown", "visa"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.visa]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenDuplicateNetworks_shouldUseFirstOccurrence() {
        // Given
        let expectedBrands = ["cartebancaire"]
        let sut = makeSUT(brands: expectedBrands)
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [
            PKPaymentNetwork(rawValue: "cartebancaire"), // first
            PKPaymentNetwork(rawValue: "cartebancaire") // duplicate—ignored
        ]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenBrandsOrder_shouldPreserveOrderInOutput() {
        // Given
        let expectedBrands = ["mc", "visa", "amex"]
        let sut = makeSUT(brands: expectedBrands)
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.amex, .visa, .masterCard]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenProviderReturnsNoNetworks_shouldReturnEmpty() {
        // Given
        let expectedBrands: [String] = []
        let sut = makeSUT(brands: ["visa"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [] // no Apple Pay support

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenMixedKnownAndUnknownBrands_shouldReturnOnlyKnown() {
        // Given
        let expectedBrands = ["visa", "mc"]
        let sut = makeSUT(brands: ["visa", "unknown1", "mc", "unknown2"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.masterCard, .visa]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(networksProviderMock.availableNetworksCallsCount, 1)
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    // MARK: - Private

    private func makeSUT(brands: [String]?) -> ApplePayPaymentMethod {
        let sut = ApplePayPaymentMethod(
            type: .applePay,
            name: "ApplePay",
            merchantProvidedDisplayInformation: nil,
            brands: brands
        )

        return sut
    }
}
