//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import XCTest

class CardBrandDetectorTests: XCTestCase {
    
    func testMastercardBrand() {
        assert(cardNumbers: CardNumbers.masterCard, with: CardBrand.masterCard)
    }
    
    func testVisaType() {
        assert(cardNumbers: CardNumbers.visa, with: CardBrand.visa)
    }
    
    func testJCBType() {
        assert(cardNumbers: CardNumbers.jcb, with: CardBrand.jcb)
    }
    
    func testCarteBancaireType() {
        assert(cardNumbers: CardNumbers.cartebancaire, with: CardBrand.carteBancaire)
    }
    
    func testAmexType() {
        assert(cardNumbers: CardNumbers.amex, with: CardBrand.americanExpress)
    }
    
    func testDinersType() {
        assert(cardNumbers: CardNumbers.diners, with: CardBrand.diners)
    }
    
    func testDiscoverType() {
        assert(cardNumbers: CardNumbers.discover, with: CardBrand.discover)
    }
    
    func testBancontactType() {
        assert(cardNumbers: CardNumbers.bancontact, with: CardBrand.bcmc)
    }
    
    func testHiperCardBrand() {
        assert(cardNumbers: CardNumbers.hipercard, with: CardBrand.hipercard)
    }
    
    func testEloType() {
        assert(cardNumbers: CardNumbers.elo, with: CardBrand.elo)
    }
    
    func testDankortType() {
        assert(cardNumbers: CardNumbers.dankort, with: CardBrand.dankort)
    }
    
    func testUATPType() {
        assert(cardNumbers: CardNumbers.uatp, with: CardBrand.uatp)
    }

    func testInvalid() {
        assert(cardNumbers: CardNumbers.invalid, with: nil)
    }

    // MARK: - Dankort extended prefixes

    func test_dankortMatches_with4571Prefix_shouldMatch() {
        XCTAssertTrue(CardBrand.dankort.matches(cardNumber: "4571123456789012"))
    }

    func test_dankortMatches_with3571Prefix_shouldMatch() {
        XCTAssertTrue(CardBrand.dankort.matches(cardNumber: "3571123456789012"))
    }

    func test_dankortMatches_withPartialPrefixes_shouldMatch() {
        let partialPrefixes = ["5", "50", "501", "5019", "4", "45", "457", "3", "35", "357"]

        partialPrefixes.forEach { prefix in
            XCTAssertTrue(CardBrand.dankort.matches(cardNumber: prefix), "Expected \(prefix) to match")
        }
    }

    func test_dankortMatches_withDivergedPrefixes_shouldNotMatch() {
        let divergedPrefixes = ["502", "5018", "51", "46", "4572", "36", "3572"]

        divergedPrefixes.forEach { prefix in
            XCTAssertFalse(CardBrand.dankort.matches(cardNumber: prefix), "Expected \(prefix) not to match")
        }
    }

    // MARK: - Co-badge detection order

    func test_typeForCardNumber_withCarteBancaireFirstAndVisaPrefix_shouldReturnCarteBancaire() {
        let supportedBrands: [CardBrand] = [.carteBancaire, .visa, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "4"), .carteBancaire)
        XCTAssertEqual(supportedBrands.adyen.types(forCardNumber: "4"), [.carteBancaire, .visa])
    }

    func test_typeForCardNumber_withCarteBancaireFirstAndMasterCardPrefix_shouldReturnCarteBancaire() {
        let supportedBrands: [CardBrand] = [.carteBancaire, .visa, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "51"), .carteBancaire)
        XCTAssertEqual(supportedBrands.adyen.types(forCardNumber: "51"), [.carteBancaire, .masterCard])
    }

    func test_typeForCardNumber_withVisaFirstAndVisaPrefix_shouldReturnVisa() {
        let supportedBrands: [CardBrand] = [.visa, .carteBancaire, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "4"), .visa)
    }

    func test_typeForCardNumber_withDankortFirstAnd5019Prefix_shouldReturnDankort() {
        let supportedBrands: [CardBrand] = [.dankort, .visa, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "5019"), .dankort)
    }

    func test_typeForCardNumber_withDankortFirstAnd4571Prefix_shouldReturnDankort() {
        let supportedBrands: [CardBrand] = [.dankort, .visa, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "4571"), .dankort)
        XCTAssertEqual(supportedBrands.adyen.types(forCardNumber: "4571"), [.dankort, .visa])
    }

    func test_typeForCardNumber_withDankortFirstAndPartialPrefix501_shouldReturnDankort() {
        let supportedBrands: [CardBrand] = [.dankort, .visa, .masterCard, .maestro]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "501"), .dankort)
    }

    func test_typeForCardNumber_withMaestroFirstAndPartialPrefix501_shouldReturnMaestro() {
        let supportedBrands: [CardBrand] = [.maestro, .dankort, .visa, .masterCard]

        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "501"), .maestro)
    }

    func test_typeForCardNumber_withPrefixDivergedFromDankort_shouldNotReturnDankort() {
        let supportedBrands: [CardBrand] = [.dankort, .visa, .masterCard, .maestro]

        XCTAssertFalse(supportedBrands.adyen.types(forCardNumber: "502").contains(.dankort))
        XCTAssertEqual(supportedBrands.adyen.type(forCardNumber: "502"), .maestro)
    }

    func test_typeForCardNumber_withMultipleMatches_shouldFollowSupportedBrandsOrder() {
        let carteBancaireFirst: [CardBrand] = [.carteBancaire, .visa]
        let visaFirst: [CardBrand] = [.visa, .carteBancaire]

        XCTAssertEqual(carteBancaireFirst.adyen.type(forCardNumber: "4111"), .carteBancaire)
        XCTAssertEqual(visaFirst.adyen.type(forCardNumber: "4111"), .visa)
    }

    private func assert(cardNumbers: [String], with brand: CardBrand?) {
        let toDetect: [CardBrand] = brand != nil ? [brand!] : []
        
        cardNumbers.forEach { cardNumber in
            XCTAssertEqual(toDetect.adyen.type(forCardNumber: cardNumber), toDetect.first)
            XCTAssertEqual(toDetect.adyen.types(forCardNumber: cardNumber), toDetect)
        }
    }
}
