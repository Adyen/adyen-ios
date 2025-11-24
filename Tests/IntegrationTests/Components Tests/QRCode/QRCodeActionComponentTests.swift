//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class QRCodeActionComponentTests: XCTestCase {
    
    var context: AdyenContext!
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
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
        
        let sut = QRCodeActionComponent(
            context: context,
            pollingComponentBuilder: builder
        )
        
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
            
            self.setupRootViewController(viewController)
        }
        
        sut.presentationDelegate = presentationDelegate
        sut.delegate = componentDelegate
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
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
        
        let sut = QRCodeActionComponent(
            context: context,
            pollingComponentBuilder: builder
        )
        
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
            self.setupRootViewController(viewController)
        }
        
        sut.presentationDelegate = presentationDelegate
        sut.delegate = componentDelegate
        
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testCopyCodeButton() throws {
        // Given
        let expectedCode = "DummyData"
        let action = QRCodeAction(
            paymentMethodType: .pix,
            qrCodeData: expectedCode,
            paymentData: "DummyData"
        )
        let logoUrl = LogoURLProvider.logoURL(
            withName: action.paymentMethodType.rawValue,
            environment: context.apiContext.environment
        )
        
        let copyCodeExpectation = expectation(description: "Copy code completion was called.")
        
        let style = QRCodeViewStyle(
            copyCodeButton: .init(title: .init(font: .systemFont(ofSize: 17), color: .red)),
            saveAsImageButton: .init(title: .init(font: .systemFont(ofSize: 17), color: .red)),
            instructionLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            amountToPayLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            progressView: .init(progressTintColor: .red, trackTintColor: .red),
            expirationLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            logoCornerRounding: .fixed(5.0),
            backgroundColor: .red
        )
        
        let viewModel = QRCodeViewModel(
            action: action,
            instructionText: "",
            payment: nil,
            logoUrl: logoUrl,
            observedProgress: nil,
            expiration: AdyenObservable(nil),
            localizationParameters: nil,
            onSaveQRCode: { _, _ in /* Empty implementation */ },
            onCopyCode: { receivedCode in
                XCTAssertEqual(expectedCode, receivedCode)
                copyCodeExpectation.fulfill()
            }
        )
        let qrCodeViewController = QRCodeViewController(viewModel: viewModel, style: style)
        
        setupRootViewController(qrCodeViewController)
        
        // When
        let saveAsImageButton: SubmitButton = try XCTUnwrap(qrCodeViewController.view.findView(by: "copyCodeButton"))
        saveAsImageButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSaveAsImageButton() throws {
        // Given
        let action = QRCodeAction(
            paymentMethodType: .promptPay,
            qrCodeData: "DummyData",
            paymentData: "DummyData"
        )
        let logoUrl = LogoURLProvider.logoURL(
            withName: action.paymentMethodType.rawValue,
            environment: context.apiContext.environment
        )
        
        let saveImageExpectation = expectation(description: "Save image completion was called.")
        
        let style = QRCodeViewStyle(
            copyCodeButton: .init(title: .init(font: .systemFont(ofSize: 17), color: .red)),
            saveAsImageButton: .init(title: .init(font: .systemFont(ofSize: 17), color: .red)),
            instructionLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            amountToPayLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            progressView: .init(progressTintColor: .red, trackTintColor: .red),
            expirationLabel: .init(font: .systemFont(ofSize: 17), color: .red),
            logoCornerRounding: .fixed(5.0),
            backgroundColor: .red
        )
        
        let viewModel = QRCodeViewModel(
            action: action,
            instructionText: "",
            payment: nil,
            logoUrl: logoUrl,
            observedProgress: nil,
            expiration: AdyenObservable(nil),
            localizationParameters: nil,
            onSaveQRCode: { _, _ in
                // Then
                saveImageExpectation.fulfill()
            }, onCopyCode: { _ in /* Empty implementation */ }
        )
        let qrCodeViewController = QRCodeViewController(viewModel: viewModel, style: style)
        
        setupRootViewController(qrCodeViewController)
        
        // When
        let saveAsImageButton: SubmitButton = try XCTUnwrap(qrCodeViewController.view.findView(by: "saveAsImageButton"))
        saveAsImageButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testQRCodeViewModelSaveAsImageActionButtonType() {
        let action = QRCodeAction(paymentMethodType: .promptPay, qrCodeData: "DummyData", paymentData: "DummyData")
        
        let sut = QRCodeActionComponent(context: context)
        
        let qrCodeViewModel = QRCodeViewModel(
            action: action,
            instructionText: localizedString(.qrCodeInstructionMessage, sut.configuration.localizationParameters),
            payment: nil,
            logoUrl: LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment),
            observedProgress: nil,
            expiration: AdyenObservable(nil),
            localizationParameters: nil,
            onSaveQRCode: ({ _, _ in /* Empty implementation */ }),
            onCopyCode: ({ _ in /* Empty implementation */ })
        )
        
        XCTAssertEqual(qrCodeViewModel.flowType, .saveCodeAsImage)
    }
    
    func testQRCodeViewModelCopyCodeActionButtonType() {
        lazy var method = InstantPaymentMethod(type: .other("pix"), name: "pix")
        let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")
        
        let sut = QRCodeActionComponent(context: context)
                
        let qrCodeViewModel = QRCodeViewModel(
            action: action,
            instructionText: localizedString(.qrCodeTimerExpirationMessage, sut.configuration.localizationParameters),
            payment: nil,
            logoUrl: LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment),
            observedProgress: nil,
            expiration: AdyenObservable(nil),
            localizationParameters: nil,
            onSaveQRCode: ({ _, _ in /* Empty implementation */ }),
            onCopyCode: ({ _ in /* Empty implementation */ })
        )
        
        XCTAssertEqual(qrCodeViewModel.flowType, .copyCode)
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
    
    func testExpiryTimer() {
        let tickExpectation = expectation(description: "onTick is called")
        let expirationExpectation = expectation(description: "onExpiration is called")
        
        let expiryTimer = ExpirationTimer(expirationTimeout: 1) { timeLeft in
            XCTAssertEqual(timeLeft, 1)
            tickExpectation.fulfill()
        } onExpiration: {
            expirationExpectation.fulfill()
        }
        
        expiryTimer.startTimer()
        
        wait(for: [tickExpectation, expirationExpectation], timeout: 1.1)
    }
    
    func testExpiryTimerCancellation() {
        
        let tickExpectation = expectation(description: "onTick is called")
        
        let expiryTimer = ExpirationTimer(expirationTimeout: 1) { timeLeft in
            XCTAssertEqual(timeLeft, 1)
            tickExpectation.fulfill()
        } onExpiration: {
            XCTFail("Timer was cancelled so onExpiration should not have been called")
        }
        
        expiryTimer.startTimer()
        wait(for: .milliseconds(10))
        expiryTimer.stopTimer()
        
        wait(for: [tickExpectation], timeout: 0)
        
        wait(for: .seconds(1)) // Waiting a bit longer to make sure the expiration block is not called
    }
}
