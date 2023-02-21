//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@testable import AdyenComponents
import XCTest

class BoletoComponentTests: XCTestCase {

    private var context: AdyenContext!

    private var sut: BoletoComponent!
    private var method = BoletoPaymentMethod(type: .boleto, name: "Boleto Bancario")

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = AdyenContext(apiContext: Dummy.apiContext, payment: Dummy.payment, analyticsProvider: AnalyticsProviderMock())
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }
    
    func testFullPrefilledInfo() throws {
        // Given
        let prefilledInformation = Dummy.dummyFullPrefilledInformation
        let brazilSocialSecurityNumberFormatter = BrazilSocialSecurityNumberFormatter()
        
        sut = BoletoComponent(paymentMethod: method,
                              context: context,
                              configuration: Dummy.getConfiguration(with: prefilledInformation, showEmailAddress: true))
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        wait(for: .milliseconds(300))
        
        let firstNameField: UITextField? = sutVC.view.findView(by: "firstNameItem.textField") as? UITextField
        let lastNameField: UITextField? = sutVC.view.findView(by: "lastNameItem.textField") as? UITextField
        let socialSecurityNumberField: UITextField? = sutVC.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
        let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField

        let streetField = sutVC.view.findView(by: "addressItem.street.textField") as? UITextField
        let houseNumberField = sutVC.view.findView(by: "addressItem.houseNumberOrName.textField") as? UITextField
        let cityField = sutVC.view.findView(by: "addressItem.city.textField") as? UITextField
        let postalCodeField = sutVC.view.findView(by: "addressItem.postalCode.textField") as? UITextField

        XCTAssertNotNil(firstNameField)
        XCTAssertEqual(firstNameField?.text, prefilledInformation.shopperName?.firstName)
        
        XCTAssertNotNil(lastNameField)
        XCTAssertEqual(lastNameField?.text, prefilledInformation.shopperName?.lastName)

        XCTAssertNotNil(socialSecurityNumberField)
        let formattedSocialSecurityNumber = brazilSocialSecurityNumberFormatter.formattedValue(for: prefilledInformation.socialSecurityNumber!)
        XCTAssertEqual(formattedSocialSecurityNumber, socialSecurityNumberField?.text)
        
        XCTAssertNotNil(emailField)
        XCTAssertEqual(emailField?.text, prefilledInformation.emailAddress)

        XCTAssertNotNil(streetField)
        XCTAssertEqual(streetField?.text, Dummy.dummyAddress.street)

        XCTAssertNotNil(houseNumberField)
        XCTAssertEqual(houseNumberField?.text, Dummy.dummyAddress.houseNumberOrName)

        XCTAssertNotNil(cityField)
        XCTAssertEqual(cityField?.text, Dummy.dummyAddress.city)

        XCTAssertNotNil(postalCodeField)
        XCTAssertEqual(postalCodeField?.text, Dummy.dummyAddress.postalCode)
    }
    
    func testNoPrefilledInformation() {
        sut = BoletoComponent(paymentMethod: method,
                              context: context,
                              configuration: Dummy.getConfiguration(showEmailAddress: true))
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        wait(for: .milliseconds(300))
        
        let firstNameField: UITextField? = sutVC.view.findView(by: "firstNameItem.textField") as? UITextField
        let lastNameField: UITextField? = sutVC.view.findView(by: "lastNameItem.textField") as? UITextField
        let socialSecurityNumberField: UITextField? = sutVC.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
        let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField

        let streetField = sutVC.view.findView(by: "addressItem.street.textField") as? UITextField
        let houseNumberField = sutVC.view.findView(by: "addressItem.houseNumberOrName.textField") as? UITextField
        let cityField = sutVC.view.findView(by: "addressItem.city.textField") as? UITextField
        let postalCodeField = sutVC.view.findView(by: "addressItem.postalCode.textField") as? UITextField

        XCTAssertNotNil(firstNameField)
        XCTAssertNil(firstNameField?.text?.adyen.nilIfEmpty)
        
        XCTAssertNotNil(lastNameField)
        XCTAssertNil(lastNameField?.text?.adyen.nilIfEmpty)
        
        XCTAssertNotNil(socialSecurityNumberField)
        XCTAssertNil(socialSecurityNumberField?.text?.adyen.nilIfEmpty)
        
        XCTAssertNotNil(emailField)
        XCTAssertNil(emailField?.text?.adyen.nilIfEmpty)

        XCTAssertNotNil(streetField)
        XCTAssertTrue(streetField?.text?.isEmpty ?? true)

        XCTAssertNotNil(houseNumberField)
        XCTAssertTrue(houseNumberField?.text?.isEmpty ?? true)

        XCTAssertNotNil(cityField)
        XCTAssertTrue(cityField?.text?.isEmpty ?? true)

        XCTAssertNotNil(postalCodeField)
        XCTAssertTrue(postalCodeField?.text?.isEmpty ?? true)
    }
    
    func testNoEmailSection() {
        sut = BoletoComponent(paymentMethod: method,
                              context: context,
                              configuration: Dummy.getConfiguration(showEmailAddress: false))
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        wait(for: .milliseconds(300))
        
        let emailSwitch: UISwitch? = sutVC.view.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
        let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField
        
        // Test that email switch does not exist
        XCTAssertNil(emailSwitch)

        // Test that email field does not exist
        XCTAssertNil(emailField)
    }
    
    func testEmailFieldHiding() {
        sut = BoletoComponent(paymentMethod: method,
                              context: context,
                              configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true))
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        wait(for: .milliseconds(300))
        
        let emailSwitchItem: FormToggleItemView? = sutVC.view.findView(by: "sendCopyToEmailItem") as? FormToggleItemView
        
        XCTAssertNotNil(emailSwitchItem)
        
        let emailSwitch: UISwitch? = emailSwitchItem!.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
        let emailItem: FormItemView? = sutVC.view.findView(by: "emailItem") as? FormTextItemView<FormTextInputItem>
        
        // Test that email switch has false by default
        XCTAssertNotNil(emailSwitch)
        XCTAssertFalse(emailSwitch!.isOn)
        
        // Test that email field is hidden
        XCTAssertNotNil(emailItem)
        XCTAssertTrue(emailItem!.isHidden)
        
        emailSwitchItem?.accessibilityActivate()

        // Test that email field is visible
        XCTAssertFalse(emailItem!.isHidden)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        sut = BoletoComponent(paymentMethod: method,
                              context: context,
                              configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true))

        // When
        sut.viewWillAppear(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
