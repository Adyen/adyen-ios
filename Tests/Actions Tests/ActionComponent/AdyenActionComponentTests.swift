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

    func testRedirectToHttpWebLink() throws {
        let sut = AdyenActionComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.presentationDelegate = try UIViewController.topPresenter()
        sut.delegate = delegate

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
        sut.handle(action)
        
        try waitUntilTopPresenter(isOfType: SFSafariViewController.self, timeout: 2)
    }

    func testAwaitAction() throws {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()

        let action = Action.await(AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik))
        sut.handle(action)
        
        let waitExpectation = expectation(description: "Expect AwaitViewController to be presented")
        
        try waitUntilTopPresenter(isOfType: AdyenActions.AwaitViewController.self, timeout: 2)
        
        let presentingViewController = try XCTUnwrap(sut.presentationDelegate as? UIViewController)
        presentingViewController.dismiss(animated: true) {

            self.wait(
                until: { (try? UIViewController.topPresenter() is AdyenActions.AwaitViewController) == false },
                timeout: 2
            )
            
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

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test3DSAction() {
        let sut = AdyenActionComponent(context: Dummy.context)
        let action = try! JSONDecoder().decode(ThreeDS2Action.self, from: threeDSFingerprintAction.data(using: .utf8)!)
        sut.handle(Action.threeDS2(action))

        wait(
            until: { sut.currentActionComponent is ThreeDS2Component },
            timeout: 2
        )
    }

    func testVoucherAction() throws {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try! JSONDecoder().decode(VoucherAction.self, from: voucherAction.data(using: .utf8)!)
        sut.handle(Action.voucher(action))
        
        self.wait(
            until: { (try? UIViewController.topPresenter())?.view is VoucherView },
            timeout: 2,
            message: "Top presenter view should be VoucherView"
        )

        let waitExpectation = expectation(description: "Expect VoucherViewController to be presented")
        (sut.presentationDelegate as! UIViewController).dismiss(animated: true) {

            self.wait(
                until: { ((try? UIViewController.topPresenter())?.view is VoucherView) == false },
                timeout: 2
            )

            waitExpectation.fulfill()
        }

        wait(for: [waitExpectation], timeout: 10)
    }
}

extension UIViewController: PresentationDelegate {
    public func present(component: PresentableComponent) {
        self.present(component.viewController, animated: true, completion: nil)
    }
}
