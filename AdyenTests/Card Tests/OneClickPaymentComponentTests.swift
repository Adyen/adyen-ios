//
//  OneClickPaymentComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/2/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class OneClickPaymentComponentTests: XCTestCase {

    func testUI() {
        let method = StoredPaymentMethodMock(identifier: "id",
                                             supportedShopperInteractions: [.shopperPresent],
                                             type: "type",
                                             name: "name")
        let sut = OneClickPaymentComponent(paymentMethod: method)
        sut.clientKey = "client_key"

        let delegate = PaymentComponentDelegateMock()

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? StoredPaymentDetails)

            let details = data.paymentMethod as! StoredPaymentDetails
            XCTAssertEqual(details.type, "type")
            XCTAssertEqual(details.storedPaymentMethodIdentifier, "id")

            delegateExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        sut.delegate = delegate

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let uiExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController

            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedString("adyen.cancelButton", nil) })
            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) })

            let payAction = alertController.actions.first { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) }!

            payAction.tap()

            uiExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

}
