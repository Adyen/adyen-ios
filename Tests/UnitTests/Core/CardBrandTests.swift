//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct CardBrandTests {

    @Test(arguments: [CardBrand.accel, .pulse, .star, .nyce])
    func isLogoHidden_givenUSDebitBrand_shouldReturnTrue(brand: CardBrand) {
        #expect(brand.isLogoHidden)
    }

    @Test(arguments: [CardBrand.visa, .masterCard, .americanExpress, .carteBancaire, .bcmc, .other(named: "star_debit")])
    func isLogoHidden_givenOtherBrand_shouldReturnFalse(brand: CardBrand) {
        #expect(!brand.isLogoHidden)
    }
}
