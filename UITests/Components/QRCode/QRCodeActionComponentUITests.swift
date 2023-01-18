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
            color: .darkGray,
            textAlignment: .left
        )

        style.amountToPayLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .darkGray,
            textAlignment: .left
        )

        style.progressView = ProgressViewStyle(
            progressTintColor: .cyan, trackTintColor: .brown
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

        presentationDelegate.doPresent = { [weak self] component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController

            UIApplication.shared.mainKeyWindow?.rootViewController = viewController

            self?.wait(for: .milliseconds(300))

            let saveAsImageButton: SubmitButton? = viewController.view.findView(by: "saveAsImageButton")
            let instructionLabel: UILabel? = viewController.view.findView(by: "instructionLabel")
            let progressView: UIProgressView? = viewController.view.findView(by: "progressView")
            let amountToPayLabel: UILabel? = viewController.view.findView(by: "amountToPayLabel")
            let expirationLabel: UILabel? = viewController.view.findView(by: "expirationLabel")
            let logo: UIImageView? = viewController.view.findView(by: "logo")

            // Test save as image button
            XCTAssertEqual(saveAsImageButton?.backgroundColor, style.saveAsImageButton.backgroundColor)
            XCTAssertEqual(saveAsImageButton?.layer.cornerRadius, 4)

            // Test instruction label
            XCTAssertEqual(instructionLabel?.font, style.instructionLabel.font)
            XCTAssertEqual(instructionLabel?.textColor, style.instructionLabel.color)
            XCTAssertEqual(instructionLabel?.textAlignment, style.instructionLabel.textAlignment)

            // Test amountToPay label
            XCTAssertEqual(amountToPayLabel?.font, UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold))
            XCTAssertEqual(amountToPayLabel?.textColor, style.amountToPayLabel.color)
            XCTAssertEqual(amountToPayLabel?.textAlignment, style.amountToPayLabel.textAlignment)

            // Test progress view
            XCTAssertEqual(progressView?.progressTintColor, style.progressView.progressTintColor)
            XCTAssertEqual(progressView?.trackTintColor, style.progressView.trackTintColor)

            // Test expiration label
            XCTAssertEqual(expirationLabel?.font, style.expirationLabel.font)
            XCTAssertEqual(expirationLabel?.textColor, style.expirationLabel.color)
            XCTAssertEqual(expirationLabel?.textAlignment, style.expirationLabel.textAlignment)

            // Test logo
            XCTAssertEqual(logo?.layer.cornerRadius, 10)

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
            color: .darkGray,
            textAlignment: .left
        )

        style.amountToPayLabel = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .darkGray,
            textAlignment: .left
        )

        style.progressView = ProgressViewStyle(
            progressTintColor: .cyan, trackTintColor: .brown
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

        presentationDelegate.doPresent = { [weak self] component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController

            UIApplication.shared.mainKeyWindow?.rootViewController = viewController

            self?.wait(for: .milliseconds(300))

            let copyCodeButton: SubmitButton? = viewController.view.findView(by: "copyCodeButton")
            let instructionLabel: UILabel? = viewController.view.findView(by: "instructionLabel")
            let progressView: UIProgressView? = viewController.view.findView(by: "progressView")
            let amountToPayLabel: UILabel? = viewController.view.findView(by: "amountToPayLabel")
            let expirationLabel: UILabel? = viewController.view.findView(by: "expirationLabel")
            let logo: UIImageView? = viewController.view.findView(by: "logo")

            // Test copy code button
            XCTAssertEqual(copyCodeButton?.backgroundColor, style.copyCodeButton.backgroundColor)
            XCTAssertEqual(copyCodeButton?.layer.cornerRadius, 4)

            // Test instruction label
            XCTAssertEqual(instructionLabel?.font, style.instructionLabel.font)
            XCTAssertEqual(instructionLabel?.textColor, style.instructionLabel.color)
            XCTAssertEqual(instructionLabel?.textAlignment, style.instructionLabel.textAlignment)

            // Test amountToPay label
            XCTAssertEqual(amountToPayLabel?.font, UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold))
            XCTAssertEqual(amountToPayLabel?.textColor, style.amountToPayLabel.color)
            XCTAssertEqual(amountToPayLabel?.textAlignment, style.amountToPayLabel.textAlignment)

            // Test progress view
            XCTAssertEqual(progressView?.progressTintColor, style.progressView.progressTintColor)
            XCTAssertEqual(progressView?.trackTintColor, style.progressView.trackTintColor)

            // Test expiration label
            XCTAssertEqual(expirationLabel?.font, style.expirationLabel.font)
            XCTAssertEqual(expirationLabel?.textColor, style.expirationLabel.color)
            XCTAssertEqual(expirationLabel?.textAlignment, style.expirationLabel.textAlignment)

            // Test logo
            XCTAssertEqual(logo?.layer.cornerRadius, 10)

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 10, handler: nil)
    }


}
