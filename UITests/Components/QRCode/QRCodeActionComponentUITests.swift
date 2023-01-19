//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
import XCTest

class QRCodeActionComponentUITests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }

    func testUIConfigurationForPromptPay() {
        lazy var method = InstantPaymentMethod(type: .other("promptpay"), name: "promptpay")
        let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")
        var style = QRCodeComponentStyle()

        style.saveAsImageButton = ButtonStyle(
            title: TextStyle(font: .preferredFont(forTextStyle: .callout), color: .blue, textAlignment: .justified),
            cornerRadius: 4,
            background: .black
        )

        style.instructionLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .red,
            textAlignment: .left
        )

        style.amountToPayLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .yellow,
            textAlignment: .left
        )

        style.progressView = ProgressViewStyle(
            progressTintColor: .brown, trackTintColor: .cyan
        )

        style.expirationLabel = TextStyle(
            font: .boldSystemFont(ofSize: 25),
            color: .blue, textAlignment: .right
        )

        style.logoCornerRounding = .fixed(10)

        style.backgroundColor = UIColor.Adyen.componentSeparator

        let sut = QRCodeActionComponent(context: context)
        sut.configuration.style = style
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            
            UIApplication.shared.mainKeyWindow?.rootViewController = component.viewController
            
            // wait until the expiration label is rendered
            self.wait(for: .seconds(1))
            
            self.assertViewControllerImage(matching: component.viewController, named: "promptPay")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUIConfigurationForPix() {
        lazy var method = InstantPaymentMethod(type: .other("pix"), name: "pix")
        let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")
        var style = QRCodeComponentStyle()

        style.copyCodeButton = ButtonStyle(
            title: TextStyle(font: .preferredFont(forTextStyle: .callout), color: .blue, textAlignment: .justified),
            cornerRadius: 4,
            background: .black
        )

        style.instructionLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .red,
            textAlignment: .left
        )

        style.amountToPayLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .yellow,
            textAlignment: .left
        )

        style.progressView = ProgressViewStyle(
            progressTintColor: .cyan, trackTintColor: .brown
        )

        style.expirationLabel = TextStyle(
            font: .boldSystemFont(ofSize: 25),
            color: .magenta, textAlignment: .right
        )

        style.logoCornerRounding = .fixed(10)

        style.backgroundColor = UIColor.Adyen.componentSeparator

        let sut = QRCodeActionComponent(context: context)
        sut.configuration.style = style
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            
            UIApplication.shared.mainKeyWindow?.rootViewController = component.viewController
            
            // wait until the expiration label is rendered
            self.wait(for: .seconds(1))
            
            self.assertViewControllerImage(matching: component.viewController, named: "pix")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 10, handler: nil)
    }


}
