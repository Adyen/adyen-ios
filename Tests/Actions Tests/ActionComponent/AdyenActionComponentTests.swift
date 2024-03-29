//
// Copyright (c) 2024 Adyen N.V.
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
    
    let qrAction = """
    {
        "paymentMethodType": "upi_qr",
        "qrCodeData": "QR_CODE_DATA",
        "paymentData": ""
    }
    """
    
    let documentAction = """
    {
        "paymentMethodType": "directdebit_GB",
        "url": "https://adyen.com"
    }
    """
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

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

        try waitUntilTopPresenter(isOfType: SFSafariViewController.self)
    }

    func testAwaitAction() throws {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()

        let action = Action.await(AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik))
        sut.handle(action)
        
        let waitExpectation = expectation(description: "Expect AwaitViewController to be presented")
        
        try waitUntilTopPresenter(isOfType: AdyenActions.AwaitViewController.self)

        (sut.presentationDelegate as! UIViewController).dismiss(animated: true) {
            let topPresentedViewController = try? UIViewController.topPresenter()
            XCTAssertNil(topPresentedViewController as? AdyenActions.AwaitViewController)

            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 100, handler: nil)
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

        wait { sut.currentActionComponent is ThreeDS2Component }
    }

    func testVoucherAction() throws {
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try! JSONDecoder().decode(VoucherAction.self, from: voucherAction.data(using: .utf8)!)
        sut.handle(Action.voucher(action))
        
        let waitExpectation = expectation(description: "Expect VoucherViewController to be presented")
        let voucherViewController = try waitUntilTopPresenter(isOfType: ADYViewController.self)
        XCTAssertNotNil(voucherViewController.view as? VoucherView)
        
        let presentationDelegate = try XCTUnwrap(sut.presentationDelegate as? UIViewController)
        presentationDelegate.dismiss(animated: true) {
            XCTAssertNotEqual(voucherViewController, try? UIViewController.topPresenter())
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 100, handler: nil)
    }
    
    func testQRCodeAction() throws {

        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try! JSONDecoder().decode(QRCodeAction.self, from: qrAction.data(using: .utf8)!)
        sut.handle(Action.qrCode(action))
        
        try waitUntilTopPresenter(isOfType: QRCodeViewController.self)
    }
    
    func testDocumentAction() throws {
        // DocumentAction
        let sut = AdyenActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try! JSONDecoder().decode(DocumentAction.self, from: documentAction.data(using: .utf8)!)
        sut.handle(Action.document(action))
        
        let documentViewController = try waitUntilTopPresenter(isOfType: ADYViewController.self)
        XCTAssertNotNil(documentViewController.view as? DocumentActionView)
    }
}
