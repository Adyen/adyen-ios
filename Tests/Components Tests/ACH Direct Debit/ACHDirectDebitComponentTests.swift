//
//  ACHDirectDebitComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 1/19/22.
//  Copyright © 2022 Adyen. All rights reserved.
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
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
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
        
        XCTAssertEqual(sut.billingAddressItem.headerItem.text, localizedString(.billingAddressSectionTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.billingAddressItem.supportedCountryCodes, ["US", "UK"])

        XCTAssertEqual(sut.payButton.title, localizedString(.confirmPurchase, sut.configuration.localizationParameters))
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
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
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
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        // Then
        let view: UIView = sut.viewController.view
        
        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = view.findView(by: "AdyenComponents.ACHDirectDebitComponent.billingAddressItem")!
        let expectedBillingAddress = shopperInformation.billingAddress!
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
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
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

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
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

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
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
                                          configuration: .init(showsBillingAddress: false),
                                          publicKeyProvider: PublicKeyProviderMock())

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

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

        wait(for: .milliseconds(300))
        
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.payButtonItem.button")
        let nameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.holderNameItem")
        let accountNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankAccountNumberItem")
        let routingNumberItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.ACHDirectDebitComponent.bankRoutingNumberItem")

        self.populate(textItemView: nameItemView!, with: "test")
        self.populate(textItemView: accountNumberItemView!, with: "123456789")
        self.populate(textItemView: routingNumberItemView!, with: "121000358")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)
        
        wait(for: [expectation], timeout: 5)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        
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
        sut.viewWillAppear(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
