//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
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
        let amount = Amount(value: 3, currencyCode: "EUR")
        let sut = StoredCardAlertManager(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey(), amount: amount)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let alertController = sut.alertController
        
        XCTAssertEqual(alertController.title, localizedString(.cardStoredTitle, sut.localizationParameters))
        let displayInformation = method.localizedDisplayInformation(using: sut.localizationParameters)
        XCTAssertEqual(alertController.message, localizedString(.cardStoredMessage, sut.localizationParameters, displayInformation.title))
        
        XCTAssertNotNil(alertController.textFields)
        XCTAssertEqual(alertController.textFields?.count, 1)
        XCTAssertEqual(alertController.textFields?.first?.placeholder, localizedString(.cardCvcItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(alertController.textFields?.first?.accessibilityLabel, localizedString(.cardCvcItemTitle, sut.localizationParameters))
        
        XCTAssertEqual(alertController.actions.count, 2)
        XCTAssertEqual(alertController.actions.first?.title, localizedString(.cancelButton, sut.localizationParameters))
        XCTAssertEqual(alertController.actions[1].title, localizedSubmitButtonTitle(with: amount, style: .immediate, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let method = try Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
        let amount = Amount(value: 3, currencyCode: "EUR")
        let sut = StoredCardAlertManager(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey(), amount: amount)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let alertController = sut.alertController
        
        XCTAssertEqual(alertController.title, localizedString(LocalizationKey(key: "adyen_card_stored_title"), sut.localizationParameters))
        let displayInformation = method.localizedDisplayInformation(using: sut.localizationParameters)
        XCTAssertEqual(alertController.message, localizedString(LocalizationKey(key: "adyen_card_stored_message"), sut.localizationParameters, displayInformation.title))
        
        XCTAssertNotNil(alertController.textFields)
        XCTAssertEqual(alertController.textFields?.count, 1)
        XCTAssertEqual(alertController.textFields?.first?.placeholder, localizedString(LocalizationKey(key: "adyen_card_cvcItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(alertController.textFields?.first?.accessibilityLabel, localizedString(LocalizationKey(key: "adyen_card_cvcItem_title"), sut.localizationParameters))
        
        XCTAssertEqual(alertController.actions.count, 2)
        XCTAssertEqual(alertController.actions.first?.title, localizedString(LocalizationKey(key: "adyen_cancelButton"), sut.localizationParameters))
        XCTAssertEqual(alertController.actions[1].title, localizedSubmitButtonTitle(with: amount, style: .immediate, sut.localizationParameters))
    }
    
}
