//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenComponents
import PassKit
import XCTest

final class ApplePayBrandsMapperTests: XCTestCase {
//    let brands = ["Eftpos", "Maestro", "Discover", "AmEx"]
    let brands = ["eftpos", "maestro", "discover", "amex"]
    let supportedNetworks: [PKPaymentNetwork] = .init([.discover, .maestro, .amex, .eftpos])

    func testMapping() {
        let expectedMapping = supportedNetworks
        let mappingResult = ApplePayBrandsMapper.map(brands: brands, supportedNetworks: supportedNetworks)

        XCTAssertEqual(mappingResult, expectedMapping)
    }

    func test_mapper_resturnsResultRespectingBrandsOrder() {
        let expectedMapping: [PKPaymentNetwork] = [.eftpos, .maestro, .discover, .amex]
        let mappingResult = ApplePayBrandsMapperRepsectingBrandsOrder.map(brands: brands, supportedNetworks: supportedNetworks)

        XCTAssertEqual(mappingResult.map(\.txVariantName), expectedMapping.map(\.txVariantName))

    }
}
