//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import SafariServices
import XCTest

// TODO: DropInComponent tests need be rewritten pretty much from scratch.
// TODO: All the logic being tested here will be splitted among the different drop-in modules.
class DropInTests: XCTestCase {
    ///
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
                "brands" : [
                  "maestro",
                  "amex",
                  "discover",
                  "eftpos_australia",
                  "elo",
                  "jcb",
                  "mc",
                  "sodexo",
                  "visa"
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
              "name" : "Online Banking",
              "supportsRecurring" : true,
              "type" : "onlineBanking_PL"
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
//
//    override func run() {
//        AdyenDependencyValues.runTestWithValues {
//            $0.openAppDetector = MockOpenExternalAppDetector(didOpenExternalApp: false)
//            $0.imageLoader = ImageLoaderMock()
//        } perform: {
//            super.run()
//        }
//    }
//
//    func testViewDidLoadShouldSendRenderCall() throws {
//        // Given
//        let analyticsProviderMock = AnalyticsProviderMock()
//        let context = Dummy.context(with: analyticsProviderMock)
//        let config = DropInComponent.Configuration(allowPreselectedPaymentView: false)
//
//        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsOneClick.data(using: .utf8)!)
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: context,
//            configuration: config
//        )
//
//        // When
//        sut.sendDidLoadEvent()
//
//        // Then
//        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
//
//        let info = analyticsProviderMock.infos.first
//        XCTAssertEqual(info?.type, .rendered)
//
//        let configDataDict = try XCTUnwrap(info?.configData?.stringOnlyDictionary)
//        XCTAssertNotNil(configDataDict)
//        XCTAssertEqual(configDataDict["skipPaymentMethodList"], "false")
//        XCTAssertEqual(configDataDict["openFirstStoredPaymentMethod"], "false")
//        XCTAssertEqual(configDataDict.keys.count, 2)
//    }
//
//
//
//    func testDeletingStoredPaymentSuccessWithSession() throws {
//        let config = DropInComponent.Configuration()
//        config.allowPreselectedPaymentView = false
//
//        var paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
//        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
//        paymentMethods.stored = [storedPaymentMethod]
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        let storedPaymentMethodsDelegate = SessionStoredPaymentMethodDelegateMock()
//        storedPaymentMethodsDelegate.onDisable = { storedPM, dropIn in
//            XCTAssertEqual(storedPM.identifier, storedPaymentMethod.identifier)
//            XCTAssertEqual(dropIn as! DropInComponent, sut)
//            return true
//        }
//        sut.storedPaymentMethodsDelegate = storedPaymentMethodsDelegate
//        XCTAssertNotNil(sut.sessionAsStoredPaymentMethodsDelegate)
//
//        let expectation = expectation(description: "deletion delegate should be called")
//        let paymentMethodsListComponent = sut.resolvePaymentMethodListViewModel(onCancel: nil)
//
//        sut.didDelete(storedPaymentMethod, in: paymentMethodsListComponent) { success in
//            XCTAssertEqual(storedPaymentMethodsDelegate.onDisableCallCount, 1)
//            XCTAssertTrue(success)
//            XCTAssertTrue(sut.paymentMethods.stored.isEmpty)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 2)
//    }
//
//    func testDeletingStoredPaymentFailureWithSession() throws {
//        let config = DropInComponent.Configuration()
//        config.allowPreselectedPaymentView = false
//
//        var paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
//        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
//        paymentMethods.stored = [storedPaymentMethod]
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        let storedPaymentMethodsDelegate = SessionStoredPaymentMethodDelegateMock()
//        storedPaymentMethodsDelegate.onDisable = { storedPM, dropIn in
//            XCTAssertEqual(storedPM.identifier, storedPaymentMethod.identifier)
//            return false
//        }
//        sut.storedPaymentMethodsDelegate = storedPaymentMethodsDelegate
//        XCTAssertNotNil(sut.sessionAsStoredPaymentMethodsDelegate)
//
//        let expectation = expectation(description: "deletion delegate should be called")
//        let paymentMethodsListComponent = sut.resolvePaymentMethodListViewModel(onCancel: nil)
//
//        sut.didDelete(storedPaymentMethod, in: paymentMethodsListComponent) { success in
//            XCTAssertEqual(storedPaymentMethodsDelegate.onDisableCallCount, 1)
//            XCTAssertFalse(success)
//            XCTAssertFalse(sut.paymentMethods.stored.isEmpty)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 2)
//    }
//
//    func testDeletingStoredPaymentSuccessAdvanced() throws {
//        let config = DropInComponent.Configuration()
//        config.allowPreselectedPaymentView = false
//
//        var paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
//        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
//        paymentMethods.stored = [storedPaymentMethod]
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        let storedPaymentMethodsDelegate = StoredPaymentMethodDelegateMock()
//        storedPaymentMethodsDelegate.onDisable = { storedPM in
//            XCTAssertEqual(storedPM.identifier, storedPaymentMethod.identifier)
//            return true
//        }
//        sut.storedPaymentMethodsDelegate = storedPaymentMethodsDelegate
//        XCTAssertNil(sut.sessionAsStoredPaymentMethodsDelegate)
//
//        let expectation = expectation(description: "deletion delegate should be called")
//        let paymentMethodsListComponent = sut.resolvePaymentMethodListViewModel(onCancel: nil)
//
//        sut.didDelete(storedPaymentMethod, in: paymentMethodsListComponent) { success in
//            XCTAssertEqual(storedPaymentMethodsDelegate.onDisableCallCount, 1)
//            XCTAssertTrue(success)
//            XCTAssertTrue(sut.paymentMethods.stored.isEmpty)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 2)
//    }
//
//    func testDeletingStoredPaymentFailureAdvanced() throws {
//        let config = DropInComponent.Configuration()
//        config.allowPreselectedPaymentView = false
//
//        var paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
//        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
//        paymentMethods.stored = [storedPaymentMethod]
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        let storedPaymentMethodsDelegate = StoredPaymentMethodDelegateMock()
//        storedPaymentMethodsDelegate.onDisable = { storedPM in
//            XCTAssertEqual(storedPM.identifier, storedPaymentMethod.identifier)
//            return false
//        }
//        sut.storedPaymentMethodsDelegate = storedPaymentMethodsDelegate
//        XCTAssertNil(sut.sessionAsStoredPaymentMethodsDelegate)
//
//        let expectation = expectation(description: "deletion delegate should be called")
//        let paymentMethodsListComponent = sut.resolvePaymentMethodListViewModel(onCancel: nil)
//
//        sut.didDelete(storedPaymentMethod, in: paymentMethodsListComponent) { success in
//            XCTAssertEqual(storedPaymentMethodsDelegate.onDisableCallCount, 1)
//            XCTAssertFalse(success)
//            XCTAssertFalse(sut.paymentMethods.stored.isEmpty)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 2)
//    }
//
//
//    func testFinaliseIfNeededEmptyList() throws {
//        let config = DropInComponent.Configuration()
//
//        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        presentOnRoot(sut.viewController)
//
//        let waitExpectation = expectation(description: "Expect Drop-In to finalize")
//
//        sut.finalizeIfNeeded(with: true) {
//            waitExpectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//
//    func testDidCancelOnRedirectAction() throws {
//        let config = DropInComponent.Configuration()
//
//        let paymentMethodsData = try XCTUnwrap(DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8))
//        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: paymentMethodsData)
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: config
//        )
//
//        let delegateMock = DropInDelegateMock()
//        delegateMock.didSubmitHandler = { _, _ in
//            sut.handle(Dummy.redirectAction)
//        }
//
//        let waitExpectation = expectation(description: "Expect Drop-In to call didCancel")
//        delegateMock.didCancelHandler = { _, _ in
//            waitExpectation.fulfill()
//        }
//
//        delegateMock.didOpenExternalApplicationHandler = { component in
//            XCTFail("didOpenExternalApplication() should not have been called")
//        }
//
//        sut.delegate = delegateMock
//
//        presentOnRoot(sut.viewController)
//
//        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController)
//        topVC.tableView(topVC.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
//
//        let safari = try waitUntilTopPresenter(isOfType: SFSafariViewController.self, timeout: 10)
//        wait(for: .aMoment)
//
//        let delegate = try XCTUnwrap(safari.delegate)
//        delegate.safariViewControllerDidFinish?(safari)
//
//        wait(for: [waitExpectation], timeout: 30)
//    }
//
//    func testDidSelectWithInitiableComponentShouldInitiatePayment() throws {
//        // Given
//        let configuration = DropInComponent.Configuration()
//
//        let paymentMethodsData = try XCTUnwrap(DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8))
//        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: paymentMethodsData)
//
//        let sut = DropInComponent(
//            paymentMethods: paymentMethods,
//            context: Dummy.context,
//            configuration: configuration
//        )
//
//        // When
//        let paymentMethod = PaymentMethodMock(type: .twint, name: "Twint")
//        let initiableComponentMock = InitiableComponentMock(paymentMethod: paymentMethod)
//        sut.didSelect(initiableComponentMock)
//
//        // Then
//        XCTAssertEqual(initiableComponentMock.initiatePaymentCallsCount, 1)
//    }
//
}

//
// extension UIViewController {
//
//    internal func findChild<T: UIViewController>(of type: T.Type) -> T? {
//        if self is T { return self as? T }
//        var result: T?
//        for child in self.children {
//            result = result ?? child.findChild(of: T.self)
//        }
//        return result
//    }
//
// }
