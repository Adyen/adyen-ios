//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class QiwiWalletComponentTests: XCTestCase {
    
    lazy var phoneExtensions = [PhoneExtension(value: "+1", countryCode: "US"), PhoneExtension(value: "+3", countryCode: "UK")]
    lazy var method = QiwiWalletPaymentMethod(type: "test_type", name: "test_name", phoneExtensions: phoneExtensions)
    let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
    
    func testLocalizationWithCustomTableName() {
        let sut = QiwiWalletComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let expectedSelectableValues = phoneExtensions.map {
            PhoneExtensionPickerItem(identifier: $0.countryCode,
                                     title: "\($0.countryDisplayName) (\($0.value))",
                                     phoneExtension: $0.value)
        }
        XCTAssertEqual(sut.selectableValues, expectedSelectableValues)
        
        XCTAssertEqual(sut.phoneNumberItem.title, ADYLocalizedString("adyen.phoneNumber.title", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.placeholder, ADYLocalizedString("adyen.phoneNumber.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.validationFailureMessage, ADYLocalizedString("adyen.phoneNumber.invalid", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.prefix, "+1")
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.selectableValues, expectedSelectableValues)
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.value.identifier, "US")
        
        XCTAssertNil(sut.footerItem.title)
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedString("adyen.continueTo", sut.localizationParameters, method.name))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let sut = QiwiWalletComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let expectedSelectableValues = phoneExtensions.map {
            PhoneExtensionPickerItem(identifier: $0.countryCode,
                                     title: "\($0.countryDisplayName) (\($0.value))",
                                     phoneExtension: $0.value)
        }
        XCTAssertEqual(sut.selectableValues, expectedSelectableValues)
        
        XCTAssertEqual(sut.phoneNumberItem.title, ADYLocalizedString("adyen_phoneNumber_title", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.placeholder, ADYLocalizedString("adyen_phoneNumber_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.validationFailureMessage, ADYLocalizedString("adyen_phoneNumber_invalid", sut.localizationParameters))
        XCTAssertEqual(sut.phoneNumberItem.prefix, "+1")
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.selectableValues, expectedSelectableValues)
        XCTAssertEqual(sut.phoneNumberItem.phonePrefixItem.value.identifier, "US")
        
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
        
        let sut = QiwiWalletComponent(paymentMethod: method, style: style)
        sut.showsLargeTitle = true
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.phoneNumberItem")
            let phoneNumberViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.phoneNumberItem.titleLabel")
            let phoneNumberViewTextField: UITextField? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.phoneNumberItem.textField")
            
            let phoneExtensionView: FormPhoneExtensionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FormPhoneNumberItem.phoneExtensionPickerItem")
            let phoneExtensionViewLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.FormPhoneNumberItem.phoneExtensionPickerItem.inputControl.label")
            
            let footerItemViewButton: UIControl? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.footerItem.submitButton")
            let footerItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.footerItem.submitButton.titleLabel")
            
            let headerItemView: UIView? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.test_name")
            let headerItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.test_name.titleLabel")
            
            /// Test phone number field
            XCTAssertEqual(phoneNumberView?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textColor, sut.viewController.view.tintColor)
            XCTAssertEqual(phoneNumberViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(phoneNumberViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(phoneNumberViewTextField?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.textAlignment, .right)
            XCTAssertEqual(phoneNumberViewTextField?.textColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.font, .systemFont(ofSize: 13))
            
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
        let sut = QiwiWalletComponent(paymentMethod: method)
        sut.showsLargeTitle = false
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.method.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testRequiresModalPresentation() {
        let qiwiPaymentMethod = QiwiWalletPaymentMethod(type: "qiwiwallet", name: "Test name")
        let sut = QiwiWalletComponent(paymentMethod: qiwiPaymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }
    
}
