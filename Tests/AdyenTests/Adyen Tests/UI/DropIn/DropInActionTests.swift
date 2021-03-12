//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenDropIn
import SafariServices
import XCTest

class DropInActionsTests: XCTestCase {

    var sut: DropInComponent!

    override func tearDown() {
        sut = nil
    }

    func testOpenRedirectAcitionOnDropIn() {
        let config = DropInComponent.PaymentMethodsConfiguration(clientKey: Dummy.dummyClientKey)
        config.payment = Payment(amount: Payment.Amount(value: 100, currencyCode: "CNY"), countryCode: "CN")

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, paymentMethodsConfiguration: config)
        sut.environment = .test

        let waitExpectation = expectation(description: "Expect SafariViewController to open")
        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: {
            let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
            self.sut.handle(action)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                XCTAssertNotNil(self.sut.viewController.adyen.topPresenter as? SFSafariViewController)
                waitExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 15, handler: nil)
    }

}
