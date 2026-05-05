//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardTypeDetectorTests: XCTestCase {
    
    func testMastercardType() {
        assert(cardNumbers: CardNumbers.masterCard, with: CardType.masterCard)
    }
    
    func testVisaType() {
        assert(cardNumbers: CardNumbers.visa, with: CardType.visa)
    }
    
    func testJCBType() {
        assert(cardNumbers: CardNumbers.jcb, with: CardType.jcb)
    }
    
    func testCarteBancaireType() {
        assert(cardNumbers: CardNumbers.cartebancaire, with: CardType.carteBancaire)
    }
    
    func testAmexType() {
        assert(cardNumbers: CardNumbers.amex, with: CardType.americanExpress)
    }
    
    func testDinersType() {
        assert(cardNumbers: CardNumbers.diners, with: CardType.diners)
    }
    
    func testDiscoverType() {
        assert(cardNumbers: CardNumbers.discover, with: CardType.discover)
    }
    
    func testBancontactType() {
        assert(cardNumbers: CardNumbers.bancontact, with: CardType.bcmc)
    }
    
    func testHiperCardType() {
        assert(cardNumbers: CardNumbers.hipercard, with: CardType.hipercard)
    }
    
    func testEloType() {
        assert(cardNumbers: CardNumbers.elo, with: CardType.elo)
    }
    
    func testDankortType() {
        assert(cardNumbers: CardNumbers.dankort, with: CardType.dankort)
    }
    
    func testUATPType() {
        assert(cardNumbers: CardNumbers.uatp, with: CardType.uatp)
    }

    func testInvalid() {
        assert(cardNumbers: CardNumbers.invalid, with: nil)
    }

    // MARK: - Dankort extended prefixes
    
    func testDankortType_4571Prefix() {
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "4571123456789012"))
    }
    
    func testDankortType_3571Prefix() {
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "3571123456789012"))
    }
    
    func testDankortType_partialPrefixes_match() {
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "5"), "Partial path toward 5019")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "50"), "Partial path toward 5019")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "501"), "Partial path toward 5019")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "5019"), "Full prefix")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "4"), "Partial path toward 4571")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "45"), "Partial path toward 4571")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "457"), "Partial path toward 4571")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "3"), "Partial path toward 3571")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "35"), "Partial path toward 3571")
        XCTAssertTrue(CardType.dankort.matches(cardNumber: "357"), "Partial path toward 3571")
    }
    
    func testDankortType_divergedPrefixes_doNotMatch() {
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "502"), "Diverged from 5019")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "5018"), "Diverged from 5019")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "51"), "Not a dankort path")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "46"), "Diverged from 4571")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "4572"), "Diverged from 4571")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "36"), "Diverged from 3571")
        XCTAssertFalse(CardType.dankort.matches(cardNumber: "3572"), "Diverged from 3571")
    }
    
    // MARK: - Co-badge: first matching brand from supported types order
    
    /// FR scenario: carteBancaire first in supported types → shown first for visa/cb overlap
    func testCoBadge_FR_carteBancaireFirstInOrder_shownForVisaPrefix() {
        let supportedTypes: [CardType] = [.carteBancaire, .visa, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "4"),
            .carteBancaire,
            "When carteBancaire is first in supported types, it should match before visa for 4-prefix"
        )
        XCTAssertEqual(
            supportedTypes.adyen.types(forCardNumber: "4"),
            [.carteBancaire, .visa],
            "Both carteBancaire and visa should match 4-prefix"
        )
    }
    
    func testCoBadge_FR_carteBancaireFirstInOrder_shownForMCPrefix() {
        let supportedTypes: [CardType] = [.carteBancaire, .visa, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "51"),
            .carteBancaire,
            "When carteBancaire is first, it should match before mc for 51-prefix"
        )
        XCTAssertEqual(
            supportedTypes.adyen.types(forCardNumber: "51"),
            [.carteBancaire, .masterCard],
            "Both carteBancaire and mc should match 51-prefix"
        )
    }
    
    /// FR scenario: visa first in supported types → visa shown first
    func testCoBadge_FR_visaFirstInOrder_shownForVisaPrefix() {
        let supportedTypes: [CardType] = [.visa, .carteBancaire, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "4"),
            .visa,
            "When visa is first in supported types, it should match before carteBancaire for 4-prefix"
        )
    }
    
    /// DK scenario: dankort first in supported types
    func testCoBadge_DK_dankortFirstInOrder_shownFor5019() {
        let supportedTypes: [CardType] = [.dankort, .visa, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "5019"),
            .dankort,
            "When dankort is first, it should match for 5019 prefix"
        )
    }
    
    func testCoBadge_DK_dankortFirstInOrder_shownFor4571() {
        let supportedTypes: [CardType] = [.dankort, .visa, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "4571"),
            .dankort,
            "When dankort is first, it should match before visa for 4571 prefix"
        )
        XCTAssertEqual(
            supportedTypes.adyen.types(forCardNumber: "4571"),
            [.dankort, .visa],
            "Both dankort and visa should match 4571 prefix"
        )
    }
    
    /// DK scenario: dankort matches partial prefix 501 when first in supported types
    func testCoBadge_DK_dankortFirstInOrder_shownForPartialPrefix501() {
        let supportedTypes: [CardType] = [.dankort, .visa, .masterCard, .maestro]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "501"),
            .dankort,
            "When dankort is first and 501 is a partial path toward 5019, dankort should match"
        )
    }
    
    /// DK scenario: when dankort is not first, maestro can match 501 instead
    func testCoBadge_DK_maestroFirstInOrder_shownForPartialPrefix501() {
        let supportedTypes: [CardType] = [.maestro, .dankort, .visa, .masterCard]
        
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "501"),
            .maestro,
            "When maestro is first, it should match before dankort for 501"
        )
    }
    
    /// DK scenario: once prefix diverges from dankort, it falls off
    func testCoBadge_DK_dankortDropsOffWhenDiverged() {
        let supportedTypes: [CardType] = [.dankort, .visa, .masterCard, .maestro]
        
        XCTAssertFalse(
            supportedTypes.adyen.types(forCardNumber: "502").contains(.dankort),
            "502 diverges from 5019 — dankort should not match"
        )
        XCTAssertEqual(
            supportedTypes.adyen.type(forCardNumber: "502"),
            .maestro,
            "After dankort drops off, maestro should match 502"
        )
    }
    
    /// Verify order determines which brand is returned first when multiple match
    func testCoBadge_orderDeterminesFirstMatch() {
        let orderA: [CardType] = [.carteBancaire, .visa]
        let orderB: [CardType] = [.visa, .carteBancaire]
        
        XCTAssertEqual(
            orderA.adyen.type(forCardNumber: "4111"),
            .carteBancaire,
            "carteBancaire first in array → carteBancaire returned"
        )
        XCTAssertEqual(
            orderB.adyen.type(forCardNumber: "4111"),
            .visa,
            "visa first in array → visa returned"
        )
    }
    
    private func assert(cardNumbers: [String], with type: CardType?) {
        let toDetect: [CardType] = type != nil ? [type!] : []
        
        cardNumbers.forEach { cardNumber in
            XCTAssertEqual(toDetect.adyen.type(forCardNumber: cardNumber), toDetect.first)
            XCTAssertEqual(toDetect.adyen.types(forCardNumber: cardNumber), toDetect)
        }
    }
}
