//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@testable import AdyenDropIn
import PassKit
import XCTest

class PreApplePayComponentTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    let amount = Dummy.payment.amount
    var paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
    var context: AdyenContext!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var sut: PreApplePayComponent!
    lazy var applePayPayment = Dummy.createTestApplePayPayment()

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        context = Dummy.context(with: analyticsProviderMock)
        paymentComponentDelegate = PaymentComponentDelegateMock()

        let configuration = ApplePayComponent.Configuration(payment: applePayPayment,
                                                            merchantIdentifier: "test_id")
        var applePayStyle = ApplePayStyle()
        applePayStyle.paymentButtonType = .inStore
        let preApplePayConfig = PreApplePayComponent.Configuration(style: applePayStyle)
        sut = try! PreApplePayComponent(paymentMethod: ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil),
                                        context: Dummy.context,
                                        configuration: preApplePayConfig,
                                        applePayConfiguration: configuration)
        sut.delegate = paymentComponentDelegate
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentComponentDelegate = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testUIConfiguration() {
        let applePayStyle = ApplePayStyle(paymentButtonStyle: .whiteOutline,
                                          paymentButtonType: .donate,
                                          cornerRadius: 10,
                                          backgroundColor: .orange,
                                          hintLabel: .init(font: .boldSystemFont(ofSize: 16),
                                                           color: .red,
                                                           textAlignment: .center))
        let model = PreApplePayView.Model(hint: applePayPayment.amount.formatted,
                                          style: applePayStyle)
        
        let view = PreApplePayView(model: model)
        let viewController = UIViewController()
        viewController.view = view
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
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
        let dismissExpectation = expectation(description: "Dismiss Expectation")
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            UIApplication.shared.keyWindow?.rootViewController?.present(component: component)
        }
        presentationMock.doDismiss = { completion in completion?() }
        sut.presentationDelegate = presentationMock
        
        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        
        XCTAssertNotNil(applePayButton)
        
        applePayButton?.sendActions(for: .touchUpInside)
        
        wait(for: .milliseconds(300))
        
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)

        sut.finalizeIfNeeded(with: false) {
            dismissExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHintLabelAmount() {
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController?.present(component: sut)
        
        wait(for: .milliseconds(300))
        
        let hintLabel = self.sut.viewController.view.findView(by: "hintLabel") as? UILabel
        
        XCTAssertNotNil(hintLabel)
        XCTAssertEqual(hintLabel?.text, self.applePayPayment.amount.formatted)
    }

    func testSubmitWithAnalyticsEnabledShouldSetCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        let expectedCheckoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        analyticsProviderMock.underlyingCheckoutAttemptId = expectedCheckoutAttemptId
        let paymentMethodDetails = ApplePayDetails(paymentMethod: paymentMethod,
                                                   token: "test_token",
                                                   network: "test_network",
                                                   billingContact: nil,
                                                   shippingContact: nil,
                                                   shippingMethod: nil)
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails,
                                                        amount: nil,
                                                        order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        sut.didSubmit(paymentComponentData, from: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertEqual(expectedCheckoutAttemptId, data.checkoutAttemptId)
        }
    }

    func testSubmitWithAnalyticsDisabledShouldNotSetCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        analyticsProviderMock.underlyingCheckoutAttemptId = nil
        let paymentMethodDetails = ApplePayDetails(paymentMethod: paymentMethod,
                                                   token: "test_token",
                                                   network: "test_network",
                                                   billingContact: nil,
                                                   shippingContact: nil,
                                                   shippingMethod: nil)
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails,
                                                        amount: nil,
                                                        order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        sut.didSubmit(paymentComponentData, from: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNil(data.checkoutAttemptId)
        }
    }
}
