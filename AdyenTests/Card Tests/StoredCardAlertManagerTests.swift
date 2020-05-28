//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class StoredCardAlertManagerTests: XCTestCase {
    
    let storedCardDictionary = [
        "type": "scheme",
        "id": "9314881977134903",
        "name": "VISA",
        "brand": "visa",
        "lastFour": "1111",
        "expiryMonth": "08",
        "expiryYear": "2018",
        "holderName": "test",
        "supportedShopperInteractions": [
            "Ecommerce",
            "ContAuth"
        ]
    ] as [String: Any]
    
    func testLocalizationWithCustomTableName() throws {
        let method = try Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
        let amount = Payment.Amount(value: 3, currencyCode: "EUR")
        let sut = StoredCardAlertManager(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey(), amount: amount)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let alertController = sut.alertController
        
        XCTAssertEqual(alertController.title, ADYLocalizedString("adyen.card.stored.title", sut.localizationParameters))
        let displayInformation = method.localizedDisplayInformation(using: sut.localizationParameters)
        XCTAssertEqual(alertController.message, ADYLocalizedString("adyen.card.stored.message", sut.localizationParameters, displayInformation.title))
        
        XCTAssertNotNil(alertController.textFields)
        XCTAssertEqual(alertController.textFields?.count, 1)
        XCTAssertEqual(alertController.textFields?.first?.placeholder, ADYLocalizedString("adyen.card.cvcItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(alertController.textFields?.first?.accessibilityLabel, ADYLocalizedString("adyen.card.cvcItem.title", sut.localizationParameters))
        
        XCTAssertEqual(alertController.actions.count, 2)
        XCTAssertEqual(alertController.actions.first?.title, ADYLocalizedString("adyen.cancelButton", sut.localizationParameters))
        XCTAssertEqual(alertController.actions[1].title, ADYLocalizedSubmitButtonTitle(with: amount, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let method = try Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
        let amount = Payment.Amount(value: 3, currencyCode: "EUR")
        let sut = StoredCardAlertManager(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey(), amount: amount)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let alertController = sut.alertController
        
        XCTAssertEqual(alertController.title, ADYLocalizedString("adyen_card_stored_title", sut.localizationParameters))
        let displayInformation = method.localizedDisplayInformation(using: sut.localizationParameters)
        XCTAssertEqual(alertController.message, ADYLocalizedString("adyen_card_stored_message", sut.localizationParameters, displayInformation.title))
        
        XCTAssertNotNil(alertController.textFields)
        XCTAssertEqual(alertController.textFields?.count, 1)
        XCTAssertEqual(alertController.textFields?.first?.placeholder, ADYLocalizedString("adyen_card_cvcItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(alertController.textFields?.first?.accessibilityLabel, ADYLocalizedString("adyen_card_cvcItem_title", sut.localizationParameters))
        
        XCTAssertEqual(alertController.actions.count, 2)
        XCTAssertEqual(alertController.actions.first?.title, ADYLocalizedString("adyen_cancelButton", sut.localizationParameters))
        XCTAssertEqual(alertController.actions[1].title, ADYLocalizedSubmitButtonTitle(with: amount, sut.localizationParameters))
    }
    
}
