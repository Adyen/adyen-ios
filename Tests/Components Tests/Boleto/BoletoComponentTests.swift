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

    private var method = BoletoPaymentMethod(type: .boleto, name: "Boleto Bancario")
    
    func testFullPrefilledInfo() throws {
        // Given
        
        let prefilledInformation = Dummy.dummyFullPrefilledInformation
        let brazilSocialSecurityNumberFormatter = BrazilSocialSecurityNumberFormatter()
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: prefilledInformation, showEmailAddress: true)
        )
        
        let viewController = component.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        let firstNameField: UITextField? = viewController.view.findView(by: "firstNameItem.textField") as? UITextField
        let lastNameField: UITextField? = viewController.view.findView(by: "lastNameItem.textField") as? UITextField
        let socialSecurityNumberField: UITextField? = viewController.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
        let emailField: UITextField? = viewController.view.findView(by: "emailItem.textField") as? UITextField

        let streetField = viewController.view.findView(by: "addressItem.street.textField") as? UITextField
        let houseNumberField = viewController.view.findView(by: "addressItem.houseNumberOrName.textField") as? UITextField
        let cityField = viewController.view.findView(by: "addressItem.city.textField") as? UITextField
        let postalCodeField = viewController.view.findView(by: "addressItem.postalCode.textField") as? UITextField

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
        
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(showEmailAddress: true)
        )
        
        let viewController = component.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        let firstNameField: UITextField? = viewController.view.findView(by: "firstNameItem.textField") as? UITextField
        let lastNameField: UITextField? = viewController.view.findView(by: "lastNameItem.textField") as? UITextField
        let socialSecurityNumberField: UITextField? = viewController.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
        let emailField: UITextField? = viewController.view.findView(by: "emailItem.textField") as? UITextField

        let streetField = viewController.view.findView(by: "addressItem.street.textField") as? UITextField
        let houseNumberField = viewController.view.findView(by: "addressItem.houseNumberOrName.textField") as? UITextField
        let cityField = viewController.view.findView(by: "addressItem.city.textField") as? UITextField
        let postalCodeField = viewController.view.findView(by: "addressItem.postalCode.textField") as? UITextField

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
        
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(showEmailAddress: false)
        )
        
        let viewController = component.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        let emailSwitch: UISwitch? = viewController.view.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
        let emailField: UITextField? = viewController.view.findView(by: "emailItem.textField") as? UITextField
        
        // Test that email switch does not exist
        XCTAssertNil(emailSwitch)

        // Test that email field does not exist
        XCTAssertNil(emailField)
    }
    
    func testEmailFieldHiding() {
        
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true)
        )
        
        let viewController = component.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        let emailSwitchItem: FormToggleItemView? = viewController.view.findView(by: "sendCopyToEmailItem") as? FormToggleItemView
        
        XCTAssertNotNil(emailSwitchItem)
        
        let emailSwitch: UISwitch? = emailSwitchItem!.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
        let emailItem: FormItemView? = viewController.view.findView(by: "emailItem") as? FormTextItemView<FormTextInputItem>
        
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
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true)
        )

        // When
        component.viewWillAppear(viewController: component.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
