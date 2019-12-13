//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//


import XCTest
@testable import AdyenDropIn

class StoredPaymentMethodComponentTests: XCTestCase {

    func testLocalization() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: "test_type", name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method)
        let payment = Payment(amount: Payment.Amount(value: 34, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment
        sut.localizationTable = "AdyenUIHost"

        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, ADYLocalizedString("adyen.cancelButton", "AdyenUIHost"))
        XCTAssertEqual(viewController?.actions.last?.title, ADYLocalizedSubmitButtonTitle(with: payment.amount, "AdyenUIHost"))
    }

}
