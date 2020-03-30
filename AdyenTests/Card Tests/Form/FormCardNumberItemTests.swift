//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {
    
    let supportedCardTypes: [CardType] = [.visa, .masterCard, .americanExpress]
    
    func testCardLogos() {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 3)
        
        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        
        // Initially, all card type logos should be visible.
        XCTAssertEqual(visa.isHidden.value, false)
        XCTAssertEqual(mc.isHidden.value, false)
        XCTAssertEqual(amex.isHidden.value, false)
        
        // When typing unknown combination, all logos should be hidden.
        item.value = "5"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, true)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // When typing unknown combination, all logos should be hidden.
        item.value = "56"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, true)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // After starting to type, only Mastercard should be visible.
        item.value = "55"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, false)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, false)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // When entering PAN, Mastercard should remain visible.
        item.value = "5577000055770004"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, false)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // When entering too long PAN, all logos should be hidden.
        item.value = "55770000557700040"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, true)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // Clearing the field should bring back both logos.
        item.value = ""
        XCTAssertEqual(visa.isHidden.value, false)
        XCTAssertEqual(mc.isHidden.value, false)
        XCTAssertEqual(amex.isHidden.value, false)
        
        // After starting to type a new number, only VISA should be visible.
        item.value = "4"
        XCTAssertEqual(visa.isHidden.value, false)
        XCTAssertEqual(mc.isHidden.value, true)
        XCTAssertEqual(amex.isHidden.value, true)
        
        // After starting to type a new number, only Amex should be visible.
        item.value = "34"
        XCTAssertEqual(visa.isHidden.value, true)
        XCTAssertEqual(mc.isHidden.value, true)
        XCTAssertEqual(amex.isHidden.value, false)
    }
    
    func testLocalizationWithCustomTableName() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen.card.numberItem.title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen.card.numberItem.placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen.card.numberItem.invalid", expectedLocalizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen_card_numberItem_title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen_card_numberItem_placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen_card_numberItem_invalid", expectedLocalizationParameters))
    }
    
}
