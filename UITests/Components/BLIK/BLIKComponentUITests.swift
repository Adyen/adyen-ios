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
    
    private func createBLIKComponent(with config: BLIKComponent.Configuration = .init()) -> BLIKComponent {
        let paymentMethod = BLIKPaymentMethod(type: .blik, name: "test_name")
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
        )
        
        return BLIKComponent(paymentMethod: paymentMethod, context: context, configuration: config)
    }

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

        let sut = createBLIKComponent(with: .init(style: style))

        setupRootViewController(sut.viewController)
        wait(for: .aMoment)
        
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() throws {
        let sut = createBLIKComponent()

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)

        let submitButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button"))

        let blikCodeView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem"))
        
        populate(textItemView: blikCodeView, with: "123456")
        wait(until: blikCodeView, at: \.textField.text, is: "123456")
        
        submitButton.sendActions(for: .touchUpInside)

        let delegateExpectation = XCTestExpectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is BLIKDetails)
            let data = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(data.blikCode, "123456")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }
        
        wait(for: [delegateExpectation], timeout: 10)
        
        wait(for: .aMoment)
        
        assertViewControllerImage(matching: sut.viewController, named: "blik_flow")
    }

    func testSubmitButtonLoading() {
        let sut = createBLIKComponent()

        setupRootViewController(sut.viewController)

        let submitButton: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")

        // start loading
        submitButton.showsActivityIndicator = true
        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "initial_state")

        // stop loading
        sut.stopLoading()
        submitButton.showsActivityIndicator = false
        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "stopped_loading")
    }
}
