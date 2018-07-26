//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardValidatorTests: XCTestCase {
    func testValidateWithMasterCardAgainstAllCards() {
        expect(cards: CardNumbers.masterCard, beEqualTo: .masterCard, acceptedCards: CardType.all)
    }
    
    func testValidateWithVisaAgainstAllCards() {
        expect(cards: CardNumbers.visa, beEqualTo: .visa, acceptedCards: CardType.all)
    }
    
    func testValidateWithJcbAgainstAllCards() {
        expect(cards: CardNumbers.jcb, beEqualTo: .jcb, acceptedCards: CardType.all)
    }
    
    func testValidateWithCartebancaireAgainstAllCards() {
        //Credit bancaire will return visa
        expect(cards: CardNumbers.cartebancaire, beEqualTo: .visa, acceptedCards: CardType.all)
    }
    
    func testValidateWithAmericanExpressAgainstAllCards() {
        expect(cards: CardNumbers.americanExpress, beEqualTo: .americanExpress, acceptedCards: CardType.all)
    }
    
    func testValidateWithDinersAgainstAllCards() {
        expect(cards: CardNumbers.diners, beEqualTo: .diners, acceptedCards: CardType.all)
    }
    
    func testValidateWithDiscoverAgainstAllCards() {
        expect(cards: CardNumbers.discover, beEqualTo: .discover, acceptedCards: CardType.all)
    }
    
    func testValidateWithBancontactAgainstAllCards() {
        expect(cards: CardNumbers.bancontact, beEqualTo: .bcmc, acceptedCards: CardType.all)
    }
    
    func testValidateWithHipercardAgainstAllCards() {
        expect(cards: CardNumbers.hipercard, beEqualTo: .hipercard, acceptedCards: CardType.all)
    }
    
    func testValidateWithEloAgainstAllCards() {
        expect(cards: CardNumbers.elo, beEqualTo: .elo, acceptedCards: CardType.all)
    }
    
    func testValidateWithDankortAgainstAllCards() {
        expect(cards: CardNumbers.dankort, beEqualTo: .dankort, acceptedCards: CardType.all)
    }
    
    func testValidateWithUnionPayAgainstAllCards() {
        expect(cards: CardNumbers.unionPay, beEqualTo: .unionPay, acceptedCards: CardType.all)
    }
    
    func testValidateWithUatpAgainstAllCards() {
        expect(cards: CardNumbers.uatp, beEqualTo: .uatp, acceptedCards: CardType.all)
    }
    
    func testValidateWithRestrictedAcceptedCards() {
        let acceptedCards = [CardType.visa, CardType.diners]
        
        let (_, visaType, _) = CardValidator.validate(cardNumber: CardNumbers.visa.first!, acceptedCardTypes: acceptedCards)
        let (_, dinersType, _) = CardValidator.validate(cardNumber: CardNumbers.diners.first!, acceptedCardTypes: acceptedCards)
        let (_, mcType, _) = CardValidator.validate(cardNumber: CardNumbers.americanExpress.first!, acceptedCardTypes: acceptedCards)
        let (_, amexType, _) = CardValidator.validate(cardNumber: CardNumbers.masterCard.first!, acceptedCardTypes: acceptedCards)
        
        XCTAssertEqual(visaType, .visa)
        XCTAssertEqual(dinersType, .diners)
        XCTAssertNil(mcType)
        XCTAssertNil(amexType)
    }
    
    func testValidateWithPartialCard() {
        let (valid, type, _) = CardValidator.validate(cardNumber: "4111 1", acceptedCardTypes: CardType.all)
        
        XCTAssertEqual(type, .visa)
        XCTAssertFalse(valid)
    }
    
    func expect(cards: [String], beEqualTo expectedType: CardType, acceptedCards: [CardType]) {
        for card in cards {
            let (_, type, _) = CardValidator.validate(cardNumber: card, acceptedCardTypes: acceptedCards)
            
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
