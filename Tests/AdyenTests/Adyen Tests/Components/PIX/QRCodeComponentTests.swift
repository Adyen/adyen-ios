//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
import XCTest

class QRCodeComponentTests: XCTestCase {
    lazy var method = RedirectPaymentMethod(type: "pix", name: "pix")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "BRL"), countryCode: "BR")
    let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "DummyData", paymentData: "DummyData")
    let componentData = ActionComponentData(details: AwaitActionDetails(payload: "DummyPayload"), paymentData: "DummyData")
    
    func testUIConfiguration() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        var style = QRCodeComponentStyle()
        
        style.copyButton = ButtonStyle(
            title: TextStyle(font: .preferredFont(forTextStyle: .callout), color: .blue, textAlignment: .justified),
            cornerRadius: 4,
            background: .black
        )
        
        style.instructionLabel = TextStyle(
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
        
        let sut = QRCodeComponent(apiContext: Dummy.context, style: style)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        
        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let copyButton: SubmitButton? = viewController.view.findView(by: "copyButton")
                let instructionLabel: UILabel? = viewController.view.findView(by: "instructionLabel")
                let progressView: UIProgressView? = viewController.view.findView(by: "progressView")
                let expirationLabel: UILabel? = viewController.view.findView(by: "expirationLabel")
                let logo: UIImageView? = viewController.view.findView(by: "logo")
                
                // Test copy button
                XCTAssertEqual(copyButton?.backgroundColor, style.copyButton.backgroundColor)
                XCTAssertEqual(copyButton?.layer.cornerRadius, 4)
                
                // Test instruction label
                XCTAssertEqual(instructionLabel?.font, style.instructionLabel.font)
                XCTAssertEqual(instructionLabel?.textColor, style.instructionLabel.color)
                XCTAssertEqual(instructionLabel?.textAlignment, style.instructionLabel.textAlignment)
                
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
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testComponentTimeout() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        let builder = AwaitActionHandlerProviderMock(
            onAwaitHandler: nil,
            onQRHandler: { type in
                XCTAssertEqual(type, QRCodePaymentMethod.pix)
                
                let handler = PollingHandlerMock()
                handler.onHandle = {
                    XCTAssertEqual($0.paymentData, self.action.paymentData)
                }
                
                return handler
            }
        )
        
        let sut = QRCodeComponent(apiContext: Dummy.context, style: QRCodeComponentStyle(), pollingComponentBuilder: builder, timeoutInterval: 2.0)
        
        let componentDelegate = ActionComponentDelegateMock()
        componentDelegate.onDidFail = { error, component in
            if let qrError = error as? QRCodeComponentError,
               case QRCodeComponentError.qrCodeExpired = qrError {}
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
        
        let sut = QRCodeComponent(apiContext: Dummy.context, style: QRCodeComponentStyle(),
                                  pollingComponentBuilder: builder,
                                  timeoutInterval: 2.0)
        
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
        
        let sut = QRCodeComponent(apiContext: Dummy.context, style: QRCodeComponentStyle(),
                                  pollingComponentBuilder: builder,
                                  timeoutInterval: 2.0)
        
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
    
    func testCopyButton() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        let sut = QRCodeComponent(apiContext: Dummy.context, style: QRCodeComponentStyle())
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        
        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? QRCodeViewController)
            let viewController = component.viewController as! QRCodeViewController
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let copyButton: SubmitButton? = viewController.view.findView(by: "copyButton")
                XCTAssertNotNil(copyButton)
                copyButton?.sendActions(for: .touchUpInside)
                
                XCTAssertEqual(self.action.qrCodeData, UIPasteboard.general.string)
                
                dummyExpectation.fulfill()
            }
        }
        
        sut.handle(action)
        waitForExpectations(timeout: 10, handler: nil)
    }
}
