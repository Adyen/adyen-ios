//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

final class BLIKComponentUITests: XCTestCase {

    private let payment = Payment(amount: Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
    private var paymentMethod: BLIKPaymentMethod { BLIKPaymentMethod(type: .blik, name: "test_name") }
    private var context: AdyenContext { AdyenContext(apiContext: Dummy.apiContext, payment: payment) }

    func testUIConfiguration() {
        var style = FormComponentStyle()

        style.hintLabel.backgroundColor = .brown
        style.hintLabel.font = .systemFont(ofSize: 10)
        style.hintLabel.textAlignment = .center
        style.hintLabel.color = .cyan

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// background color
        style.backgroundColor = .red

        /// Text field
        style.textField.text.color = .red
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let config = BLIKComponent.Configuration(style: style)
        let sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() throws {
        let config = BLIKComponent.Configuration(style: .init())
        let sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)

        let submitButton: SubmitButton = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button"))

        let blikCodeView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
        self.populate(textItemView: blikCodeView, with: "123456")

        let delegateExpectation = XCTestExpectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        delegate.didSubmitClosure = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is BLIKDetails)
            let data = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(data.blikCode, "123456")

            sut.stopLoadingIfNeeded()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
            
            self.wait(for: .aMoment)
            self.assertViewControllerImage(matching: sut.viewController, named: "blik_flow")
            
            delegateExpectation.fulfill()
        }
        
        submitButton.sendActions(for: .touchUpInside)
        
        wait(for: [delegateExpectation], timeout: 120)
    }

    func testSubmitButtonLoading() throws {
        let config = BLIKComponent.Configuration(style: .init())
        let sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)

        setupRootViewController(sut.viewController)
        
        let submitButton: SubmitButton = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button"))
        
        endEditing(for: sut.viewController.view)
        
        try withoutAnimation {
            // start loading
            submitButton.showsActivityIndicator = true
            wait(until: submitButton, at: \.showsActivityIndicator, is: true)
            assertViewControllerImage(matching: sut.viewController, named: "initial_state")
            
            // stop loading
            sut.stopLoading()
            submitButton.showsActivityIndicator = false
            
            wait(until: submitButton, at: \.showsActivityIndicator, is: false)
            assertViewControllerImage(matching: sut.viewController, named: "stopped_loading")
        }
    }
}
