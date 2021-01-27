//
//  AdyenActionHandlerTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/19/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import AdyenActions
import Adyen
import SafariServices
import XCTest

class AdyenActionHandlerTests: XCTestCase {

    let weChatActionResponse = """
    {
      "timestamp" : "x",
      "partnerid" : "x",
      "noncestr" : "x",
      "packageValue" : "Sign=WXPay",
      "sign" : "x",
      "appid" : "x",
      "prepayid" : "x"
    }
    """

    func testRedirectToHttpWebLink() {
        let sut = AdyenActionHandler()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? SFSafariViewController)

            sut.dismiss(true) {
                let topPresentedViewController = UIViewController.findTopPresenter()
                XCTAssertNil(topPresentedViewController as? SFSafariViewController)

                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAwaitAction() {
        let sut = AdyenActionHandler()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        sut.clientKey = "SOME_KLIENT_KEY"

        sut.presentationDelegate = UIViewController.findTopPresenter()

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = Action.await(AwaitAction(paymentData: "SOME_DATA", paymentMethodType: .blik))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? AdyenActions.AwaitViewController)

            (sut.presentationDelegate as! UIViewController).dismiss(animated: false) {
                let topPresentedViewController = UIViewController.findTopPresenter()
                XCTAssertNil(topPresentedViewController as? AdyenActions.AwaitViewController)

                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testWeChatAction() {
        let sut = AdyenActionHandler()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        sut.clientKey = "SOME_KLIENT_KEY"

        sut.presentationDelegate = UIViewController.findTopPresenter()

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let weChatData = try! JSONDecoder().decode(WeChatPaySDKData.self, from: weChatActionResponse.data(using: .utf8)!)
        let action = Action.sdk(.weChatPay(WeChatPaySDKAction.init(sdkData: weChatData, paymentData: "SOME_DATA") ))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            XCTAssertNotNil(sut.weChatPaySDKActionComponent)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension UIViewController: PresentationDelegate {
    public func present(component: PresentableComponent, disableCloseButton: Bool) {
        self.present(component.viewController, animated: false, completion: nil)
    }
}
