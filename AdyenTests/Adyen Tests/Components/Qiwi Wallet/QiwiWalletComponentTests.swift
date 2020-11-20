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

    func testShowLargeTiteSetting() {
        let sut = QiwiWalletComponent(paymentMethod: method)

        sut.showsLargeTitle = true
        sut._isDropIn = true
        XCTAssertFalse(sut.showsLargeTitle)

        sut.showsLargeTitle = true
        sut._isDropIn = false
        XCTAssertTrue(sut._showsLargeTitle)

        sut.showsLargeTitle = false
        sut._isDropIn = false
        XCTAssertFalse(sut._showsLargeTitle)
    }
    
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
        
        XCTAssertEqual(sut.button.title, ADYLocalizedString("adyen.continueTo", sut.localizationParameters, method.name))
        XCTAssertTrue(sut.button.title!.contains(method.name))
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
        
        XCTAssertEqual(sut.button.title, ADYLocalizedString("adyen_continueTo", sut.localizationParameters, method.name))
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
            
            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.payButtonItem.button.titleLabel")
            
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
            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))
            
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

    func testSubmit() {
        let phoneExtensions = [PhoneExtension(value: "+3", countryCode: "UK")]
        let method = QiwiWalletPaymentMethod(type: "test_type", name: "test_name", phoneExtensions: phoneExtensions)
        let sut = QiwiWalletComponent(paymentMethod: method)
        let delegate = PaymentComponentDelegateMock()
        sut.showsLargeTitle = true
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is QiwiWalletDetails)
            let data = data.paymentMethod as! QiwiWalletDetails
            XCTAssertEqual(data.phonePrefix, "+3")
            XCTAssertEqual(data.phoneNumber, "7455573152")

            sut.stopLoading(withSuccess: true, completion: {
                delegateExpectation.fulfill()
            })
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.phoneNumberItem")

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "Adyen.QiwiWalletComponent.payButtonItem.button")

            self.populate(textItemView: phoneNumberView!, with: "7455573152")

            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    private func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }
    
}
