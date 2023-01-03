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
        let configuration = ApplePayComponent.Configuration(summaryItems: createTestSummaryItems(), merchantIdentifier: "test_id")
        var applePayStyle = ApplePayStyle()
        applePayStyle.paymentButtonType = .inStore
        sut = try! PreApplePayComponent(paymentMethod: ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil),
                                        apiContext: Dummy.context,
                                        payment: payment,
                                        configuration: configuration,
                                        style: applePayStyle)
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
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            UIApplication.shared.keyWindow?.rootViewController?.present(component: component)
        }
        sut.presentationDelegate = presentationMock
        
        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        
        XCTAssertNotNil(applePayButton)
        
        applePayButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))
        
        XCTAssertEqual(presentationMock.presentComponentCallsCount, 1)
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
    }

    func testApplePayDismissed() {
        guard Available.iOS12 else { return }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            UIApplication.shared.keyWindow?.rootViewController?.present(component: component)
        }

        presentationMock.doDismiss = { _ in
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        }

        sut.presentationDelegate = presentationMock

        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        applePayButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)

        sut.cancelIfNeeded()
        wait(for: .seconds(1))

        XCTAssertEqual(presentationMock.dismissComponentCallsCount, 1)
        XCTAssertFalse(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)

    }
    
    func testHintLabelAmount() {
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController?.present(component: sut)

        wait(for: .seconds(1))

        let hintLabel = sut.viewController.view.findView(by: "hintLabel") as? UILabel
        
        XCTAssertNotNil(hintLabel)
        XCTAssertEqual(hintLabel?.text, amount.formatted)
    }

    func testFinalise() {

        let dummyExpectation = expectation(description: "Dummy Expectation")
        sut.finalizeIfNeeded(with: true) {
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    private func createTestSummaryItems() -> [PKPaymentSummaryItem] {
        var amounts = (0...3).map { _ in
            NSDecimalNumber(mantissa: UInt64.random(in: 1...20), exponent: 1, isNegative: Bool.random())
        }
        // Positive Grand total
        amounts.append(NSDecimalNumber(mantissa: 20, exponent: 1, isNegative: false))
        return amounts.enumerated().map {
            PKPaymentSummaryItem(label: "summary_\($0)", amount: $1)
        }
    }
}
