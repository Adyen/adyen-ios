//
//  FormErrorItemTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 4/19/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormErrorItemTests: XCTestCase {

    func testHidingAndShowing() throws {
        let formViewController = FormViewController(style: FormComponentStyle())

        UIApplication.shared.keyWindow?.rootViewController? = formViewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let errorItem = FormErrorItem(message: "Error Message", iconName: "error")
            errorItem.identifier = "errorItem"
            formViewController.append(errorItem)

            let errorView: FormErrorItemView? = formViewController.view.findView(with: "errorItem")

            let messageLabel: UILabel? = formViewController.view.findView(with: "errorItem.messageLabel")
            let iconView: UIImageView? = formViewController.view.findView(with: "errorItem.iconView")
            XCTAssertTrue(errorView!.isHidden)

            errorItem.isHidden.wrappedValue = false

            XCTAssertFalse(errorView!.isHidden)
            XCTAssertEqual(messageLabel?.text, "Error Message")
            XCTAssertNotNil(iconView?.image)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }

}
