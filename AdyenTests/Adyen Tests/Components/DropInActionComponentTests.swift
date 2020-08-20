//
//  DropInActionComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/19/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenDropIn
import SafariServices

class DropInActionComponentTests: XCTestCase {

    func testRedirectToHttpWebLink() {
        let sut = DropInActionComponent()
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

}
