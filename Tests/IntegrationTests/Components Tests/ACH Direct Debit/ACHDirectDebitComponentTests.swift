//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
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

        let config = ACHDirectDebitComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil),
                                                           billingAddressCountryCodes: ["US", "UK"])
        let sut = ACHDirectDebitComponent(paymentMethod: method,
                                          context: context,
                                          configuration: config,
                                          publicKeyProvider: PublicKeyProviderMock())
        
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

        XCTAssertEqual(sut.payButton.title, localizedSubmitButtonTitle(with: sut.payment?.amount,
                                                                       style: .immediate,
                                                                       sut.configuration.localizationParameters))
    }
    
    func testUIConfiguration() {
        var achComponentStyle = FormComponentStyle()
        
        /// Footer
        achComponentStyle.mainButtonItem.button.title.color = .white
        achComponentStyle.mainButtonItem.button.title.backgroundColor = .red
        achComponentStyle.mainButtonItem.button.title.textAlignment = .center
        achComponentStyle.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        achComponentStyle.mainButtonItem.button.backgroundColor = .red
        achComponentStyle.mainButtonItem.backgroundColor = .brown
        
        /// background color
        achComponentStyle.backgroundColor = .red
        
        /// Text field
        achComponentStyle.textField.text.color = .red
        achComponentStyle.textField.text.font = .systemFont(ofSize: 13)
        achComponentStyle.textField.text.textAlignment = .right
        
        achComponentStyle.textField.title.backgroundColor = .blue
        achComponentStyle.textField.title.color = .yellow
        achComponentStyle.textField.title.font = .systemFont(ofSize: 20)
        achComponentStyle.textField.title.textAlignment = .center
        achComponentStyle.textField.backgroundColor = .red
        
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: .init(style: achComponentStyle,
                                                               billingAddressCountryCodes: ["US", "UK"]),
                                          publicKeyProvider: PublicKeyProviderMock())
        
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem")
        let nameItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem.titleLabel")
        let nameItemViewTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem.textField")
        
        let accountNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem")
        let accountNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem.titleLabel")
        let accountNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem.textField")
        
        let routingNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem")
        let routingNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem.titleLabel")
        let routingNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem.textField")
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem.button")
        let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem.button.titleLabel")
        
        XCTAssertNotNil(sut.viewController.view.findView(by: "AdyenComponents.ACHDirectDebitComponent.billingAddressItem"))
        
        /// holder name
        XCTAssertEqual(nameItemView?.backgroundColor, .red)
        XCTAssertEqual(nameItemViewTitleLabel?.backgroundColor, .blue)
        XCTAssertEqual(nameItemViewTitleLabel?.textAlignment, .center)
        XCTAssertEqual(nameItemViewTitleLabel?.font, .systemFont(ofSize: 20))
        XCTAssertEqual(nameItemViewTextField?.backgroundColor, .red)
        XCTAssertEqual(nameItemViewTextField?.textAlignment, .right)
        XCTAssertEqual(nameItemViewTextField?.textColor, .red)
        XCTAssertEqual(nameItemViewTextField?.font, .systemFont(ofSize: 13))
        
        /// account number
        XCTAssertEqual(accountNumberItemView?.backgroundColor, .red)
        XCTAssertEqual(accountNumberItemTitleLabel?.backgroundColor, .blue)
        XCTAssertEqual(accountNumberItemTitleLabel?.textAlignment, .center)
        XCTAssertEqual(accountNumberItemTitleLabel?.font, .systemFont(ofSize: 20))
        XCTAssertEqual(accountNumberItemTextField?.backgroundColor, .red)
        XCTAssertEqual(accountNumberItemTextField?.textAlignment, .right)
        XCTAssertEqual(accountNumberItemTextField?.textColor, .red)
        XCTAssertEqual(accountNumberItemTextField?.font, .systemFont(ofSize: 13))
        
        /// routing number
        XCTAssertEqual(routingNumberItemView?.backgroundColor, .red)
        XCTAssertEqual(routingNumberItemTitleLabel?.backgroundColor, .blue)
        XCTAssertEqual(routingNumberItemTitleLabel?.textAlignment, .center)
        XCTAssertEqual(routingNumberItemTitleLabel?.font, .systemFont(ofSize: 20))
        XCTAssertEqual(routingNumberItemTextField?.backgroundColor, .red)
        XCTAssertEqual(routingNumberItemTextField?.textAlignment, .right)
        XCTAssertEqual(routingNumberItemTextField?.textColor, .red)
        XCTAssertEqual(routingNumberItemTextField?.font, .systemFont(ofSize: 13))
        
        /// Test footer
        XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
        XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
        XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))
    }
    
    func testPrefillInfo() throws {
        // Given
        let method = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "test_name")
        let config = ACHDirectDebitComponent.Configuration(shopperInformation: shopperInformation,
                                                           billingAddressCountryCodes: ["US", "UK"])
        let sut = ACHDirectDebitComponent(paymentMethod: method,
                                          context: context,
                                          configuration: config,
                                          publicKeyProvider: PublicKeyProviderMock())
        
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
        let sut = ACHDirectDebitComponent(paymentMethod: method,
                                          context: context,
                                          configuration: config,
                                          publicKeyProvider: PublicKeyProviderMock())
        
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, method.name.uppercased())
    }
    
    func testRequiresModalPresentation() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let config = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: config,
                                          publicKeyProvider: PublicKeyProviderMock())
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testStopLoading() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let config = ACHDirectDebitComponent.Configuration(billingAddressCountryCodes: ["US", "UK"])
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: config,
                                          publicKeyProvider: PublicKeyProviderMock())

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        XCTAssertFalse(sut.payButton.showsActivityIndicator)
        sut.payButton.showsActivityIndicator = true
        sut.stopLoadingIfNeeded()
        XCTAssertFalse(sut.payButton.showsActivityIndicator)
    }

    func testEmptyFieldsValidation() {
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          publicKeyProvider: PublicKeyProviderMock())

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
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: .init(shopperInformation: shopperInformation, showsBillingAddress: false),
                                          publicKeyProvider: PublicKeyProviderMock())

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
        
        payButtonItemViewButton.didSelectSubmitButton()
        wait(until: payButtonItemViewButton, at: \.item.showsActivityIndicator, is: true)
        
        wait(for: [expectation], timeout: 100)
    }

    func testViewDidLoadShouldSendInitialCall() throws {
        
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(apiContext: Dummy.apiContext,
                                   payment: Dummy.payment,
                                   analyticsProvider: analyticsProviderMock)
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: .init(showsBillingAddress: false),
                                          publicKeyProvider: PublicKeyProviderMock())

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    func testSubmitWithDefaultSubmitHiddenShouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let configuration = ACHDirectDebitComponent.Configuration(showsSubmitButton: false,
                                                                  showsBillingAddress: false)
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: configuration,
                                          publicKeyProvider: PublicKeyProviderMock())

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

    func testSubmitWithDefaultSubmitShownShouldNotCallPaymentDelegateDidSubmit() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(apiContext: Dummy.apiContext,
                                   payment: Dummy.payment,
                                   analyticsProvider: analyticsProviderMock)
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")

        let configuration = ACHDirectDebitComponent.Configuration(showsSubmitButton: false)
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: configuration,
                                          publicKeyProvider: PublicKeyProviderMock())
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        // When
        sut.submit()

        // Then
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 0)
    }

    func testValidateWithValidInputSubmitShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod = ACHDirectDebitPaymentMethod(type: .achDirectDebit, name: "Test name")
        let configuration = ACHDirectDebitComponent.Configuration(showsSubmitButton: false,
                                                                  showsBillingAddress: false)
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: configuration,
                                          publicKeyProvider: PublicKeyProviderMock())

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
        let configuration = ACHDirectDebitComponent.Configuration(showsSubmitButton: false,
                                                                  showsBillingAddress: false)
        let sut = ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: configuration,
                                          publicKeyProvider: PublicKeyProviderMock())

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
