//
//  SevenElevenComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/18/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen
@testable import AdyenComponents

class SevenElevenComponentTests: XCTestCase {

    lazy var method = SevenElevenPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "IDR"), countryCode: "ID")

    func testLocalizationWithCustomTableName() {
        let sut = SevenElevenComponent(paymentMethod: method)
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
        let sut = SevenElevenComponent(paymentMethod: method)
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
        style.textField.backgroundColor = .cyan
        style.textField.text.color = .brown
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let sut = SevenElevenComponent(paymentMethod: method, style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            /// Test firstName field
            self.assertTextInputUI("AdyenComponents.SevenElevenComponent.firstNameItem",
                                   view: sut.viewController.view,
                                   style: style.textField,
                                   isFirstField: true)

            /// Test lastName field
            self.assertTextInputUI("AdyenComponents.SevenElevenComponent.lastNameItem",
                                   view: sut.viewController.view,
                                   style: style.textField,
                                   isFirstField: false)

            /// Test email field
            self.assertTextInputUI("AdyenComponents.SevenElevenComponent.emailItem",
                                   view: sut.viewController.view,
                                   style: style.textField,
                                   isFirstField: false)

            let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.phoneNumberItem")
            let phoneNumberViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.phoneNumberItem.titleLabel")
            let phoneNumberViewTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.phoneNumberItem.textField")

            /// Test submit button
            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.payButtonItem.button.titleLabel")

            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            /// Test phone number field
            XCTAssertEqual(phoneNumberView?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textColor, .yellow)
            XCTAssertEqual(phoneNumberViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(phoneNumberViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(phoneNumberViewTextField?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.textAlignment, .right)
            XCTAssertEqual(phoneNumberViewTextField?.textColor, .brown)
            XCTAssertEqual(phoneNumberViewTextField?.font, .systemFont(ofSize: 13))

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
        let sut = SevenElevenComponent(paymentMethod: method)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        sut.payment = payment

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is SevenElevenDetails)
            let data = data.paymentMethod as! SevenElevenDetails
            XCTAssertEqual(data.firstName, "Mohamed")
            XCTAssertEqual(data.lastName, "Smith")
            XCTAssertEqual(data.emailAddress, "mohamed.smith@domain.com")
            XCTAssertEqual(data.telephoneNumber, "+11233456789")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.payButtonItem.button")

            let firstNameView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.firstNameItem")
            self.populate(textItemView: firstNameView, with: "Mohamed")

            let lastNameView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.lastNameItem")
            self.populate(textItemView: lastNameView, with: "Smith")

            let emailView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.emailItem")
            self.populate(textItemView: emailView, with: "mohamed.smith@domain.com")

            let phoneNumberView: FormPhoneNumberItemView! = sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.phoneNumberItem")
            self.populate(textItemView: phoneNumberView, with: "1233456789")

            submitButton?.sendActions(for: .touchUpInside)

            dummyExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testBigTitle() {
        let sut = SevenElevenComponent(paymentMethod: method)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.SevenElevenComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.method.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testRequiresModalPresentation() {
        let paymentMethod = SevenElevenPaymentMethod(type: "test_type", name: "Test name")
        let sut = SevenElevenComponent(paymentMethod: paymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

}
