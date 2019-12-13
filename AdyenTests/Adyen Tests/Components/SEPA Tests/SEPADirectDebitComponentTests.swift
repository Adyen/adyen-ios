//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class SEPADirectDebitComponentTests: XCTestCase {

    func testLocalization() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationTable = "AdyenUIHost"

        XCTAssertEqual(sut.nameItem.title, ADYLocalizedString("adyen.sepa.nameItem.title", "AdyenUIHost"))
        XCTAssertEqual(sut.nameItem.placeholder, ADYLocalizedString("adyen.sepa.nameItem.placeholder", "AdyenUIHost"))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, ADYLocalizedString("adyen.sepa.nameItem.invalid", "AdyenUIHost"))

        XCTAssertEqual(sut.ibanItem.title, ADYLocalizedString("adyen.sepa.ibanItem.title", "AdyenUIHost"))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, ADYLocalizedString("adyen.sepa.ibanItem.invalid", "AdyenUIHost"))

        XCTAssertEqual(sut.footerItem.title, ADYLocalizedString("adyen.sepa.consentLabel", "AdyenUIHost"))
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, "AdyenUIHost"))
    }

}
