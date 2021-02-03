//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenDropIn
import XCTest

class DropInTests: XCTestCase {

    static let paymentMethods =
    """
    {
      "paymentMethods" : [
        {
          "configuration" : {
            "merchantDisplayName" : "TestMerchantCheckout",
            "merchantIdentifier" : "merchant.com.adyen.test"
          },
          "details" : [
            {
              "key" : "applePayToken",
              "type" : "applePayToken"
            }
          ],
          "name" : "Apple Pay",
          "supportsRecurring" : true,
          "type" : "applepay"
        },
        {
          "name" : "WeChat Pay",
          "type" : "wechatpaySDK"
        },
        {
          "details" : [
            {
              "items" : [],
              "key" : "issuer",
              "type" : "select"
            }
          ],
          "name" : "iDEAL",
          "supportsRecurring" : true,
          "type" : "ideal"
        },
        {
          "brands" : [ "mc", "visa" ],
          "details" : [],
          "name" : "Credit Card",
          "type" : "scheme"
        }
      ],
      "oneClickPaymentMethods" : [],
      "storedPaymentMethods" : [],
      "groups" : []
    }
    """

    static let paymentMethodsOneclick =
    """
    {
      "paymentMethods" : [
        {
          "brands" : [ "mc", "visa" ],
          "details" : [],
          "name" : "Credit Card",
          "type" : "scheme"
        }
      ],
      "oneClickPaymentMethods" : [],
      "storedPaymentMethods" : [
        {
          "expiryMonth" : "10",
          "expiryYear" : "2020",
          "id" : "8415625756263270",
          "supportedShopperInteractions" : [
            "Ecommerce",
            "ContAuth"
          ],
          "lastFour" : "1111",
          "brand" : "visa",
          "type" : "scheme",
          "holderName" : "Checkout Shopper PlaceHolder",
          "name" : "VISA"
        }
    ],
      "groups" : []
    }
    """

    var sut: DropInComponent!

    override func tearDown() {
        sut = nil
    }

    func testOpenDropInAsList() {
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.environment = .test
        config.clientKey = "SOME_CLIENT_KEY"

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, paymentMethodsConfiguration: config)
        sut.payment = Payment(amount: Payment.Amount(value: 100, currencyCode: "CNY" ), countryCode: "CN")

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let topVC = self.sut.viewController.children[0].children[0].children[0] as? ListViewController
            XCTAssertNotNil(topVC)
            XCTAssertEqual(topVC!.sections.count, 1)
            XCTAssertEqual(topVC!.sections[0].items.count, 2)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testOpenDropInAsOneclickPayment() {
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.environment = .test
        config.clientKey = "SOME_CLIENT_KEY"

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneclick.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, paymentMethodsConfiguration: config)

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            XCTAssertFalse(self.sut.viewController.children[0].children[0].children[0] is ListViewController)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

}
