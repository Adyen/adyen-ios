//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
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

    func testRequiresKeyboardInput() throws {
        // Given
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)
        
        // When
        sut.viewController.loadViewIfNeeded()

        // Then
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<FormViewController>)
        let formViewController = securedViewController.childViewController
        XCTAssertTrue(formViewController.requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)
        
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: Dummy.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithZeroPayment() {
        let zeroAmount = Amount(value: 0, currencyCode: "EUR")
        let context = Dummy.context(with: zeroAmount)
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)

        XCTAssertEqual(sut.nameItem.title, localizedString(.sepaNameItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(.sepaNameItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(.sepaNameItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.ibanItem.title, localizedString(.sepaIbanItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(.sepaIbanItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: zeroAmount, style: .immediate, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedString(.confirmPreauthorization, sut.configuration.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let sut = SEPADirectDebitComponent(paymentMethod: method, context: context)
        
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        XCTAssertEqual(sut.nameItem.title, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.placeholder, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.nameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_nameItem_invalid"), sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.ibanItem.title, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.ibanItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_sepa_ibanItem_invalid"), sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: Dummy.amount, style: .immediate, sut.configuration.localizationParameters))
    }
    
    func testUIConfiguration() throws {
        // Given - use TestTheme helper for distinctive, verifiable styling
        var configuration = SEPADirectDebitComponent.Configuration()
        configuration.theme = TestTheme.distinctive()

        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(
            paymentMethod: sepaPaymentMethod,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // MARK: - Assert text fields use theme styling

        let prefix = "AdyenComponents.SEPADirectDebitComponent"
        try sut.viewController.assertTextFieldsUseTheme(
            [
                "\(prefix).nameItem",
                "\(prefix).ibanItem"
            ],
            style: TestTheme.expectedTextFieldStyle
        )

        // MARK: - Assert pay button uses theme styling

        try sut.viewController.assertButtonUsesTheme(
            "\(prefix).payButtonItem",
            style: TestTheme.expectedButtonStyle
        )
    }

    func testBigTitle() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)
        
        setupRootViewController(sut.viewController)
        
        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, sepaPaymentMethod.name)
    }

    func testStopLoading() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        XCTAssertFalse(sut.button.showsActivityIndicator)
        sut.button.showsActivityIndicator = true
        sut.stopLoading()
        XCTAssertFalse(sut.button.showsActivityIndicator)
    }

    func testEmptyFieldsValidation() {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.payButtonItem.button")
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem")
        let ibanItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        XCTAssertEqual(nameItemView?.footerLabel.text, "Holder name invalid")
        XCTAssertEqual(ibanItemView?.footerLabel.text, "Invalid account number")

    }

    func testSubmission() throws {
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(paymentMethod: sepaPaymentMethod, context: context)

        setupRootViewController(sut.viewController)

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

        try self.populate(textItemView: XCTUnwrap(ibanItemView), with: "NL13TEST0123456789")
        try self.populate(textItemView: XCTUnwrap(nameItemView), with: "A. Klaassen")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)
        
        wait(for: [expectation], timeout: 5)
    }

    func testViewDidLoadShouldSendInitialCall() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let mockViewController = UIViewController()
        let sepaPaymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(
            paymentMethod: sepaPaymentMethod,
            context: context
        )

        // When
        sut.viewDidLoad(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    func testSubmitShouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let paymentMethod = SEPADirectDebitPaymentMethod(type: .sepaDirectDebit, name: "Test name")
        let sut = SEPADirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            didSubmitExpectation.fulfill()
        }

        let ibanItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.ibanItem"))
        let nameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.SEPADirectDebitComponent.nameItem"))

        self.populate(textItemView: ibanItemView, with: "NL13TEST0123456789")
        self.populate(textItemView: nameItemView, with: "A. Klaassen")

        // When
        sut.performSubmit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }
}
