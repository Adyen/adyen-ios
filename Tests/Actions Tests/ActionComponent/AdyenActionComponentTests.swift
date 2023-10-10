//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import AdyenWeChatPay
import SafariServices
import XCTest

class AdyenActionComponentTests: XCTestCase {

    let weChatActionResponse = """
    {
      "paymentMethodType" : "wechatpaySDK",
      "paymentData" : "x",
      "type" : "sdk",
      "sdkData" : {
        "timestamp" : "x",
        "partnerid" : "x",
        "noncestr" : "x",
        "packageValue" : "Sign=WXPay",
        "sign" : "x",
        "appid" : "x",
        "prepayid" : "x"
      }
    }
    """

    let threeDSFingerprintAction = """
    {
      "token" : "x",
      "type" : "threeDS2",
      "authorisationToken" : "x",
      "subtype" : "fingerprint"
    }
    """

    let voucherAction = """
    {
      "reference" : "0",
      "initialAmount" : {
        "currency" : "IDR",
        "value" : 17408
      },
      "paymentMethodType" : "doku_alfamart",
      "instructionsUrl" : "x",
      "shopperEmail" : "x",
      "totalAmount" : {
        "currency" : "IDR",
        "value" : 17408
      },
      "expiresAt" : "2025-01-01T23:52:00",
      "merchantName" : "x",
      "shopperName" : "x",
      "type" : "voucher"
    }
    """

    func testRedirectToHttpWebLink() {
        let sut = AdyenActionComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.presentationDelegate = UIViewController.findTopPresenter()
        sut.delegate = delegate

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
        sut.handle(action)

        wait(for: .seconds(2))

        let topPresentedViewController = UIViewController.findTopPresenter()
        XCTAssertNotNil(topPresentedViewController as? SFSafariViewController)
    }

    func testAwaitAction() {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = UIViewController.findTopPresenter()

        let action = Action.await(AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik))
        sut.handle(action)
        
        wait(for: .seconds(2))
        
        let waitExpectation = expectation(description: "Expect AwaitViewController to be presented")
        
        let topPresentedViewController = UIViewController.findTopPresenter()
        XCTAssertNotNil(topPresentedViewController as? AdyenActions.AwaitViewController)

        (sut.presentationDelegate as! UIViewController).dismiss(animated: true) {
            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNil(topPresentedViewController as? AdyenActions.AwaitViewController)

            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testWeChatAction() {
        let sut = AdyenActionComponent(context: Dummy.context)

        let expectation = expectation(description: "Assertion Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertNil(sut.currentActionComponent)
            XCTAssertEqual(message, "WeChatPaySDKActionComponent can only work on a real device.")
            expectation.fulfill()
        }

        let sdkAction = try! JSONDecoder().decode(SDKAction.self, from: weChatActionResponse.data(using: .utf8)!)
        sut.handle(Action.sdk(sdkAction))

        waitForExpectations(timeout: 15, handler: nil)
    }

    func test3DSAction() {
        let sut = AdyenActionComponent(context: Dummy.context)
        let action = try! JSONDecoder().decode(ThreeDS2Action.self, from: threeDSFingerprintAction.data(using: .utf8)!)
        sut.handle(Action.threeDS2(action))

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            XCTAssertNotNil(sut.currentActionComponent as? ThreeDS2Component)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testVoucherAction() {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = UIViewController.findTopPresenter()
        
        let action = try! JSONDecoder().decode(VoucherAction.self, from: voucherAction.data(using: .utf8)!)
        sut.handle(Action.voucher(action))
        
        wait(for: .seconds(2))
        
        let waitExpectation = expectation(description: "Expect VoucherViewController to be presented")
        let topPresentedViewController = UIViewController.findTopPresenter()
        XCTAssertNotNil(topPresentedViewController?.view as? VoucherView)

        (sut.presentationDelegate as! UIViewController).dismiss(animated: true) {
            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNil(topPresentedViewController as? VoucherViewController)

            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension UIViewController: PresentationDelegate {
    public func present(component: PresentableComponent) {
        self.present(component.viewController, animated: true, completion: nil)
    }
}
