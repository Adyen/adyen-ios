//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
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
    
    func testUnionPayType() {
        assert(cardNumbers: CardNumbers.unionPay, with: CardType.unionPay)
    }
    
    func testUATPType() {
        assert(cardNumbers: CardNumbers.uatp, with: CardType.uatp)
    }
    
    private func assert(cardNumbers: [String], with type: CardType) {
        let cardTypeDetector = CardTypeDetector()
        cardTypeDetector.detectableTypes = [type]
        
        cardNumbers.forEach { cardNumber in
            let detectedType = cardTypeDetector.type(forCardNumber: cardNumber)
            XCTAssertEqual(detectedType, type, "\(cardNumber) does not match \(type) (found: \(detectedType?.rawValue ?? "nil")).")
        }
    }
}
