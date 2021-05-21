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
        let configuration = ApplePayComponent.Configuration(
            payment: payment,
            paymentMethod: ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil),
            summaryItems: createTestSummaryItems(),
            merchantIdentifier: "test_id"
        )
        sut = try! PreApplePayComponent(configuration: configuration)
    }
    
    func testUIConfiguration() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        let hintStyle = TextStyle(font: .systemFont(ofSize: 25, weight: .heavy), color: .brown, textAlignment: .justified)
        
        let model = PreApplePayView.Model(
            hint: amount.formatted,
            style: PreApplePayView.Model.Style(
                hintLabel: hintStyle, backgroundColor: .cyan
            )
        )
        
        let sut = PreApplePayView(model: model)
        let viewController = UIViewController()
        viewController.view = sut
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let hintLabel: UILabel? = viewController.view.findView(by: "hintLabel")
            XCTAssertEqual(hintLabel?.text, model.hint)
            XCTAssertEqual(hintLabel?.font, model.style.hintLabel.font)
            XCTAssertEqual(hintLabel?.textColor, model.style.hintLabel.color)
            XCTAssertEqual(hintLabel?.textAlignment, model.style.hintLabel.textAlignment)
            
            XCTAssertEqual(viewController.view.backgroundColor, model.style.backgroundColor)
            
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testApplePayPresented() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            UIApplication.shared.keyWindow?.rootViewController?.present(component: component)
        }
        sut.presentationDelegate = presentationMock
        
        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        
        XCTAssertNotNil(applePayButton)
        
        applePayButton?.sendActions(for: .primaryActionTriggered)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)
            
            dummyExpectation.fulfill()
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
