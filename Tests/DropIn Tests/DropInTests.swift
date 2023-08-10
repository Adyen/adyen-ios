//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenDropIn
import XCTest

class DropInTests: XCTestCase {

    static let paymentMethods =
        """
        {
          "paymentMethods" : [
            {
              "configuration" : {
                "merchantDisplayName" : "TheMerchant",
                "merchantIdentifier" : "merchant.com.myCompany.test"
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

    static let paymentMethodsOneClick =
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
    
    static let paymentMethodsWithSingleInstant =
        """
        {
          "paymentMethods" : [
            {
              "name" : "Paysafecard",
              "type" : "paysafecard"
            }
          ],
          "oneClickPaymentMethods" : [],
          "storedPaymentMethods" : [],
          "groups" : []
        }
        """
    
    static let paymentMethodsWithSingleNonInstant =
        """
        {
          "paymentMethods" : [
            {
              "name" : "SEPA Direct Debit",
              "type" : "sepadirectdebit"
            }
          ],
          "oneClickPaymentMethods" : [],
          "storedPaymentMethods" : [],
          "groups" : []
        }
        """

    var sut: DropInComponent!
    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        sut = nil
        context = nil
        try super.tearDownWithError()
    }

    func testOpenDropInAsList() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        XCTAssertEqual(topVC.sections.count, 1)
        XCTAssertEqual(topVC.sections[0].items.count, 2)
    }

    func testOpenDropInAsOneClickPayment() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneClick.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        wait(for: .seconds(1))
        
        XCTAssertNil(self.sut.viewController.firstChild(of: ListViewController.self))
    }

    func testOpenDropInWithNoOneClickPayment() throws {
        let config = DropInComponent.Configuration(allowPreselectedPaymentView: false)

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneClick.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
    }

    func testOpenApplePay() throws {
        let config = DropInComponent.Configuration()
        config.applePay = .init(payment: Dummy.createTestApplePayPayment(), merchantIdentifier: "")

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        topVC.tableView(topVC.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        let newtopVC = try waitForViewController(ofType: ADYViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        XCTAssertEqual(newtopVC.title, "Apple Pay")
    }

    func testGiftCard() throws {
        let config = DropInComponent.Configuration()

        var paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        paymentMethods.paid = [
            OrderPaymentMethod(lastFour: "1234",
                               type: .card,
                               transactionLimit: Amount(value: 2000, currencyCode: "CNY"),
                               amount: Amount(value: 2000, currencyCode: "CNY")),
            OrderPaymentMethod(lastFour: "1234",
                               type: .bcmcMobile,
                               transactionLimit: Amount(value: 3000, currencyCode: "CNY"),
                               amount: Amount(value: 3000, currencyCode: "CNY"))
        ]
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        XCTAssertEqual(topVC.sections.count, 2)
        XCTAssertEqual(topVC.sections[0].items.count, 2)
        XCTAssertTrue(topVC.sections[0].footer!.title.contains("Select payment method for the remaining"))
    }

    func testSinglePaymentMethodSkippingPaymentList() throws {
        let config = DropInComponent.Configuration(allowsSkippingPaymentList: true)

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleNonInstant.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)
        
        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)
        
        // presented screen is SEPA (payment list is skipped)
        let topVC = try waitForViewController(ofType: SecuredViewController<FormViewController>.self, toBecomeChildOf: sut.viewController, timeout: 1)
        XCTAssertEqual(topVC.title, "SEPA Direct Debit")
    }
    
    func testSinglePaymentMethodNotSkippingPaymentList() throws {
        let config = DropInComponent.Configuration(allowsSkippingPaymentList: true)

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)
        
        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)
        
        // presented screen should be payment list with 1 instant payment element
        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        XCTAssertEqual(topVC.sections.count, 1)
        XCTAssertEqual(topVC.sections[0].items.count, 1)
    }

    func testFinaliseIfNeededEmptyList() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods, context: Dummy.context, configuration: config)

        let root = UIViewController()
        try setupRootViewController(root)
        root.present(sut.viewController, animated: true, completion: nil)

        let waitExpectation = expectation(description: "Expect Drop-In to finalize")

        wait(for: .seconds(1))
        sut.finalizeIfNeeded(with: true) {
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
