//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

final class BLIKComponentUITests: XCTestCase {

    private var paymentMethod: BLIKPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!
    private var sut: BLIKComponent!

    override func setUpWithError() throws {
        paymentMethod = BLIKPaymentMethod(type: .blik, name: "test_name")
        let payment = Payment(amount: Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
        context = AdyenContext(apiContext: Dummy.apiContext, payment: payment)
        style = FormComponentStyle()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        paymentMethod = nil
        context = nil
        style = nil
    }

    func testUIConfiguration() {
        style = FormComponentStyle()

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
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() {
        let config = BLIKComponent.Configuration(style: style)
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")

        let blikCodeView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
        self.populate(textItemView: blikCodeView, with: "123456")

        submitButton?.sendActions(for: .touchUpInside)

        let delegateExpectation = XCTestExpectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            XCTAssertTrue(data.paymentMethod is BLIKDetails)
            let data = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(data.blikCode, "123456")

            self.sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(self.sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(self.sut.button.showsActivityIndicator, false)
        }
        wait(for: .milliseconds(300))
        assertViewControllerImage(matching: sut.viewController, named: "blik_flow")
    }

    func testSubmitButtonLoading() {
        let config = BLIKComponent.Configuration(style: style)
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)

        UIApplication.shared.adyen.mainKeyWindow?.rootViewController = sut.viewController

        let submitButton: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")

        // start loading
        submitButton.showsActivityIndicator = true
        assertViewHeirarchy(matching: sut.viewController, named: "initial_state")

        // stop loading
        sut.stopLoading()
        submitButton.showsActivityIndicator = false
        assertViewHeirarchy(matching: sut.viewController, named: "stopped_loading")
    }
}
