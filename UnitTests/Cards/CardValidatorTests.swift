//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class CardValidatorTests: XCTestCase {
    
    func testValidateWithMasterCardAgainstAllCards() {
        expect(cards: CardNumbers.masterCard, beEqualTo: .mc, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithVisaAgainstAllCards() {
        expect(cards: CardNumbers.visa, beEqualTo: .visa, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithJcbAgainstAllCards() {
        expect(cards: CardNumbers.jcb, beEqualTo: .jcb, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithCartebancaireAgainstAllCards() {
        //Credit bancaire will return visa
        expect(cards: CardNumbers.cartebancaire, beEqualTo: .visa, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithAmericanExpressAgainstAllCards() {
        expect(cards: CardNumbers.americanExpress, beEqualTo: .amex, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithDinersAgainstAllCards() {
        expect(cards: CardNumbers.diners, beEqualTo: .diners, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithDiscoverAgainstAllCards() {
        expect(cards: CardNumbers.discover, beEqualTo: .discover, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithBancontactAgainstAllCards() {
        expect(cards: CardNumbers.bancontact, beEqualTo: .bcmc, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithHipercardAgainstAllCards() {
        expect(cards: CardNumbers.hipercard, beEqualTo: .hipercard, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithEloAgainstAllCards() {
        expect(cards: CardNumbers.elo, beEqualTo: .elo, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithDankortAgainstAllCards() {
        expect(cards: CardNumbers.dankort, beEqualTo: .dankort, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithUnionPayAgainstAllCards() {
        expect(cards: CardNumbers.unionPay, beEqualTo: .unionPay, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithUatpAgainstAllCards() {
        expect(cards: CardNumbers.uatp, beEqualTo: .uatp, acceptedCards: CardType.allCards)
    }
    
    func testValidateWithRestrictedAcceptedCards() {
        let acceptedCards = [CardType.visa, CardType.diners]
        
        let (visaType, _, _) = CardValidator.validate(card: CardNumbers.visa.first!, acceptedCards: acceptedCards)
        let (dinersType, _, _) = CardValidator.validate(card: CardNumbers.diners.first!, acceptedCards: acceptedCards)
        let (mcType, _, _) = CardValidator.validate(card: CardNumbers.americanExpress.first!, acceptedCards: acceptedCards)
        let (amexType, _, _) = CardValidator.validate(card: CardNumbers.masterCard.first!, acceptedCards: acceptedCards)
        
        XCTAssertEqual(visaType, .visa)
        XCTAssertEqual(dinersType, .diners)
        XCTAssertEqual(mcType, .unknown)
        XCTAssertEqual(amexType, .unknown)
    }
    
    func testValidateWithPartialCard() {
        let (type, _, valid) = CardValidator.validate(card: "4111 1", acceptedCards: CardType.allCards)
        
        XCTAssertEqual(type, .visa)
        XCTAssertFalse(valid)
    }
    
    func expect(cards: [String], beEqualTo expectedType: CardType, acceptedCards: [CardType]) {
        for card in cards {
            let (type, _, _) = CardValidator.validate(card: card, acceptedCards: acceptedCards)
            
            XCTAssertEqual(type, expectedType)
        }
    }
}

class CardNumbers {
    static let masterCard = [
        "2223 0000 4841 0010", // Credit	NL
        "2223 5204 4356 0010", // Debit     NL
        "2222 4107 4036 0010", // Corporate	NL
        "5100 0811 1222 3332", // Bijenkorf	NL
        "5103 2219 1119 9245", // Prepaid	US
        "5100 2900 2900 2909", // Consumer	NL
        "5577 0000 5577 0004", // Consumer	PL
        "5136 3333 3333 3335", // Consumer	FR
        "5585 5585 5585 5583", // Consumer	ES
        "5555 4444 3333 1111", // Consumer	GB
        "5555 5555 5555 4444", // Corporate	GB
        "5500 0000 0000 0004", // Debit     US
        "5424 0000 0000 0015" // Pro       EC
    ]
    
    static let visa = [
        "4111 1111 1111 1111", // Consumer	NL
        "4988 4388 4388 4305", // Classic	ES
        "4166 6766 6766 6746", // Classic	NL
        "4646 4646 4646 4644", // Classic	PL
        "4444 3333 2222 1111", // Corporate	GB
        "4400 0000 0000 0008", // Debit     US
        "4977 9494 9494 9497" // Gold      FR
    ]
    
    static let jcb = [
        "3569 9900 1009 5841" // Consumer	US
    ]
    
    static let cartebancaire = [
        "4035 5010 0000 0008", // Visadebit/Cartebancaire	FR
        "4360 0000 0100 0005" // Cartebancaire             FR
    ]
    
    static let americanExpress = [
        "3700 0000 0000 002" // NL
    ]
    
    static let diners = [
        "3600 6666 3333 44" // US
    ]
    
    static let discover = [
        "6011 6011 6011 6611", // US
        "6445 6445 6445 6445" // GB
    ]
    
    static let bancontact = [
        "6703 4444 4444 4449" // BE
    ]
    
    static let hipercard = [
        "6062 8288 8866 6688" // BR
    ]
    
    static let elo = [
        "5066 9911 1111 1118" // BR
    ]
    
    static let dankort = [
        "5019 5555 4444 5555"
    ]
    
    static let unionPay = [
        "6250 9460 0000 0016", // Debit
        "6250 9470 0000 0014", // Credit
        "6243 0300 0000 0001" // Express Pay
    ]
    
    static let uatp = [
        "1354 1001 4004 955"
    ]
}
