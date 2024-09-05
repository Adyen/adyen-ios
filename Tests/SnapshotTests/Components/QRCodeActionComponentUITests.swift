//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import XCTest

class QRCodeActionComponentUITests: XCTestCase {

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testUIConfigurationForPromptPay() {
        lazy var method = InstantPaymentMethod(type: .other("promptpay"), name: "promptpay")
        let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: Dummy.context)
        sut.configuration.style = customStyle()
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            let qrCodeViewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            
            self.setupRootViewController(qrCodeViewController)
            self.wait(for: qrCodeViewController.qrCodeView)
            self.assertViewControllerImage(matching: qrCodeViewController, named: "promptPay")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testUIConfigurationForPix() {
        lazy var method = InstantPaymentMethod(type: .other("pix"), name: "pix")
        let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")
     
        let sut = QRCodeActionComponent(context: Dummy.context)
        sut.configuration.style = customStyle()
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            let qrCodeViewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            
            self.setupRootViewController(qrCodeViewController)
            self.wait(for: qrCodeViewController.qrCodeView)
            self.verifyViewControllerImage(matching: qrCodeViewController, named: "pix")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testUIConfigurationForUPIQRCode() {
        lazy var method = InstantPaymentMethod(type: .other("upi_qr"), name: "upi")
        let action = QRCodeAction(paymentMethodType: .upiQRCode, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: Dummy.context)
        sut.configuration.style = customStyle()
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            let qrCodeViewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            
            self.setupRootViewController(qrCodeViewController)
            self.wait(for: qrCodeViewController.qrCodeView)
            self.verifyViewControllerImage(matching: qrCodeViewController, named: "upi")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testQRCodeCancelButtonOnUPI() {

        lazy var method = InstantPaymentMethod(type: .other("upi_qr"), name: "upi")
        let action = QRCodeAction(paymentMethodType: .upiQRCode, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        let sut = QRCodeActionComponent(context: Dummy.context)
        sut.configuration.style = customStyle()
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            
            let qrCodeViewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            
            let pollingComponentToolBar = CancellingToolBar(
                title: qrCodeViewController.title,
                style: NavigationStyle()
            )
            
            let wrapper = WrapperViewController(
                child: ModalViewController(
                    rootViewController: qrCodeViewController,
                    navBarType: .custom(pollingComponentToolBar)
                )
            )
            
            self.setupRootViewController(wrapper)
            self.wait(for: qrCodeViewController.qrCodeView)
            self.verifyViewControllerImage(matching: wrapper, named: "upi_cancel_button")

            dummyExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }
}

// MARK: - Convenience

private extension QRCodeActionComponentUITests {
    
    func wait(for qrCodeView: QRCodeView) {
        self.wait { qrCodeView.expirationLabel.text?.isEmpty == false }
        self.wait { qrCodeView.logo.image != nil }
        // Allow the ui to reflect all changes
        self.wait(for: .aMoment)
    }
    
    func customStyle() -> QRCodeComponentStyle {
        
        var style = QRCodeComponentStyle()

        style.saveAsImageButton = ButtonStyle(
            title: TextStyle(font: .preferredFont(forTextStyle: .callout), color: .blue, textAlignment: .justified),
            cornerRadius: 4,
            background: .black
        )
        
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
            progressTintColor: .brown, trackTintColor: .cyan
        )

        style.expirationLabel = TextStyle(
            font: .boldSystemFont(ofSize: 25),
            color: .blue, textAlignment: .right
        )

        style.logoCornerRounding = .fixed(10)

        style.backgroundColor = UIColor.Adyen.componentSeparator
        
        return style
    }
}
