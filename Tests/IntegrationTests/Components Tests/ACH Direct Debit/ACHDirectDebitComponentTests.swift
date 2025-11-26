//
// Copyright (c) 2025 Adyen N.V.
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

    func testLocalizationWithCustomTableName() throws {
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")

        let config = ACHDirectDebitComponent.Configuration(
            localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil),
            billingAddressCountryCodes: ["US", "UK"]
        )
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
        
        XCTAssertEqual(sut.billingAddressItem.title, localizedString(.billingAddressSectionTitle, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.payButton.title, localizedSubmitButtonTitle(
            with: sut.payment?.amount,
            style: .immediate,
            sut.configuration.localizationParameters
        ))
    }
    
    func testUIConfiguration() throws {
        // Given
        let customColors = AdyenColors(container: .systemYellow, primary: .systemPink, highlight: .systemBlue)
        let customTheme = AdyenTheme(colors: customColors).primaryButton(backgroundColor: .systemRed, textColor: .white)

        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        var configuration = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
        configuration.theme = customTheme
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock()
        )

        // When
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // Then
        let view = sut.viewController.view
        let nameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem"))
        let nameItemViewTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem.titleLabel"))
        let nameItemViewTextField: UITextField = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem.textField"))
        let accountNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem"))
        let accountNumberItemTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem.titleLabel"))
        let accountNumberItemTextField: UITextField = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem.textField"))
        let routingNumberItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem"))
        let routingNumberItemTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem.titleLabel"))
        let routingNumberItemTextField: UITextField = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem.textField"))
        let payButtonItemView: FormButtonItemView = try XCTUnwrap(view?.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem"))

        XCTAssertNotNil(view?.findView(by: "AdyenComponents.ACHDirectDebitComponent.billingAddressItem"))

        XCTAssertEqual(nameItemViewTitleLabel.textColor, .systemPink)
        XCTAssertEqual(nameItemViewTextField.textColor, .systemPink)
        XCTAssertEqual(accountNumberItemTitleLabel.textColor, .systemPink)
        XCTAssertEqual(accountNumberItemTextField.textColor, .systemPink)
        XCTAssertEqual(routingNumberItemTitleLabel.textColor, .systemPink)
        XCTAssertEqual(routingNumberItemTextField.textColor, .systemPink)
        XCTAssertEqual(nameItemView.backgroundColor, .systemYellow)
        XCTAssertEqual(accountNumberItemView.backgroundColor, .systemYellow)
        XCTAssertEqual(routingNumberItemView.backgroundColor, .systemYellow)
        XCTAssertEqual(payButtonItemView.button.backgroundColor, .systemRed)
    }
    
    func testPrefillInfo() throws {
        // Given
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")
        let config = ACHDirectDebitComponent.Configuration(
            shopperInformation: shopperInformation,
            billingAddressCountryCodes: ["US", "UK"]
        )
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
        let config = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
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
    
    func testRequiresModalPresentation() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let config = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config,
            publicKeyProvider: PublicKeyProviderMock()
        )
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testStopLoading() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let config = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
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

        XCTAssertEqual(nameItemView?.alertLabel.text, "Invalid account holder name")
        XCTAssertEqual(accountNumberItemView?.alertLabel.text, "Invalid account number")
        XCTAssertEqual(routingNumberItemView?.alertLabel.text, "Invalid ABA routing number")
    }
    
    func testSubmission() throws {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(shopperInformation: shopperInformation, showsBillingAddress: false),
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

    func testViewDidLoadShouldSendInitialCall() throws {
        
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(showsBillingAddress: false),
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
        let configuration = ACHDirectDebitComponent.Configuration(showsBillingAddress: false)
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
        let configuration = ACHDirectDebitComponent.Configuration(
            showsSubmitButton: false,
            showsBillingAddress: false
        )
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
        let configuration = ACHDirectDebitComponent.Configuration(
            showsSubmitButton: false,
            showsBillingAddress: false
        )
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
