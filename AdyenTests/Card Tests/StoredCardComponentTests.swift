//
//  StoredCardComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/17/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenCard
@testable import Adyen

class StoredCardComponentTests: XCTestCase {

    func testUI() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = "client_key"

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedString("adyen.cancelButton", nil) } )
            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) } )

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

}
