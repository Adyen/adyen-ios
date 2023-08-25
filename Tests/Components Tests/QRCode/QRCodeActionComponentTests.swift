//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
import XCTest

class QRCodeActionComponentTests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }

    lazy var method = InstantPaymentMethod(type: .other("pix"), name: "pix")
    let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")
    let componentData = ActionComponentData(details: AwaitActionDetails(payload: "DummyPayload"), paymentData: "DummyData")
    
    func testComponentSuccess() {
        let expectationForDidProvide = expectation(description: "didProvide expectation")
        
        let handler = PollingHandlerMock()
        let builder = AwaitActionHandlerProviderMock(
            onAwaitHandler: nil,
            onQRHandler: { type in
                XCTAssertEqual(type, QRCodePaymentMethod.pix)
                return handler
            }
        )
        
        let sut = QRCodeActionComponent(context: context,
                                        pollingComponentBuilder: builder)
        
        XCTAssertEqual(sut.timeoutDuration(for: action), 900)
        
        handler.onHandle = {
            XCTAssertEqual($0.paymentData, self.action.paymentData)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                handler.delegate?.didProvide(self.componentData, from: sut)
            }
        }
        
        let componentDelegate = ActionComponentDelegateMock()
        componentDelegate.onDidProvide = { data, component in
            XCTAssertEqual(data.paymentData, self.componentData.paymentData)
            XCTAssertTrue(component === sut)
            expectationForDidProvide.fulfill()
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
    
    func testComponentFailure() {
        let expectationForDidFail = expectation(description: "didFail expectation")
        
        let handler = PollingHandlerMock()
        let builder = AwaitActionHandlerProviderMock(
            onAwaitHandler: nil,
            onQRHandler: { type in
                XCTAssertEqual(type, QRCodePaymentMethod.pix)
                return handler
            }
        )
        
        let sut = QRCodeActionComponent(context: context,
                                        pollingComponentBuilder: builder)
        
        handler.onHandle = {
            XCTAssertEqual($0.paymentData, self.action.paymentData)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                handler.delegate?.didFail(with: UnknownError(), from: sut)
            }
        }
        
        let componentDelegate = ActionComponentDelegateMock()
        componentDelegate.onDidFail = { error, component in
            XCTAssertTrue(error is UnknownError)
            XCTAssertTrue(component === sut)
            expectationForDidFail.fulfill()
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
    
    func testCopyCodeButton() {
        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: context)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        presentationDelegate.doPresent = { component in
            let viewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            self.setupRootViewController(viewController)

            let copyButton: SubmitButton? = viewController.view.findView(by: "copyCodeButton")
            XCTAssertNotNil(copyButton)
            copyButton?.sendActions(for: .touchUpInside)

            XCTAssertEqual(self.action.qrCodeData, UIPasteboard.general.string)

            dummyExpectation.fulfill()
        }

        sut.handle(action)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSaveAsImageButton() {
        lazy var method = InstantPaymentMethod(type: .other("promptpay"), name: "promptpay")
        let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")

        let dummyExpectation = expectation(description: "Dummy Expectation")

        let sut = QRCodeActionComponent(context: context)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        let delgate = QRCodeViewDelegateMock()

        presentationDelegate.doPresent = { component in
            let viewController = try XCTUnwrap(component.viewController as? QRCodeViewController)
            self.setupRootViewController(viewController)
            viewController.qrCodeView.delegate = delgate
            
            let saveAsImageButton: SubmitButton? = viewController.view.findView(by: "saveAsImageButton")
            XCTAssertNotNil(saveAsImageButton)
            saveAsImageButton?.sendActions(for: .touchUpInside)
            XCTAssertTrue(delgate.saveAsImageCalled)
            dummyExpectation.fulfill()
        }

        sut.handle(action)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testQRCodeViewModelSaveAsImageActionButtonType() {
        lazy var method = InstantPaymentMethod(type: .other("promptpay"), name: "promptpay")
        let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")

        let sut = QRCodeActionComponent(context: context)

        let qrCodeViewModel = QRCodeView.Model(action: action, instruction: localizedString(.qrCodeInstructionMessage, sut.configuration.localizationParameters), payment: nil, logoUrl: LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment), observedProgress: nil, expiration: AdyenObservable(nil), style: QRCodeView.Model.Style(copyCodeButton: .init(title: .init(font: UIFont(), color: .red)), saveAsImageButton: .init(title: .init(font: UIFont(), color: .red)), instructionLabel: .init(font: UIFont(), color: .red), amountToPayLabel: .init(font: UIFont(), color: .red), progressView: .init(progressTintColor: .red, trackTintColor: .red), expirationLabel: .init(font: UIFont(), color: .red), logoCornerRounding: .fixed(5.0), backgroundColor: .red))

        XCTAssertEqual(qrCodeViewModel.actionButtonType, .saveAsImage)
    }

    func testQRCodeViewModelCopyCodeActionButtonType() {
        lazy var method = InstantPaymentMethod(type: .other("pix"), name: "pix")
        let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")

        let sut = QRCodeActionComponent(context: context)

        let qrCodeViewModel = QRCodeView.Model(action: action, instruction: localizedString(.qrCodeTimerExpirationMessage, sut.configuration.localizationParameters), payment: nil, logoUrl: LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment), observedProgress: nil, expiration: AdyenObservable(nil), style: QRCodeView.Model.Style(copyCodeButton: .init(title: .init(font: UIFont(), color: .red)), saveAsImageButton: .init(title: .init(font: UIFont(), color: .red)), instructionLabel: .init(font: UIFont(), color: .red), amountToPayLabel: .init(font: UIFont(), color: .red), progressView: .init(progressTintColor: .red, trackTintColor: .red), expirationLabel: .init(font: UIFont(), color: .red), logoCornerRounding: .fixed(5.0), backgroundColor: .red))

        XCTAssertEqual(qrCodeViewModel.actionButtonType, .copyCode)
    }
    
    func testTimeoutForActions() {
        let sut = QRCodeActionComponent(context: context)
        let promptPay = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")
        let pix = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")
        let duitNow = QRCodeAction(paymentMethodType: .duitNow, qrCodeData: "DummyData", paymentData: "DummyData")
        let payNow = QRCodeAction(paymentMethodType: .payNow, qrCodeData: "DummyData", paymentData: "DummyData")
        
        XCTAssertEqual(sut.timeoutDuration(for: promptPay), 90)
        XCTAssertEqual(sut.timeoutDuration(for: duitNow), 90)
        XCTAssertEqual(sut.timeoutDuration(for: pix), 900)
        XCTAssertEqual(sut.timeoutDuration(for: payNow), 180)
    }

}
