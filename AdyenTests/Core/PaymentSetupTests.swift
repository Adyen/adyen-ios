//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentSetupTests: XCTestCase {
    
    func testDecoding() {
        let data = JsonReader.readData(fileName: "PaymentSetup")
        let paymentSetup = PaymentSetup(data: data)!
        XCTAssertEqual(paymentSetup.amount, 17408)
        XCTAssertEqual(paymentSetup.currencyCode, "EUR")
        XCTAssertEqual(paymentSetup.countryCode, "NL")
        XCTAssertEqual(paymentSetup.merchantReference, "iOS & M+M Black dress & accessories")
        XCTAssertEqual(paymentSetup.shopperReference, "shopper@company.com")
        XCTAssertEqual(paymentSetup.shopperLocaleIdentifier, "NL")
        XCTAssertEqual(paymentSetup.preferredPaymentMethods.count, 6)
        XCTAssertEqual(paymentSetup.availablePaymentMethods.count, 6)
        XCTAssertEqual(paymentSetup.logoBaseURL.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/img/pm/")
        XCTAssertEqual(paymentSetup.initiationURL.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/services/PaymentInitiation/v1/initiate")
        XCTAssertEqual(paymentSetup.deletePreferredPaymentMethodURL.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/services/PaymentInitiation/v1/disableRecurringDetail")
        XCTAssertEqual(paymentSetup.generationDateString, "2017-07-11T07:17:11Z")
        XCTAssertEqual(paymentSetup.publicKey, "publicKey")
        XCTAssertEqual(paymentSetup.paymentData, "data")
    }
    
}
