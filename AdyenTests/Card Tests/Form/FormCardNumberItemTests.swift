//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {
    
    func testCardLogos() {
        let item = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 2)
        
        // Initially, both card type logos should be visible.
        XCTAssertFalse(item.cardTypeLogos[0].isHidden.value)
        XCTAssertFalse(item.cardTypeLogos[1].isHidden.value)
        
        // After starting to type, only Mastercard should be visible.
        item.value = "5"
        XCTAssertTrue(item.cardTypeLogos[0].isHidden.value)
        XCTAssertFalse(item.cardTypeLogos[1].isHidden.value)
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        XCTAssertTrue(item.cardTypeLogos[0].isHidden.value)
        XCTAssertFalse(item.cardTypeLogos[1].isHidden.value)
        
        // Clearing the field should bring back both logos.
        item.value = ""
        XCTAssertFalse(item.cardTypeLogos[0].isHidden.value)
        XCTAssertFalse(item.cardTypeLogos[1].isHidden.value)
        
        // After starting to type a new number, only VISA should be visible.
        item.value = "4"
        XCTAssertFalse(item.cardTypeLogos[0].isHidden.value)
        XCTAssertTrue(item.cardTypeLogos[1].isHidden.value)
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
