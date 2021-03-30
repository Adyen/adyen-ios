//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenDropIn)
import AdyenDropIn
#endif
import XCTest

class DropInTests: XCTestCase {

    static let paymentMethods =
        """
        {
          "paymentMethods" : [
            {
              "configuration" : {
                "merchantDisplayName" : "TheMerchant",
                "merchantIdentifier" : "merchant.com.mycompany.test"
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
              "id" : "123412341234",
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
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.payment = Payment(amount: Amount(value: 100, currencyCode: "CNY"), countryCode: "CN")

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, configuration: config)

        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let topVC = self.sut.viewController.findChild(of: ListViewController.self)
            XCTAssertNotNil(topVC)
            XCTAssertEqual(topVC!.sections.count, 1)
            XCTAssertEqual(topVC!.sections[0].items.count, 2)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testOpenDropInAsOneclickPayment() {
        let config = DropInComponent.Configuration(apiContext: Dummy.context)

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneclick.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, configuration: config)

        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            XCTAssertNil(self.sut.viewController.findChild(of: ListViewController.self))
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testOpenApplePay() {
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.applePay = .init(summaryItems: [.init(label: "Item", amount: 100)], merchantIdentifier: "")
        config.payment = .init(amount: .init(value: 100, currencyCode: "EUR"), countryCode: "NL")

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods, configuration: config)

        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let topVC = self.sut.viewController.findChild(of: ListViewController.self)
            topVC?.tableView(topVC!.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                let topVC = self.sut.viewController.findChild(of: ADYViewController.self)
                XCTAssertEqual(topVC?.title, "Apple Pay")
                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testGiftCard() {
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.payment = Payment(amount: Amount(value: 10000, currencyCode: "CNY"), countryCode: "CN")

        var paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        paymentMethods.paid = [
            OrderPaymentMethod(lastFour: "1234",
                               type: "type-1",
                               transactionLimit: Amount(value: 2000, currencyCode: "CNY"),
                               amount: Amount(value: 2000, currencyCode: "CNY")),
            OrderPaymentMethod(lastFour: "1234",
                               type: "type-2",
                               transactionLimit: Amount(value: 3000, currencyCode: "CNY"),
                               amount: Amount(value: 3000, currencyCode: "CNY"))
        ]
        sut = DropInComponent(paymentMethods: paymentMethods, configuration: config)

        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect DropIn to open")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let topVC = self.sut.viewController.findChild(of: ListViewController.self)
            XCTAssertNotNil(topVC)
            XCTAssertEqual(topVC!.sections.count, 2)
            XCTAssertEqual(topVC!.sections[0].items.count, 2)
            XCTAssertTrue(topVC!.sections[0].footer!.title.contains("Select payment method for the remaining amount"))
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

}

extension UIViewController {

    fileprivate func findChild<T: UIViewController>(of type: T.Type) -> T? {
        if self is T { return self as? T }
        var result: T?
        for child in self.children {
            result = result ?? child.findChild(of: T.self)
        }
        return result
    }

}
