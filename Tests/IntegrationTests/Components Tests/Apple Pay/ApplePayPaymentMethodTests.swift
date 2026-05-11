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

    func testSupportedNetworks_givenNilBrands_shouldReturnAppleSupportedNetworks() {
        // Given
        let expectedBrands: [String] = ["visa", "mc"]
        let sut = makeSUT(brands: nil)
        let networksProviderMock = ApplePayNetworksProvidingMock()
        networksProviderMock.availableNetworksReturnValue = [.visa, .masterCard]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
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
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    func testSupportedNetworks_givenMultipleNetworksWithSameTxVariantName_shouldReturnAll() {
        // Given
        let sut = makeSUT(brands: ["cartebancaire"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        let network1 = PKPaymentNetwork.carteBancaire
        let network2 = PKPaymentNetwork.cartesBancaires
        networksProviderMock.availableNetworksReturnValue = [network1, network2]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], network1)
        XCTAssertEqual(result[1], network2)
    }

    func testSupportedNetworks_givenMultipleBrandsWithMultipleVariants_shouldReturnAllGroupedByBrand() {
        // Given
        let sut = makeSUT(brands: ["visa", "mc"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        let visa1 = PKPaymentNetwork(rawValue: "visa")
        let visa2 = PKPaymentNetwork(rawValue: "Visa")
        let mc1 = PKPaymentNetwork.masterCard
        let mc2 = PKPaymentNetwork(rawValue: "mc")
        networksProviderMock.availableNetworksReturnValue = [visa1, visa2, mc1, mc2]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then: visa variants first (in provider order), then mc variants
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0], visa1)
        XCTAssertEqual(result[1], visa2)
        XCTAssertEqual(result[2], mc1)
        XCTAssertEqual(result[3], mc2)
    }

    func testSupportedNetworks_givenBrandWithNoMatchingVariants_shouldSkipIt() {
        // Given
        let sut = makeSUT(brands: ["visa", "unknown", "mc"])
        let networksProviderMock = ApplePayNetworksProvidingMock()
        let visa1 = PKPaymentNetwork(rawValue: "visa")
        let visa2 = PKPaymentNetwork(rawValue: "VISA")
        networksProviderMock.availableNetworksReturnValue = [visa1, visa2, .masterCard]

        // When
        let result = sut.supportedNetworks(provider: networksProviderMock)

        // Then: visa variants, then mc (unknown skipped)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], visa1)
        XCTAssertEqual(result[1], visa2)
        XCTAssertEqual(result[2], .masterCard)
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
        let receivedBrands = result.map(\.txVariantName)
        XCTAssertEqual(expectedBrands, receivedBrands)
    }

    // MARK: - Private

    private func makeSUT(brands: [String]?) -> ApplePayPaymentMethod {
        ApplePayPaymentMethod(
            type: .applePay,
            name: "ApplePay",
            merchantProvidedDisplayInformation: nil,
            brands: brands
        )
    }
}
