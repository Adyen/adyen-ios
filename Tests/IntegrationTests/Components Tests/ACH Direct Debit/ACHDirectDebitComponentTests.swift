//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class ACHDirectDebitComponentTests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }
    
    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370"
        )
    }

    func testLocalizationWithCustomTableName() {
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")

        let config = ACHDirectDebitComponentConfiguration()
            .localizationParameters(LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil))
            .billingAddressCountryCodes(["US", "UK"])
        let sut = ACHDirectDebitComponent(
            paymentMethod: method,
            context: context,
            configuration: config,
            publicKeyProvider: PublicKeyProviderMock()
        )
        
        XCTAssertEqual(sut.headerItem.text, localizedString(.achBankAccountTitle, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.holderNameItem.title, localizedString(.achAccountHolderNameFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.placeholder, localizedString(.achAccountHolderNameFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.validationFailureMessage, localizedString(.achAccountHolderNameFieldInvalid, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.bankAccountNumberItem.title, localizedString(.achAccountNumberFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.bankAccountNumberItem.placeholder, localizedString(.achAccountNumberFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.bankAccountNumberItem.validationFailureMessage, localizedString(.achAccountNumberFieldInvalid, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.bankRoutingNumberItem.title, localizedString(.achAccountLocationFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.bankRoutingNumberItem.placeholder, localizedString(.achAccountLocationFieldTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.bankRoutingNumberItem.validationFailureMessage, localizedString(.achAccountLocationFieldInvalid, sut.configuration.localizationParameters))
        
        XCTAssertEqual(sut.billingAddressItem.title, localizedString(.addressFieldTitle, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.payButton.title, localizedSubmitButtonTitle(
            with: sut.payment?.amount,
            style: .immediate,
            sut.configuration.localizationParameters
        ))
    }
    
    func testUIConfiguration() throws {
        // Given - use TestTheme helper for distinctive, verifiable styling
        var configuration = ACHDirectDebitComponentConfiguration().billingAddressCountryCodes(["US", "UK"])
        configuration.theme = TestTheme.distinctive()

        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // MARK: - Assert text fields use theme styling

        let prefix = "AdyenComponents.ACHDirectDebitComponent"
        try sut.viewController.assertTextFieldsUseTheme(
            [
                "\(prefix).holderNameItem",
                "\(prefix).bankAccountNumberItem",
                "\(prefix).bankRoutingNumberItem"
            ],
            style: TestTheme.expectedTextFieldStyle
        )

        // MARK: - Assert pay button uses theme styling

        try sut.viewController.assertButtonUsesTheme(
            "\(prefix).payButtonItem",
            style: TestTheme.expectedButtonStyle
        )
    }

    func testPrefillInfo() throws {
        // Given
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")
        let config = ACHDirectDebitComponentConfiguration()
            .shopperInformation(shopperInformation)
            .billingAddressCountryCodes(["US", "UK"])
        let sut = ACHDirectDebitComponent(
            paymentMethod: method,
            context: context,
            configuration: config,
            publicKeyProvider: PublicKeyProviderMock()
        )
        
        setupRootViewController(sut.viewController)

        // Then
        let view: UIView = sut.viewController.view
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: "AdyenComponents.ACHDirectDebitComponent.billingAddressItem"))
        let expectedBillingAddress = shopperInformation.billingAddress
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
    }
    
    func testBigTitle() {
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")
        let config = ACHDirectDebitComponentConfiguration().billingAddressCountryCodes(["US", "UK"])
        let sut = ACHDirectDebitComponent(
            paymentMethod: method,
            context: context,
            configuration: config,
            publicKeyProvider: PublicKeyProviderMock()
        )
        
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, method.name.uppercased())
    }
    
    func testStopLoading() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let config = ACHDirectDebitComponentConfiguration().billingAddressCountryCodes(["US", "UK"])
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        XCTAssertFalse(sut.payButton.showsActivityIndicator)
        sut.payButton.showsActivityIndicator = true
        sut.stopLoading()
        XCTAssertFalse(sut.payButton.showsActivityIndicator)
    }

    func testEmptyFieldsValidation() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem.button")
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem")
        let accountNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem")
        let routingNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        XCTAssertEqual(nameItemView?.footerLabel.text, "Invalid account holder name")
        XCTAssertEqual(accountNumberItemView?.footerLabel.text, "Invalid account number")
        XCTAssertEqual(routingNumberItemView?.footerLabel.text, "Invalid ABA routing number")
    }
    
    func testSubmission() throws {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: ACHDirectDebitComponentConfiguration().shopperInformation(shopperInformation).showBillingAddress(false),
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)

        let expectation = XCTestExpectation(description: "Dummy Expectation")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is ACHDirectDebitDetails)
            let data = data.paymentMethod as! ACHDirectDebitDetails
            XCTAssertEqual(data.holderName, "test")
            XCTAssertNotNil(data.encryptedBankAccountNumber)
            XCTAssertNotNil(data.encryptedBankRoutingNumber)
            XCTAssertNotNil(data.billingAddress)
            expectation.fulfill()
        }
        
        let payButtonItemViewButton: FormButtonItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem"))
        let nameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem"))
        let accountNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem"))
        let routingNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem"))

        self.populate(textItemView: nameItemView, with: "test")
        self.populate(textItemView: accountNumberItemView, with: "123456789")
        self.populate(textItemView: routingNumberItemView, with: "121000358")

        wait(until: routingNumberItemView, at: \.textField.text, is: "121000358")
        
        payButtonItemViewButton.didTapButton()
        wait(until: payButtonItemViewButton, at: \.item.showsActivityIndicator, is: true)
        
        wait(for: [expectation], timeout: 100)
    }

    func testViewDidLoadShouldSendInitialCall() {
        
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: analyticsProviderMock
        )
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: ACHDirectDebitComponentConfiguration().showBillingAddress(false),
            publicKeyProvider: PublicKeyProviderMock()
        )

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    func testSubmitShouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let configuration = ACHDirectDebitComponentConfiguration().showBillingAddress(false)
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock
        paymentDelegateMock.onDidSubmit = { _, component in
            XCTAssertTrue(component === sut)
            didSubmitExpectation.fulfill()
        }

        let nameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem"))
        let accountNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem"))
        let routingNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem"))

        self.populate(textItemView: nameItemView, with: "test")
        self.populate(textItemView: accountNumberItemView, with: "123456789")
        self.populate(textItemView: routingNumberItemView, with: "121000358")

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 1)
    }

    func testValidateWithValidInputSubmitShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let configuration = ACHDirectDebitComponentConfiguration().showBillingAddress(false)
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)

        let nameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem"))
        let accountNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem"))
        let routingNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem"))

        self.populate(textItemView: nameItemView, with: "test")
        self.populate(textItemView: accountNumberItemView, with: "123456789")
        self.populate(textItemView: routingNumberItemView, with: "121000358")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateWithInvalidInputSubmitShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let configuration = ACHDirectDebitComponentConfiguration().showBillingAddress(false)
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock()
        )

        setupRootViewController(sut.viewController)

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }
}
