//
//  VoucherComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
import UIKit
import Adyen
@testable import AdyenActions

class VoucherComponentTests: XCTestCase {

    let indomaretJson: [String: Any] = [
        "reference" : "9786512300056485",
        "initialAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "paymentMethodType" : "doku_indomaret",
        "instructionsUrl" : "https://www.doku.com/how-to-pay/indomaret.php",
        "shopperEmail" : "Qwfqwf@POj.co",
        "totalAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "expiresAt" : "2021-02-02T22:00:00",
        "merchantName" : "Adyen Demo Shop",
        "shopperName" : "Qwfqwew Gewgewf",
        "type" : "voucher"
      ]

    func testVoucherComponent() throws {
        let viewControllerProvider = VoucherViewControllerProviderMock()
        let presentationDelegate = PresentationDelegateMock()
        let sut = VoucherComponent(voucherViewControllerProvider: viewControllerProvider)
        sut.presentationDelegate = presentationDelegate

        let dokuAction = try Coder.decode(indomaretJson) as DokuVoucherAction
        let action = VoucherAction.dokuAlfamart(dokuAction)

        let expectedViewContoller = UIViewController()
        expectedViewContoller.title = "test_title"

        let viewControllerProviderExpectation = expectation(description: "Expect viewControllerProvider.provide() to be called.")
        viewControllerProvider.onProvide = { action in
            viewControllerProviderExpectation.fulfill()
            return expectedViewContoller
        }

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { component, disableCloseButton in
            let component = component as! PresentableComponentWrapper
            XCTAssertEqual(component.viewController.title, "test_title")
            XCTAssertTrue(component.viewController === expectedViewContoller)
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

}
