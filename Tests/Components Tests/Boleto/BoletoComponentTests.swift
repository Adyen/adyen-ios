//
// Copyright (c) 2024 Adyen N.V.
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
        
        let firstNameField: UITextField = try XCTUnwrap(viewController.view.findView(by: "firstNameItem.textField"))
        let lastNameField: UITextField = try XCTUnwrap(viewController.view.findView(by: "lastNameItem.textField"))
        let socialSecurityNumberField: UITextField = try XCTUnwrap(viewController.view.findView(by: "socialSecurityNumberItem.textField"))
        let emailField: UITextField = try XCTUnwrap(viewController.view.findView(by: "emailItem.textField"))
        let addressField: FormAddressPickerItemView = try XCTUnwrap(viewController.view.findView(by: "addressItem"))
        
        setupRootViewController(viewController)
        
        XCTAssertEqual(firstNameField.text, prefilledInformation.shopperName?.firstName)
        XCTAssertEqual(lastNameField.text, prefilledInformation.shopperName?.lastName)
        let formattedSocialSecurityNumber = brazilSocialSecurityNumberFormatter.formattedValue(for: prefilledInformation.socialSecurityNumber!)
        XCTAssertEqual(socialSecurityNumberField.text, formattedSocialSecurityNumber)
        XCTAssertEqual(emailField.text, prefilledInformation.emailAddress)
        XCTAssertEqual(addressField.item.value, Dummy.dummyAddress)
    }
    
    func testNoPrefilledInformation() throws {
        
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(showEmailAddress: true)
        )
        
        let viewController = component.viewController
        
        setupRootViewController(viewController)
        
        let firstNameField: UITextField? = viewController.view.findView(by: "firstNameItem.textField") as? UITextField
        let lastNameField: UITextField? = viewController.view.findView(by: "lastNameItem.textField") as? UITextField
        let socialSecurityNumberField: UITextField? = viewController.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
        let emailField: UITextField? = viewController.view.findView(by: "emailItem.textField") as? UITextField

        let addressField: FormAddressPickerItemView = try XCTUnwrap(viewController.view.findView(by: "addressItem"))
        XCTAssertNil(addressField.item.value)
    }
    
    func testNoEmailSection() {
        
        let context = Dummy.context(with: AnalyticsProviderMock())
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(showEmailAddress: false)
        )
        
        let viewController = component.viewController
        
        setupRootViewController(viewController)
        
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
        
        setupRootViewController(viewController)
        
        let emailSwitchItem: FormToggleItemView = viewController.view.findView(by: "sendCopyToEmailItem") as! FormToggleItemView
        let emailSwitch: UISwitch = emailSwitchItem.findView(by: "sendCopyToEmailItem.switch") as! UISwitch
        let emailItem: FormItemView = viewController.view.findView(by: "emailItem") as! FormTextItemView<FormTextInputItem>
        
        // Test that email switch has false by default
        XCTAssertFalse(emailSwitch.isOn)
        
        // Test that email field is hidden
        XCTAssertTrue(emailItem.isHidden)
        
        emailSwitchItem.accessibilityActivate()

        wait(for: .milliseconds(10))
        
        // Test that email field is visible
        XCTAssertFalse(emailItem.isHidden)
    }

    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        
        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true)
        )

        // When
        component.viewDidLoad(viewController: component.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infoCount, 1)
    }
}
