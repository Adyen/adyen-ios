//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import XCTest

class SEPADirectDebitComponentTests: XCTestCase {

    var context: AdyenContext!
    let method = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "test_name")

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }

    func testRequiresKeyboardInput() {
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() throws {
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)
        
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithZeroPayment() throws {
        let payment = Payment(amount: Amount(value: 0, currencyCode: "EUR"), countryCode: "DE")
        let context = Dummy.context(with: payment)
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)

        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedString(.confirmPreauthorization, sut.configuration.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)
        
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        XCTAssertEqual(sut.nameItem.title, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_invalid"), sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_invalid"), sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, sut.configuration.localizationParameters))
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
        
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let configuration = SEPADirectDebitComponent.Configuration(style: sepaComponentStyle)
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod,
                                           context: context,
                                           configuration: configuration)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .milliseconds(300))
        
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
        
    }
    
    func testBigTitle() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, sepaPaymentMethod.name)
    }
    
    func testRequiresModalPresentation() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testStopLoading() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))
        
        XCTAssertFalse(sut.button.showsActivityIndicator)
        sut.button.showsActivityIndicator = true
        sut.stopLoadingIfNeeded()
        XCTAssertFalse(sut.button.showsActivityIndicator)
    }

    func testEmptyFieldsValidation() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
        let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        XCTAssertEqual(nameItemView?.alertLabel.text, "Holder name invalid")
        XCTAssertEqual(ibanItemView?.alertLabel.text, "Invalid account number")

    }

    func testSubmission() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

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

        wait(for: .milliseconds(300))
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
        let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")

        self.populate(textItemView: ibanItemView!, with: "NL13TEST0123456789")
        self.populate(textItemView: nameItemView!, with: "A. Klaassen")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let mockViewController = UIViewController()
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod,
                                           context: context)

        // When
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
