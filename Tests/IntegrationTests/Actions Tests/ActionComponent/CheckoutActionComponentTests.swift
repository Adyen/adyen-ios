//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenUI
import SafariServices
import XCTest

#if canImport(AdyenTwint)
    import AdyenTwint
#endif

class CheckoutActionComponentTests: XCTestCase {

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
    
    let twintAction = """
    {
        "paymentMethodType": "twint",
        "paymentData": "",
        "type": "sdk",
        "sdkData": {
            "token": "",
            "isStored": "false"
        }
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
        let sut = CheckoutActionComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.presentationDelegate = try UIViewController.topPresenter()
        sut.delegate = delegate

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = try Action.redirect(RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "test_data"))
        sut.handle(action)

        try waitUntilTopPresenter(isOfType: SFSafariViewController.self)
    }

    func testAwaitAction() throws {
        let sut = CheckoutActionComponent(context: Dummy.context)
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
    
    func testRedirectableAwaitAction() throws {
        let expectedRedirectUrl = try XCTUnwrap(URL(string: "https://adyen.com"))
        let expectedAppLaunch = expectation(description: "`AppLauncher.openCustomSchemeUrl` was called")
        
        let mockAppLauncher = AppLauncherMock()
        mockAppLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTAssertEqual(expectedRedirectUrl, url)
            expectedAppLaunch.fulfill()
            completion?(true)
        }
        
        let sut = CheckoutActionComponent(context: Dummy.context)
        sut.appLauncher = mockAppLauncher
        
        sut.presentationDelegate = try UIViewController.topPresenter()
        let action = Action.redirectableAwait(
            RedirectableAwaitAction(
                paymentData: "SOME_DATA",
                paymentMethodType: .upiIntent,
                url: expectedRedirectUrl
            )
        )
        
        sut.handle(action)
        
        let waitExpectation = expectation(description: "Expect AwaitViewController to be presented")
        
        try waitUntilTopPresenter(isOfType: AdyenActions.AwaitViewController.self)

        try XCTUnwrap(sut.presentationDelegate as? UIViewController).dismiss(animated: true) {
            let topPresentedViewController = try? UIViewController.topPresenter()
            XCTAssertNil(topPresentedViewController as? AdyenActions.AwaitViewController)

            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func testWeChatAction() throws {
        let sut = CheckoutActionComponent(context: Dummy.context)

        let expectation = expectation(description: "Assertion Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertNil(sut.currentActionComponent)
            XCTAssertEqual(message, "WeChatPaySDKActionComponent can only work on a real device.")
            expectation.fulfill()
        }

        let sdkAction = try JSONDecoder().decode(SDKAction.self, from: XCTUnwrap(weChatActionResponse.data(using: .utf8)))
        sut.handle(Action.sdk(sdkAction))

        waitForExpectations(timeout: 15, handler: nil)
    }

    func test3DSAction() throws {
        let sut = CheckoutActionComponent(context: Dummy.context)
        let action = try JSONDecoder().decode(ThreeDS2Action.self, from: XCTUnwrap(threeDSFingerprintAction.data(using: .utf8)))
        sut.handle(Action.threeDS2(action))

        wait { sut.currentActionComponent is ThreeDS2Component }
    }

    func testVoucherAction() throws {
        let sut = CheckoutActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try JSONDecoder().decode(VoucherAction.self, from: XCTUnwrap(voucherAction.data(using: .utf8)))
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

        let sut = CheckoutActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try JSONDecoder().decode(QRCodeAction.self, from: XCTUnwrap(qrAction.data(using: .utf8)))
        sut.handle(Action.qrCode(action))
        
        try waitUntilTopPresenter(isOfType: QRCodeViewController.self)
    }
    
    func testDocumentAction() throws {
        // DocumentAction
        let sut = CheckoutActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let action = try JSONDecoder().decode(DocumentAction.self, from: XCTUnwrap(documentAction.data(using: .utf8)))
        sut.handle(Action.document(action))
        
        let documentViewController = try waitUntilTopPresenter(isOfType: ADYViewController.self)
        XCTAssertNotNil(documentViewController.view as? DocumentActionView)
    }
    
    func testTwintAction() throws {
        
        let sut = CheckoutActionComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        
        let assertionExpectation = expectation(description: "Should Assert if no Twint configuration is provided")
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "Twint action configuration instance must not be nil in order to use AdyenTwint")
            assertionExpectation.fulfill()
        }
        
        let action = try JSONDecoder().decode(TwintSDKAction.self, from: XCTUnwrap(twintAction.data(using: .utf8)))
        sut.handle(Action.sdk(.twint(action)))
        
        wait(for: [assertionExpectation], timeout: 0.1)
        
        AdyenAssertion.listener = nil
        
        let expectedCallbackAppScheme = "ui-host"
        sut.configuration.twint = .init(callbackAppScheme: expectedCallbackAppScheme)
        sut.handle(Action.sdk(.twint(action)))
        
        #if canImport(TwintSDK)
            let twintComponent = try XCTUnwrap(sut.currentActionComponent as? TwintSDKActionComponent)
            XCTAssertEqual(twintComponent.configuration.callbackAppScheme, expectedCallbackAppScheme)
        #endif
    }
    
    func testTwintActionConfiguration() {
        
        let validSchemes = ["scheme"]
        
        let invalidSchemes = [
            "scheme:",
            "scheme://",
            "scheme://host"
        ]
        
        // Valid Configuration
        
        validSchemes.forEach { scheme in
            AdyenAssertion.listener = { message in
                XCTFail("No assertion should have been raised")
            }
            
            _ = TwintActionConfiguration(callbackAppScheme: scheme)
        }
        
        // Invalid Configuration
        
        invalidSchemes.forEach { scheme in
            AdyenAssertion.listener = { message in
                XCTAssertEqual(message, "Format of provided callbackAppScheme '\(scheme)' is incorrect.")
            }
            
            _ = TwintActionConfiguration(callbackAppScheme: scheme)
        }
    }
    
    func testHandleRedirectEvent() throws {
        let redirectAction = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "test_data")
        testEvent(for: Action.redirect(redirectAction))
    }
    
    func testHandleAwaitActionEvent() {
        let awaitAction = AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik)
        testEvent(for: Action.await(awaitAction))
    }
    
    func testHandleSDKActionEvent() throws {
        let sdkAction = try JSONDecoder().decode(SDKAction.self, from: XCTUnwrap(weChatActionResponse.data(using: .utf8)))
        testEvent(for: Action.sdk(sdkAction))
    }
    
    func testHandleThreeDSEvent() throws {
        let threeDSAction = try JSONDecoder().decode(ThreeDS2Action.self, from: XCTUnwrap(threeDSFingerprintAction.data(using: .utf8)))
        testEvent(for: Action.threeDS2(threeDSAction))
    }
    
    func testHandleVoucherEvent() throws {
        let voucherAction = try JSONDecoder().decode(VoucherAction.self, from: XCTUnwrap(voucherAction.data(using: .utf8)))
        testEvent(for: Action.voucher(voucherAction))
    }
    
    func testQRCodeActionEvent() throws {
        let qrCodeAction = try JSONDecoder().decode(QRCodeAction.self, from: XCTUnwrap(qrAction.data(using: .utf8)))
        testEvent(for: Action.qrCode(qrCodeAction))
    }
    
    func testDocumentActionEvent() throws {
        let documentAction = try JSONDecoder().decode(DocumentAction.self, from: XCTUnwrap(documentAction.data(using: .utf8)))
        testEvent(for: Action.document(documentAction))
    }
    
    private func testEvent(for action: Action) {
        
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = CheckoutActionComponent(context: Dummy.context(analyticsProvider: analyticsProviderMock))
        
        sut.handle(action)
        
        let event = analyticsProviderMock.logs[0]
        XCTAssertEqual(event.type, .action)
        
        switch action {
        case .redirect:
            XCTAssertEqual(event.component, "redirect")
        case .sdk:
            XCTAssertEqual(event.component, "sdk")
        case .threeDS2Fingerprint:
            XCTAssertEqual(event.component, "threeDS2Fingerprint")
        case .threeDS2Challenge:
            XCTAssertEqual(event.component, "threeDS2Challenge")
        case .threeDS2:
            XCTAssertEqual(event.component, "threeDS2")
        case .await:
            XCTAssertEqual(event.component, "await")
        case .voucher, .document:
            XCTAssertEqual(event.component, "voucher")
        case .qrCode:
            XCTAssertEqual(event.component, "qrCode")
        case .redirectableAwait:
            XCTAssertEqual(event.component, "await")
        }
    }
    
}
