//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class SEPADirectDebitComponentTests: XCTestCase {
    
    func testLocalizationWithCustomTableName() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        XCTAssertEqual(sut.nameItem.title, ADYLocalizedString("adyen.sepa.nameItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, ADYLocalizedString("adyen.sepa.nameItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, ADYLocalizedString("adyen.sepa.nameItem.invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, ADYLocalizedString("adyen.sepa.ibanItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, ADYLocalizedString("adyen.sepa.ibanItem.invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.footerItem.title, ADYLocalizedString("adyen.sepa.consentLabel", sut.localizationParameters))
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = SEPADirectDebitPaymentMethod(type: "test_type", name: "test_name")
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        let sut = SEPADirectDebitComponent(paymentMethod: method)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        XCTAssertEqual(sut.nameItem.title, ADYLocalizedString("adyen_sepa_nameItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, ADYLocalizedString("adyen_sepa_nameItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, ADYLocalizedString("adyen_sepa_nameItem_invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, ADYLocalizedString("adyen_sepa_ibanItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, ADYLocalizedString("adyen_sepa_ibanItem_invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.footerItem.title, ADYLocalizedString("adyen_sepa_consentLabel", sut.localizationParameters))
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
    func testUIConfiguration() {
        var sepaComponentStyle = FormComponentStyle()
        
        /// Footer
        sepaComponentStyle.footer.button.title.color = .white
        sepaComponentStyle.footer.button.title.backgroundColor = .red
        sepaComponentStyle.footer.button.title.textAlignment = .center
        sepaComponentStyle.footer.button.title.font = .systemFont(ofSize: 22)
        sepaComponentStyle.footer.button.backgroundColor = .red
        sepaComponentStyle.footer.backgroundColor = .brown
        
        /// background color
        sepaComponentStyle.backgroundColor = .red
        
        /// Header
        sepaComponentStyle.header.backgroundColor = .magenta
        sepaComponentStyle.header.title.color = .white
        sepaComponentStyle.header.title.backgroundColor = .black
        sepaComponentStyle.header.title.textAlignment = .left
        sepaComponentStyle.header.title.font = .systemFont(ofSize: 30)
        
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
            let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.nameItem")
            let nameItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.nameItem.titleLabel")
            let nameItemViewTextField: UITextField? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.nameItem.textField")
            
            let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.ibanItem")
            let ibanItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.ibanItem.titleLabel")
            let ibanItemTextField: UITextField? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.ibanItem.textField")
            
            let footerItemViewButton: UIControl? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.footerItem.submitButton")
            let footerItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.footerItem.submitButton.titleLabel")
            
            let headerItemView: UIView? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.Test name")
            let headerItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "Adyen.SEPADirectDebitComponent.Test name.titleLabel")
            
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
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: "bcmc", name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod)
        sut.showsLargeTitle = false
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name"))
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
    
}
