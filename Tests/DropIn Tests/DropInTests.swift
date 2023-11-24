//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@testable import AdyenDropIn
import SafariServices
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
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.openAppDetector = MockOpenExternalAppDetector(didOpenExternalApp: false)
        } perform: {
            super.run()
        }
    }
    
    func testDropInStyle() throws {
        var style = DropInComponent.Style(tintColor: .brown)

        XCTAssertEqual(style.formComponent.textField.tintColor, .brown)
        XCTAssertEqual(style.navigation.tintColor, .brown)

        // MARK: Update separatorColor
        
        style.separatorColor = .yellow

        XCTAssertEqual(style.formComponent.separatorColor, .yellow)
        XCTAssertEqual(style.navigation.separatorColor, .yellow)

        style.separatorColor = .green

        /*
         In its current implementation calling `separatorColor` with multiple times with different colors
         won't have any effect. This might be unexpected but this tests confirms the current implementation detail.
         */
        XCTAssertEqual(style.formComponent.separatorColor, .yellow)
        XCTAssertEqual(style.navigation.separatorColor, .yellow)

        /*
         To be able to restore the initial behavior
         the `formComponent.separatorColor` and/or `navigation.separatorColor`
         have to be nilled out
         */
        style.formComponent.separatorColor = nil
        style.navigation.separatorColor = nil

        style.separatorColor = .green

        XCTAssertEqual(style.formComponent.separatorColor, .green)
        XCTAssertEqual(style.navigation.separatorColor, .green)
    }
    
    func testOpenDropInAsList() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)

        let topVC = try XCTUnwrap(sut.viewController.findChild(of: ListViewController.self))
        XCTAssertEqual(topVC.sections.count, 1)
        XCTAssertEqual(topVC.sections[0].items.count, 2)
    }

    func testOpenDropInAsOneClickPayment() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneClick.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)
        
        XCTAssertNil(sut.viewController.findChild(of: ListViewController.self))
    }

    func testOpenDropInWithNoOneClickPayment() throws {
        let config = DropInComponent.Configuration(allowPreselectedPaymentView: false)

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneClick.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)
        
        XCTAssertNotNil(sut.viewController.findChild(of: ListViewController.self))
    }

    func testOpenApplePay() throws {
        let config = DropInComponent.Configuration()
        config.applePay = .init(payment: Dummy.createTestApplePayPayment(), merchantIdentifier: "")

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)
        
        let topVC = try XCTUnwrap(sut.viewController.findChild(of: ListViewController.self))
        topVC.tableView(topVC.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        wait(for: .seconds(1))
        let newtopVC = try XCTUnwrap(sut.viewController.findChild(of: ADYViewController.self))
        XCTAssertEqual(newtopVC.title, "Apple Pay")
    }

    func testGiftCard() throws {
        let config = DropInComponent.Configuration()

        var paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
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
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)

        let topVC = try XCTUnwrap(sut.viewController.findChild(of: ListViewController.self))
        XCTAssertEqual(topVC.sections.count, 2)
        XCTAssertEqual(topVC.sections[0].items.count, 2)
        XCTAssertTrue(topVC.sections[0].footer!.title.contains("Select payment method for the remaining"))
    }

    func testSinglePaymentMethodSkippingPaymentList() throws {
        let config = DropInComponent.Configuration(allowsSkippingPaymentList: true)

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleNonInstant.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)
        
        presentOnRoot(sut.viewController)
        
        // presented screen is SEPA (payment list is skipped)
        let topVC = try XCTUnwrap(sut.viewController.findChild(of: SecuredViewController<FormViewController>.self))
        XCTAssertEqual(topVC.title, "SEPA Direct Debit")
    }
    
    func testSinglePaymentMethodNotSkippingPaymentList() throws {
        let config = DropInComponent.Configuration(allowsSkippingPaymentList: true)

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)
        
        presentOnRoot(sut.viewController)
        
        // presented screen should be payment list with 1 instant payment element
        let topVC = try XCTUnwrap(sut.viewController.findChild(of: ListViewController.self))
        XCTAssertEqual(topVC.sections.count, 1)
        XCTAssertEqual(topVC.sections[0].items.count, 1)
    }

    func testFinaliseIfNeededEmptyList() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)
        
        let waitExpectation = expectation(description: "Expect Drop-In to finalize")

        sut.finalizeIfNeeded(with: true) {
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDidCancelOnRedirectAction() throws {
        let config = DropInComponent.Configuration()
        
        let paymentMethodsData = try XCTUnwrap(DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8))
        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: paymentMethodsData)

        let sut = DropInComponent(
            paymentMethods: paymentMethods,
            context: Dummy.context,
            configuration: config
        )

        let delegateMock = DropInDelegateMock()
        delegateMock.didSubmitHandler = { _, _ in
            sut.handle(Dummy.redirectAction)
        }

        let waitExpectation = expectation(description: "Expect Drop-In to call didCancel")
        delegateMock.didCancelHandler = { _, _ in
            waitExpectation.fulfill()
        }
        
        delegateMock.didOpenExternalApplicationHandler = { component in
            XCTFail("didOpenExternalApplication() should not have been called")
        }

        sut.delegate = delegateMock

        presentOnRoot(sut.viewController)

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController)
        topVC.tableView(topVC.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        let safari = try waitUntilTopPresenter(isOfType: SFSafariViewController.self, timeout: 5)
        wait(for: .aMoment)

        let delegate = try XCTUnwrap(safari.delegate)
        delegate.safariViewControllerDidFinish?(safari)

        wait(for: [waitExpectation], timeout: 30)
    }
    
    func testReload() throws {
        
        let config = DropInComponent.Configuration()
        
        let paymentMethods = try JSONDecoder().decode(
            PaymentMethods.self,
            from: XCTUnwrap(DropInTests.paymentMethods.data(using: .utf8))
        )
        
        let updatedPaymentMethods = try JSONDecoder().decode(
            PaymentMethods.self,
            from: XCTUnwrap(DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8))
        )
        
        let expectation = expectation(description: "Api Client Called")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(OrderStatusResponse(
                remainingAmount: .init(value: 100, currencyCode: "EUR"),
                paymentMethods: nil
            ))
        ]
        apiClient.onExecute = {
            XCTAssertTrue($0 is OrderStatusRequest)
            expectation.fulfill()
        }
        
        let sut = DropInComponent(
            paymentMethods: paymentMethods,
            context: Dummy.context,
            configuration: config,
            apiClient: apiClient
        )
        
        try sut.reload(with: .init(pspReference: "", orderData: ""), updatedPaymentMethods)
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(sut.paymentMethods, updatedPaymentMethods)
    }
    
    func testReloadFailure() throws {
        
        let config = DropInComponent.Configuration()
        
        let paymentMethods = try JSONDecoder().decode(
            PaymentMethods.self,
            from: XCTUnwrap(DropInTests.paymentMethods.data(using: .utf8))
        )
        
        let updatedPaymentMethods = try JSONDecoder().decode(
            PaymentMethods.self,
            from: XCTUnwrap(DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8))
        )
        
        let apiClientExpectation = expectation(description: "Api Client Called")
        let failExpectation = expectation(description: "Delegate didFail Called")
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            // Returning a random error so the reload fails
            .failure(APIError(status: nil, errorCode: "", errorMessage: "", type: .internal))
        ]
        apiClient.onExecute = {
            XCTAssertTrue($0 is OrderStatusRequest)
            apiClientExpectation.fulfill()
        }
        
        let sut = DropInComponent(
            paymentMethods: paymentMethods,
            context: Dummy.context,
            configuration: config,
            apiClient: apiClient
        )
        
        let delegateMock = DropInComponentDelegateMock(
            onDidFail: { error, component in
                failExpectation.fulfill()
            })
        
        sut.delegate = delegateMock
        
        try sut.reload(with: .init(pspReference: "", orderData: ""), updatedPaymentMethods)
        
        wait(for: [apiClientExpectation, failExpectation], timeout: 10)
        
        XCTAssertEqual(sut.paymentMethods, paymentMethods) // Should still be the old paymentMethods
    }
}

extension UIViewController {

    internal func findChild<T: UIViewController>(of type: T.Type) -> T? {
        if self is T { return self as? T }
        var result: T?
        for child in self.children {
            result = result ?? child.findChild(of: T.self)
        }
        return result
    }

}
