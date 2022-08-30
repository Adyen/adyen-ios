//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
import XCTest

class PromptPayActionComponentTests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }

    lazy var method = InstantPaymentMethod(type: .other("promptpay"), name: "promptpay")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "THB"), countryCode: "TH")
    let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")
    let componentData = ActionComponentData(details: AwaitActionDetails(payload: "DummyPayload"), paymentData: "DummyData")

    func testComponentTimeout() {
        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: context,
                                        timeoutInterval: 2.0)
        let componentDelegate = ActionComponentDelegateMock()
        componentDelegate.onDidFail = { error, component in
            if let qrError = error as? QRCodeComponentError,
               case QRCodeComponentError.qrCodeExpired = qrError { }
            else {
                XCTFail()
            }
            dummyExpectation.fulfill()
        }

        let presentationDelegate = PresentationDelegateMock()
        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController

            UIApplication.shared.keyWindow?.rootViewController = viewController
        }

        sut.presentationDelegate = presentationDelegate
        sut.delegate = componentDelegate

        sut.handle(action)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testSaveAsImageButton() {
        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: context)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        let delgate = QRCodeViewDelegateMock()

        presentationDelegate.doPresent = { [self] component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            viewController.qrCodeView.delegate = delgate
            wait(for: .milliseconds(300))
                        let saveAsImageButton: SubmitButton? = viewController.view.findView(by: "SaveAsImageButton")
            XCTAssertNotNil(saveAsImageButton)
            saveAsImageButton?.sendActions(for: .touchUpInside)
            XCTAssertTrue(delgate.saveAsImageCalled)
            dummyExpectation.fulfill()
        }

        sut.handle(action)
        waitForExpectations(timeout: 10, handler: nil)
    }
}
