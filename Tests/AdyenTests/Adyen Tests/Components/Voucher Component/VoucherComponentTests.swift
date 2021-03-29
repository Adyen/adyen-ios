//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

class VoucherComponentTests: XCTestCase {

    var sut: VoucherComponent!

    var presentationDelegate: PresentationDelegateMock!

    var viewControllerProvider: VoucherViewControllerProviderMock!

    var expectedViewContoller: UIViewController!

    override func setUp() {
        super.setUp()
        viewControllerProvider = VoucherViewControllerProviderMock()
        presentationDelegate = PresentationDelegateMock()
        sut = VoucherComponent(voucherViewControllerProvider: viewControllerProvider)
        sut.localizationParameters = LocalizationParameters(tableName: "test_table")
        sut.presentationDelegate = presentationDelegate

        expectedViewContoller = UIViewController()
        expectedViewContoller.title = "test_title"
    }

    func testDukoVoucherComponent() throws {
        let action = try Coder.decode(dokuIndomaretAction) as VoucherAction

        let viewControllerProviderExpectation = expectation(description: "Expect viewControllerProvider.provide() to be called.")
        viewControllerProvider.onProvide = { action in
            viewControllerProviderExpectation.fulfill()
            return self.expectedViewContoller
        }

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { component in
            let component = component as! PresentableComponentWrapper
            XCTAssertEqual(component.viewController.title, "test_title")
            XCTAssertTrue(component.viewController === self.expectedViewContoller)
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)
        XCTAssertEqual(viewControllerProvider.localizationParameters?.tableName, "test_table")

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testEContextATMVoucherComponent() throws {
        let action = try Coder.decode(econtextATMAction) as VoucherAction

        let viewControllerProviderExpectation = expectation(description: "Expect viewControllerProvider.provide() to be called.")
        viewControllerProvider.onProvide = { action in
            viewControllerProviderExpectation.fulfill()
            return self.expectedViewContoller
        }

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { component in
            let component = component as! PresentableComponentWrapper
            XCTAssertEqual(component.viewController.title, "test_title")
            XCTAssertTrue(component.viewController === self.expectedViewContoller)
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)
        XCTAssertEqual(viewControllerProvider.localizationParameters?.tableName, "test_table")

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testEContextStoresVoucherComponent() throws {
        let action = try Coder.decode(econtextStoresAction) as VoucherAction

        let viewControllerProviderExpectation = expectation(description: "Expect viewControllerProvider.provide() to be called.")
        viewControllerProvider.onProvide = { action in
            viewControllerProviderExpectation.fulfill()
            return self.expectedViewContoller
        }

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { component in
            let component = component as! PresentableComponentWrapper
            XCTAssertEqual(component.viewController.title, "test_title")
            XCTAssertTrue(component.viewController === self.expectedViewContoller)
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)
        XCTAssertEqual(viewControllerProvider.localizationParameters?.tableName, "test_table")

        waitForExpectations(timeout: 2, handler: nil)
    }
}
