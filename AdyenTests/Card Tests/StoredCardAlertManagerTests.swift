//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import AdyenCard

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

    func testLocalization() throws {
        let method = try Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
        let amount = Payment.Amount(value: 3, currencyCode: "EUR")
        let sut = StoredCardAlertManager(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey(), amount: amount)
        sut.localizationTable = "AdyenUIHost"

        let alertController = sut.alertController

        XCTAssertEqual(alertController.title, ADYLocalizedString("adyen.card.stored.title", "AdyenUIHost"))
        let displayInformation = method.localizedDisplayInformation(usingTableName: "AdyenUIHost")
        XCTAssertEqual(alertController.message, ADYLocalizedString("adyen.card.stored.message", "AdyenUIHost", displayInformation.title))

        XCTAssertNotNil(alertController.textFields)
        XCTAssertEqual(alertController.textFields?.count, 1)
        XCTAssertEqual(alertController.textFields?.first?.placeholder, ADYLocalizedString("adyen.card.cvcItem.placeholder", "AdyenUIHost"))
        XCTAssertEqual(alertController.textFields?.first?.accessibilityLabel, ADYLocalizedString("adyen.card.cvcItem.title", "AdyenUIHost"))

        XCTAssertEqual(alertController.actions.count, 2)
        XCTAssertEqual(alertController.actions.first?.title, ADYLocalizedString("adyen.cancelButton", "AdyenUIHost"))
        XCTAssertEqual(alertController.actions[1].title, ADYLocalizedSubmitButtonTitle(with: amount, "AdyenUIHost"))
    }

}
