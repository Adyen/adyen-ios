//
//  MBWayComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 7/31/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import XCTest

class MBWayComponentTests: XCTestCase {

    lazy var method = MBWayPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")

    func testLocalizationWithCustomTableName() {
        let sut = MBWayComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let expectedSelectableValues = [PhoneExtensionPickerItem(identifier: "PT", title: "+351", phoneExtension: "+351")]

        XCTAssertEqual(sut.phoneNumberItem.title, ADYLocalizedString("adyen.phoneNumber.title", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.placeholder, ADYLocalizedString("adyen.phoneNumber.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.validationFailureMessage, ADYLocalizedString("adyen.phoneNumber.invalid", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.prefix, "+351")
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.selectableValues, expectedSelectableValues)
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.value.identifier, "PT")

        XCTAssertEqual(sut.emailItem.title, ADYLocalizedString("adyen.emailItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem.placeholder, "shopper@domain.com")
        XCTAssertEqual(sut.emailItem.validationFailureMessage, ADYLocalizedString("adyen.emailItem.invalid", sut.localizationParameters))

        XCTAssertNil(sut.footerItem.title)
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedString("adyen.continueTo", sut.localizationParameters, method.name))
        XCTAssertTrue(sut.footerItem.submitButtonTitle!.contains(method.name))
    }

    func testLocalizationWithCustomKeySeparator() {
        let sut = MBWayComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        let expectedSelectableValues = [PhoneExtensionPickerItem(identifier: "PT", title: "+351", phoneExtension: "+351")]

        XCTAssertEqual(sut.phoneNumberItem.title, ADYLocalizedString("adyen_phoneNumber_title", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.placeholder, ADYLocalizedString("adyen_phoneNumber_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.validationFailureMessage, ADYLocalizedString("adyen_phoneNumber_invalid", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.prefix, "+351")
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.selectableValues, expectedSelectableValues)
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.value.identifier, "PT")

        XCTAssertEqual(sut.emailItem.title, ADYLocalizedString("adyen_emailItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.emailItem.placeholder, "shopper@domain.com")
        XCTAssertEqual(sut.emailItem.validationFailureMessage, ADYLocalizedString("adyen_emailItem_invalid", sut.localizationParameters))

        XCTAssertNil(sut.footerItem.title)
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedString("adyen_continueTo", sut.localizationParameters, method.name))
    }

    func testUIConfiguration() {
        var style = FormComponentStyle()

        /// Footer
        style.footer.button.title.color = .white
        style.footer.button.title.backgroundColor = .red
        style.footer.button.title.textAlignment = .center
        style.footer.button.title.font = .systemFont(ofSize: 22)
        style.footer.button.backgroundColor = .red
        style.footer.backgroundColor = .brown

        /// background color
        style.backgroundColor = .red

        /// Header
        style.header.backgroundColor = .magenta
        style.header.title.color = .white
        style.header.title.backgroundColor = .black
        style.header.title.textAlignment = .left
        style.header.title.font = .systemFont(ofSize: 30)

        /// Text field
        style.textField.text.color = .red
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let sut = MBWayComponent(paymentMethod: method, style: style)
        sut.showsLargeTitle = true

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.phoneNumberItem")
            let phoneNumberViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.phoneNumberItem.titleLabel")
            let phoneNumberViewTextField: UITextField? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.phoneNumberItem.textField")

            let phoneExtensionView: FormPhoneExtensionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FormPhoneNumberItem.phoneExtensionPickerItem")
            let phoneExtensionViewLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.FormPhoneNumberItem.phoneExtensionPickerItem.inputControl.label")

            let emailItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.emailItem")
            let emailItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.emailItem.titleLabel")
            let emailItemViewTextField: UITextField? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.emailItem.textField")

            let footerItemViewButton: UIControl? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.footerItem.submitButton")
            let footerItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.footerItem.submitButton.titleLabel")

            let headerItemView: UIView? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.test_name")
            let headerItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.MBWayComponent.test_name.titleLabel")

            /// Test phone number field
            XCTAssertEqual(phoneNumberView?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textColor, .yellow)
            XCTAssertEqual(phoneNumberViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(phoneNumberViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(phoneNumberViewTextField?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.textAlignment, .right)
            XCTAssertEqual(phoneNumberViewTextField?.textColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.font, .systemFont(ofSize: 13))

            /// Email item view.
            XCTAssertEqual(emailItemView?.backgroundColor, .red)
            XCTAssertEqual(emailItemViewTitleLabel?.textColor, sut.viewController.view.tintColor)
            XCTAssertEqual(emailItemViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(emailItemViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(emailItemViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(emailItemViewTextField?.backgroundColor, .red)
            XCTAssertEqual(emailItemViewTextField?.textAlignment, .right)
            XCTAssertEqual(emailItemViewTextField?.textColor, .red)
            XCTAssertEqual(emailItemViewTextField?.font, .systemFont(ofSize: 13))

            /// Test phone extension
            XCTAssertEqual(phoneExtensionView?.backgroundColor, .red)
            XCTAssertEqual(phoneExtensionViewLabel?.textAlignment, .right)
            XCTAssertEqual(phoneExtensionViewLabel?.textColor, .red)
            XCTAssertEqual(phoneExtensionViewLabel?.font, .systemFont(ofSize: 13))

            /// Test footer
            XCTAssertEqual(footerItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(footerItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(footerItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(footerItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(footerItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            /// Test header
            XCTAssertEqual(headerItemView?.backgroundColor, .magenta)
            XCTAssertEqual(headerItemViewTitleLabel?.backgroundColor, .black)
            XCTAssertEqual(headerItemViewTitleLabel?.textAlignment, .left)
            XCTAssertEqual(headerItemViewTitleLabel?.textColor, .white)
            XCTAssertEqual(headerItemViewTitleLabel?.font, .systemFont(ofSize: 30))

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testBigTitle() {
        let sut = MBWayComponent(paymentMethod: method)
        sut.showsLargeTitle = false

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.MBWayComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.method.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testRequiresModalPresentation() {
        let mbWayPaymentMethod = MBWayPaymentMethod(type: "mbway", name: "Test name")
        let sut = MBWayComponent(paymentMethod: mbWayPaymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

}
