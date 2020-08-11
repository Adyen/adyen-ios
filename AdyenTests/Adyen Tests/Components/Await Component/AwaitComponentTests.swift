//
//  AwaitComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/11/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen

class AwaitComponentTests: XCTestCase {

    func testUIConfiguration() {
        var style = AwaitComponentStyle()
        style.backgroundColor = UIColor.green

        style.message = TextStyle(font: UIFont.systemFont(ofSize: 15), color: UIColor.red, textAlignment: .center)

        style.spinnerTitle = TextStyle(font: UIFont.systemFont(ofSize: 21), color: UIColor.blue, textAlignment: .left)

        let sut = AwaitComponent(apiClient: nil, style: style)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let presentationDelegate = PresentationDelegateMock()
        let waitExpectation = expectation(description: "Wait for the presentationDelegate to be called.")
        presentationDelegate.doPresent = { component, disableCloseButton in
            XCTAssertNotNil(component.viewController as? AwaitViewController)
            let viewController = component.viewController as! AwaitViewController

            UIApplication.shared.keyWindow?.rootViewController = viewController

            let view = viewController.awaitView

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(view.messageLabel.textColor, UIColor.red)
                XCTAssertEqual(view.messageLabel.textAlignment, .center)
                XCTAssertEqual(view.messageLabel.font, UIFont.systemFont(ofSize: 15))

                XCTAssertEqual(view.spinnerTitleLabel.textColor, UIColor.blue)
                XCTAssertEqual(view.spinnerTitleLabel.textAlignment, .left)
                XCTAssertEqual(view.spinnerTitleLabel.font, UIFont.systemFont(ofSize: 21))
                XCTAssertEqual(view.activityIndicatorView.color, UIColor.blue)

                XCTAssertEqual(view.backgroundColor, .green)

                waitExpectation.fulfill()
            }
        }


        sut.presentationDelegate = presentationDelegate
        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 3, handler: nil)
    }
    
}
