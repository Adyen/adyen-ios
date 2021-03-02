//
//  DokuComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 1/25/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class DokuComponentTests: XCTestCase {

    lazy var method = DokuPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "IDR"), countryCode: "ID")

    func testLocalizationWithCustomTableName() {
        let sut = DokuComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.firstNameItem?.title, ADYLocalizedString("adyen.firstName", sut.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, ADYLocalizedString("adyen.firstName", sut.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, ADYLocalizedString("adyen.lastName", sut.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, ADYLocalizedString("adyen.lastName", sut.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, ADYLocalizedString("adyen.emailItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, ADYLocalizedString("adyen.emailItem.placeHolder", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, ADYLocalizedString("adyen.emailItem.invalid", sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, ADYLocalizedString("adyen.confirmPurchase", sut.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        let sut = DokuComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.firstNameItem?.title, ADYLocalizedString("adyen_firstName", sut.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, ADYLocalizedString("adyen_firstName", sut.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, ADYLocalizedString("adyen_lastName", sut.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, ADYLocalizedString("adyen_lastName", sut.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, ADYLocalizedString("adyen_emailItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, ADYLocalizedString("adyen_emailItem_placeHolder", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, ADYLocalizedString("adyen_emailItem_invalid", sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, ADYLocalizedString("adyen_confirmPurchase", sut.localizationParameters))
    }

    func testUIConfiguration() {
        var style = FormComponentStyle()

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// background color
        style.backgroundColor = .yellow

        /// Text field
        style.textField.text.color = .brown
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let sut = DokuComponent(paymentMethod: method, style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            /// Test firstName field
            self.assertTextInputUI("AdyenComponents.DokuComponent.firstNameItem",
                     view: sut.viewController.view,
                     style: style.textField,
                     isFirstField: true)

            /// Test lastName field
            self.assertTextInputUI("AdyenComponents.DokuComponent.lastNameItem",
                     view: sut.viewController.view,
                     style: style.textField,
                     isFirstField: false)

            /// Test email field
            self.assertTextInputUI("AdyenComponents.DokuComponent.emailItem",
                     view: sut.viewController.view,
                     style: style.textField,
                     isFirstField: false)

            /// Test submit button
            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.payButtonItem.button.titleLabel")

            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    private func assertTextInputUI(_ identifier: String,
                                   view: UIView,
                                   style: FormTextItemStyle,
                                   isFirstField: Bool) {

        let textView: FormTextInputItemView? = view.findView(with: identifier)
        let textViewTitleLabel: UILabel? = view.findView(with: "\(identifier).titleLabel")
        let textViewTextField: UITextField? = view.findView(with: "\(identifier).textField")

        XCTAssertEqual(textView?.backgroundColor, .red)
        XCTAssertEqual(textViewTitleLabel?.textColor, isFirstField ? view.tintColor : style.title.color)
        XCTAssertEqual(textViewTitleLabel?.backgroundColor, style.title.backgroundColor)
        XCTAssertEqual(textViewTitleLabel?.textAlignment, style.title.textAlignment)
        XCTAssertEqual(textViewTitleLabel?.font, style.title.font)
        XCTAssertEqual(textViewTextField?.backgroundColor, style.backgroundColor)
        XCTAssertEqual(textViewTextField?.textAlignment, style.text.textAlignment)
        XCTAssertEqual(textViewTextField?.textColor, style.text.color)
        XCTAssertEqual(textViewTextField?.font, style.text.font)
    }

    func testSubmitForm() {
        let sut = DokuComponent(paymentMethod: method)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        sut.payment = payment

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is DokuDetails)
            let data = data.paymentMethod as! DokuDetails
            XCTAssertEqual(data.firstName, "Mohamed")
            XCTAssertEqual(data.lastName, "Smith")
            XCTAssertEqual(data.emailAddress, "mohamed.smith@domain.com")

            sut.stopLoading {
                delegateExpectation.fulfill()
            }
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.payButtonItem.button")

            let firstNameView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.firstNameItem")
            self.populate(textItemView: firstNameView, with: "Mohamed")

            let lastNameView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.lastNameItem")
            self.populate(textItemView: lastNameView, with: "Smith")

            let emailView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.emailItem")
            self.populate(textItemView: emailView, with: "mohamed.smith@domain.com")

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

    func testBigTitle() {
        let sut = DokuComponent(paymentMethod: method)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.DokuComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.method.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testRequiresModalPresentation() {
        let dokuPaymentMethod = DokuPaymentMethod(type: "doku_wallet", name: "Test name")
        let sut = DokuComponent(paymentMethod: dokuPaymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

}
