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

    private func assert(cardNumbers: [String], with brand: CardBrand?) {
        let toDetect: [CardBrand] = brand != nil ? [brand!] : []
        
        cardNumbers.forEach { cardNumber in
            XCTAssertEqual(toDetect.adyen.type(forCardNumber: cardNumber), toDetect.first)
            XCTAssertEqual(toDetect.adyen.types(forCardNumber: cardNumber), toDetect)
        }
    }
}
