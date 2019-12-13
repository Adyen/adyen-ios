//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import AdyenCard

class CardComponentTests: XCTestCase {

    func testLocalization() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        let sut = CardComponent(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey())
        sut.payment = payment
        sut.localizationTable = "AdyenUIHost"
        sut.showsHolderNameField = true

        XCTAssertEqual(sut.expiryDateItem.title, ADYLocalizedString("adyen.card.expiryItem.title", "AdyenUIHost"))
        XCTAssertEqual(sut.expiryDateItem.placeholder, ADYLocalizedString("adyen.card.expiryItem.placeholder", "AdyenUIHost"))
        XCTAssertEqual(sut.expiryDateItem.validationFailureMessage, ADYLocalizedString("adyen.card.expiryItem.invalid", "AdyenUIHost"))

        XCTAssertEqual(sut.securityCodeItem.title, ADYLocalizedString("adyen.card.cvcItem.title", "AdyenUIHost"))
        XCTAssertEqual(sut.securityCodeItem.placeholder, ADYLocalizedString("adyen.card.cvcItem.placeholder", "AdyenUIHost"))
        XCTAssertEqual(sut.securityCodeItem.validationFailureMessage, ADYLocalizedString("adyen.card.cvcItem.invalid", "AdyenUIHost"))

        XCTAssertEqual(sut.holderNameItem?.title, ADYLocalizedString("adyen.card.nameItem.title", "AdyenUIHost"))
        XCTAssertEqual(sut.holderNameItem?.placeholder, ADYLocalizedString("adyen.card.nameItem.placeholder", "AdyenUIHost"))
        XCTAssertEqual(sut.holderNameItem?.validationFailureMessage, ADYLocalizedString("adyen.card.nameItem.invalid", "AdyenUIHost"))

        XCTAssertEqual(sut.storeDetailsItem?.title, ADYLocalizedString("adyen.card.storeDetailsButton", "AdyenUIHost"))

        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, "AdyenUIHost"))
    }

}
