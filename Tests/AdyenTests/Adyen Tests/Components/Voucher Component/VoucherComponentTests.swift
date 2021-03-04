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

    func testVoucherComponent() throws {
        let viewControllerProvider = VoucherViewControllerProviderMock()
        let presentationDelegate = PresentationDelegateMock()
        let sut = VoucherComponent(voucherViewControllerProvider: viewControllerProvider)
        sut.localizationParameters = LocalizationParameters(tableName: "test_table")
        sut.presentationDelegate = presentationDelegate

        let action = try Coder.decode(dokuIndomaretAction) as VoucherAction

        let expectedViewContoller = UIViewController()
        expectedViewContoller.title = "test_title"

        let viewControllerProviderExpectation = expectation(description: "Expect viewControllerProvider.provide() to be called.")
        viewControllerProvider.onProvide = { action in
            viewControllerProviderExpectation.fulfill()
            return expectedViewContoller
        }

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { component in
            let component = component as! PresentableComponentWrapper
            XCTAssertEqual(component.viewController.title, "test_title")
            XCTAssertTrue(component.viewController === expectedViewContoller)
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)
        XCTAssertEqual(viewControllerProvider.localizationParameters?.tableName, "test_table")

        waitForExpectations(timeout: 2, handler: nil)
    }
}
