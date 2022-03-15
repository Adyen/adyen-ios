//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import PassKit
import XCTest

class PreApplePayComponentTests: XCTestCase {
    
    var sut: PreApplePayComponent!
    lazy var amount = Amount(value: 2, currencyCode: getRandomCurrencyCode())
    lazy var payment = Payment(amount: amount, countryCode: getRandomCountryCode())
    
    override func setUp() {
        let configuration = ApplePayComponent.Configuration(payment: Dummy.createTestApplePayPayment(),
                                                            merchantIdentifier: "test_id")
        var applePayStyle = ApplePayStyle()
        applePayStyle.paymentButtonType = .inStore
        let preApplePayConfig = PreApplePayComponent.Configuration(style: applePayStyle)
        sut = try! PreApplePayComponent(paymentMethod: ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil),
                                        apiContext: Dummy.context,
                                        payment: payment,
                                        configuration: preApplePayConfig,
                                        applePayConfiguration: configuration)
    }
    
    func testUIConfiguration() {
        let applePayStyle = ApplePayStyle(paymentButtonStyle: .whiteOutline,
                                          paymentButtonType: .donate,
                                          cornerRadius: 10,
                                          backgroundColor: .orange,
                                          hintLabel: .init(font: .boldSystemFont(ofSize: 16),
                                                           color: .red,
                                                           textAlignment: .center))
        let model = PreApplePayView.Model(hint: amount.formatted,
                                          style: applePayStyle)
        
        let view = PreApplePayView(model: model)
        let viewController = UIViewController()
        viewController.view = view
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .seconds(1))
        
        let hintLabel: UILabel? = viewController.view.findView(by: "hintLabel")
        XCTAssertEqual(hintLabel?.text, model.hint)
        XCTAssertEqual(hintLabel?.font, model.style.hintLabel.font)
        XCTAssertEqual(hintLabel?.textColor, model.style.hintLabel.color)
        XCTAssertEqual(hintLabel?.textAlignment, model.style.hintLabel.textAlignment)
        
        XCTAssertEqual(viewController.view.backgroundColor, model.style.backgroundColor)
        
        let style = view.model.style
        if #available(iOS 12.0, *) {
            XCTAssertEqual(style.cornerRadius, 10)
        }
        XCTAssertEqual(style.paymentButtonStyle, .whiteOutline)
        XCTAssertEqual(style.paymentButtonType, .donate)
    }
    
    func testApplePayPresented() {
        guard Available.iOS12 else { return }
        let presentExpectation = expectation(description: "Present Expectation")
        let dismissExpectation = expectation(description: "Dismiss Expectation")
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            UIApplication.shared.keyWindow?.rootViewController?.present(component: component)
        }
        presentationMock.doDismiss = { compleat in
            compleat?()
        }
        sut.presentationDelegate = presentationMock
        
        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        
        XCTAssertNotNil(applePayButton)
        
        applePayButton?.sendActions(for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
            presentExpectation.fulfill()
        }

        sut.finalizeIfNeeded(with: false) {
            dismissExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHintLabelAmount() {
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController?.present(component: sut)
        
        let dummyExpectation = expectation(description: "Dummy Expectation")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let hintLabel = self.sut.viewController.view.findView(by: "hintLabel") as? UILabel
            
            XCTAssertNotNil(hintLabel)
            XCTAssertEqual(hintLabel?.text, self.amount.formatted)
            
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

}
