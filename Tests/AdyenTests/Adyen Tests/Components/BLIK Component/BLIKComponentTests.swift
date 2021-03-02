//
//  BLIKComponentTests.swift
//  AdyenTests
//
//  Created by Vladimir Abramichev on 03/11/2020.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BLIKComponentTests: XCTestCase {

    lazy var method = BLIKPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
    var sut: BLIKComponent!

    override func setUp() {
        sut = BLIKComponent(paymentMethod: method)
        sut.payment = payment
    }

    override func tearDown() {
        sut = nil
    }

    func testLocalizationWithCustomTableName() {
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.hintLabelItem.text, ADYLocalizedString("adyen.blik.help", sut.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, ADYLocalizedString("adyen.blik.code", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, ADYLocalizedString("adyen.blik.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, ADYLocalizedString("adyen.blik.invalid", sut.localizationParameters))

        XCTAssertEqual(sut.button.title, ADYLocalizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testLocalizationWithZeroPayment() {
        let payment = Payment(amount: Payment.Amount(value: 0, currencyCode: "PLN"), countryCode: "PL")
        sut.payment = payment
        XCTAssertEqual(sut.hintLabelItem.text, ADYLocalizedString("adyen.blik.help", sut.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, ADYLocalizedString("adyen.blik.code", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, ADYLocalizedString("adyen.blik.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, ADYLocalizedString("adyen.blik.invalid", sut.localizationParameters))

        XCTAssertEqual(sut.button.title, ADYLocalizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.hintLabelItem.text, ADYLocalizedString("adyen_blik_help", sut.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, ADYLocalizedString("adyen_blik_code", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, ADYLocalizedString("adyen_blik_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, ADYLocalizedString("adyen_blik_invalid", sut.localizationParameters))

        XCTAssertEqual(sut.button.title, ADYLocalizedString("adyen_submitButton_formatted", sut.localizationParameters, payment.amount.formatted))
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

        sut = BLIKComponent(paymentMethod: method, style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let hintView: UILabel! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeHintLabel")

            let blikCodeView: FormTextInputItemView! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
            let blikCodeViewTitleLabel: UILabel! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem.titleLabel")
            let blikCodeViewTextField: UITextField! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem.textField")

            let payButtonItemViewButton: UIControl! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button.titleLabel")

            XCTAssertEqual(hintView.backgroundColor, .brown)
            XCTAssertEqual(hintView.textColor, .cyan)
            XCTAssertEqual(hintView.textAlignment, .center)
            XCTAssertEqual(hintView.font, .systemFont(ofSize: 10))

            /// Test BINK code field
            XCTAssertEqual(blikCodeView.backgroundColor, .red)
            XCTAssertEqual(blikCodeViewTitleLabel.textColor, self.sut.viewController.view.tintColor)
            XCTAssertEqual(blikCodeViewTitleLabel.backgroundColor, .blue)
            XCTAssertEqual(blikCodeViewTitleLabel.textAlignment, .center)
            XCTAssertEqual(blikCodeViewTitleLabel.font, .systemFont(ofSize: 20))
            XCTAssertEqual(blikCodeViewTextField.backgroundColor, .red)
            XCTAssertEqual(blikCodeViewTextField.textAlignment, .right)
            XCTAssertEqual(blikCodeViewTextField.textColor, .red)
            XCTAssertEqual(blikCodeViewTextField.font, .systemFont(ofSize: 13))

            /// Test footer
            XCTAssertEqual(payButtonItemViewButton.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle.font, .systemFont(ofSize: 22))

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSubmitForm() {
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            XCTAssertTrue(data.paymentMethod is BLIKDetails)
            let data = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(data.blikCode, "123456")

            self.sut.stopLoading {
                delegateExpectation.fulfill()
            }
            XCTAssertEqual(self.sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(self.sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let submitButton: UIControl? = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")

            let blikCodeView: FormTextInputItemView! = self.sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
            self.populate(textItemView: blikCodeView, with: "123456")

            submitButton?.sendActions(for: .touchUpInside)

            dummyExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    private func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }

    func testVCTitle() {

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(self.sut.viewController.title, self.method.name.uppercased())
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testRequiresModalPresentation() {
        let blikPaymentMethod = BLIKPaymentMethod(type: "blik", name: "Test name")
        let sut = BLIKComponent(paymentMethod: blikPaymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

}
