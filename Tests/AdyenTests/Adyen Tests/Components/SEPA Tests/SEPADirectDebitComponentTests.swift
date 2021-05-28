//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import XCTest

class SEPADirectDebitComponentTests: XCTestCase {

    func testRequiresKeyboardInput() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let sut = SEPADirectDebitComponent(paymentMethod: method)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testLocalizationWithZeroPayment() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Amount(value: 0, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment

        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.localizationParameters))

        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedString(.confirmPreauthorization, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        XCTAssertEqual(sut.nameItem.title, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_title"), sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_invalid"), sut.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_title"), sut.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_invalid"), sut.localizationParameters))
        
        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }
    
    func testUIConfiguration() {
        var sepaComponentStyle = FormComponentStyle()
        
        /// Footer
        sepaComponentStyle.mainButtonItem.button.title.color = .white
        sepaComponentStyle.mainButtonItem.button.title.backgroundColor = .red
        sepaComponentStyle.mainButtonItem.button.title.textAlignment = .center
        sepaComponentStyle.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        sepaComponentStyle.mainButtonItem.button.backgroundColor = .red
        sepaComponentStyle.mainButtonItem.backgroundColor = .brown
        
        /// background color
        sepaComponentStyle.backgroundColor = .red
        
        /// Text field
        sepaComponentStyle.textField.text.color = .red
        sepaComponentStyle.textField.text.font = .systemFont(ofSize: 13)
        sepaComponentStyle.textField.text.textAlignment = .right
        
        sepaComponentStyle.textField.title.backgroundColor = .blue
        sepaComponentStyle.textField.title.color = .yellow
        sepaComponentStyle.textField.title.font = .systemFont(ofSize: 20)
        sepaComponentStyle.textField.title.textAlignment = .center
        sepaComponentStyle.textField.backgroundColor = .red
        
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, style: sepaComponentStyle)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
            let nameItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem.titleLabel")
            let nameItemViewTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem.textField")
            
            let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")
            let ibanItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem.titleLabel")
            let ibanItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem.textField")
            
            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button.titleLabel")
            
            /// Test card number field
            XCTAssertEqual(nameItemView?.backgroundColor, .red)
            XCTAssertEqual(nameItemViewTitleLabel?.textColor, sut.viewController.view.tintColor)
            XCTAssertEqual(nameItemViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(nameItemViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(nameItemViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(nameItemViewTextField?.backgroundColor, .red)
            XCTAssertEqual(nameItemViewTextField?.textAlignment, .right)
            XCTAssertEqual(nameItemViewTextField?.textColor, .red)
            XCTAssertEqual(nameItemViewTextField?.font, .systemFont(ofSize: 13))
            
            /// Test IBAN field
            XCTAssertEqual(ibanItemView?.backgroundColor, .red)
            XCTAssertEqual(ibanItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(ibanItemTitleLabel?.textAlignment, .center)
            XCTAssertEqual(ibanItemTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(ibanItemTitleLabel?.textColor, .yellow)
            XCTAssertEqual(ibanItemTextField?.backgroundColor, .red)
            XCTAssertEqual(ibanItemTextField?.textAlignment, .right)
            XCTAssertEqual(ibanItemTextField?.textColor, .red)
            XCTAssertEqual(ibanItemTextField?.font, .systemFont(ofSize: 13))
            
            /// Test footer
            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testBigTitle() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, sepaPaymentMethod.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testRequiresModalPresentation() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testStopLoading() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertFalse(sut.button.showsActivityIndicator)
            sut.button.showsActivityIndicator = true
            sut.stopLoadingIfNeeded()
            XCTAssertFalse(sut.button.showsActivityIndicator)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testEmptyFieldsValidation() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
            let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
            let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")

            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            XCTAssertEqual(nameItemView?.alertLabel.text, "Holder name invalid")
            XCTAssertEqual(ibanItemView?.alertLabel.text, "Invalid account number")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSubmition() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is SEPADirectDebitDetails)
            let data = data.paymentMethod as! SEPADirectDebitDetails
            XCTAssertEqual(data.iban, "NL13TEST0123456789")
            XCTAssertEqual(data.ownerName, "A. Klaassen")
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
            let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
            let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")

            self.populate(textItemView: ibanItemView!, with: "NL13TEST0123456789")
            self.populate(textItemView: nameItemView!, with: "A. Klaassen")

            payButtonItemViewButton?.sendActions(for: .touchUpInside)
        }
        wait(for: [expectation], timeout: 5)
    }
    
}
