//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class BoletoComponentTests: XCTestCase {

    private var method = BoletoPaymentMethod(type: .boletoBancarioSantander, name: "Boleto Bancario")
    
    func testFullPrefilledInfo() throws {
        // Given

        let prefilledInformation = Dummy.dummyFullPrefilledInformation
        let brazilSocialSecurityNumberFormatter = BrazilSocialSecurityNumberFormatter()
        let context = Dummy.context(analyticsProvider: AnalyticsProviderMock())

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
        let formattedSocialSecurityNumber = try brazilSocialSecurityNumberFormatter.formattedValue(for: XCTUnwrap(prefilledInformation.socialSecurityNumber))
        XCTAssertEqual(socialSecurityNumberField.text, formattedSocialSecurityNumber)
        XCTAssertEqual(emailField.text, prefilledInformation.emailAddress)
        XCTAssertEqual(addressField.item.value, Dummy.dummyAddress)
    }

    func testNoPrefilledInformation() throws {

        let context = Dummy.context(analyticsProvider: AnalyticsProviderMock())

        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(showEmailAddress: true)
        )

        let viewController = component.viewController

        setupRootViewController(viewController)

        XCTAssertNotNil(viewController.view.findView(by: "firstNameItem.textField") as? UITextField)
        XCTAssertNotNil(viewController.view.findView(by: "lastNameItem.textField") as? UITextField)
        XCTAssertNotNil(viewController.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField)
        XCTAssertNotNil(viewController.view.findView(by: "emailItem.textField") as? UITextField)

        let addressField: FormAddressPickerItemView = try XCTUnwrap(viewController.view.findView(by: "addressItem"))
        XCTAssertNil(addressField.item.value)
    }

    func testNoEmailSection() {

        let context = Dummy.context(analyticsProvider: AnalyticsProviderMock())

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

    func testEmailFieldHiding() throws {

        let context = Dummy.context(analyticsProvider: AnalyticsProviderMock())

        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true)
        )

        let viewController = component.viewController

        setupRootViewController(viewController)

        let emailSwitchItem: FormToggleItemView = try XCTUnwrap(viewController.view.findView(by: "sendCopyToEmailItem") as? FormToggleItemView)
        let emailSwitch: UISwitch = try XCTUnwrap(emailSwitchItem.findView(by: "sendCopyToEmailItem.switch") as? UISwitch)
        let emailItem: FormItemView = try XCTUnwrap(viewController.view.findView(by: "emailItem") as? FormTextItemView<FormTextInputItem>)

        // Test that email switch has false by default
        XCTAssertFalse(emailSwitch.isOn)

        // Test that email field is hidden
        XCTAssertTrue(emailItem.isHidden)

        emailSwitchItem.accessibilityActivate()

        wait(for: .milliseconds(10))

        // Test that email field is visible
        XCTAssertFalse(emailItem.isHidden)
    }

    func testSubmitShouldCallPaymentComponentDelegateDidSubmit() throws {
        // Given
        let context = Dummy.context(analyticsProvider: AnalyticsProviderMock())
        let configuration = BoletoComponent.Configuration(shopperInformation: nil, showEmailAddress: false)
        let sut = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        let firstNameItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.viewController.view.findView(by: ViewIdentifier.firstNameItem)
        )
        populate(textItemView: firstNameItem, with: "Katrina")

        let lastNameItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.viewController.view.findView(by: ViewIdentifier.lastNameItem)
        )
        populate(textItemView: lastNameItem, with: "Del Mar")

        let socialSecurityNumberItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.viewController.view.findView(by: ViewIdentifier.socialSecurityNumberItem)
        )
        populate(textItemView: socialSecurityNumberItem, with: "351.843.385-78")

        let addressPickerItem: FormAddressPickerItemView = try XCTUnwrap(
            sut.viewController.view.findView(
                by: ViewIdentifier.addressItem
            )
        )
        addressPickerItem.item.value = PostalAddressMocks.newYorkPostalAddress

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }

    func test_shopperDetails_afterReturningToForm_shouldKeepPrefilledValues() throws {
        // Given
        let prefilledInformation = Dummy.dummyFullPrefilledInformation
        let form = try makeSUT(shopperInformation: prefilledInformation)

        // When
        form.navigateAwayAndBack()

        // Then
        let formattedSocialSecurityNumber = try BrazilSocialSecurityNumberFormatter().formattedValue(for: XCTUnwrap(prefilledInformation.socialSecurityNumber))
        XCTAssertEqual(form.socialSecurityNumberText, formattedSocialSecurityNumber)
        XCTAssertEqual(form.emailText, prefilledInformation.emailAddress)
    }

    func test_shopperDetails_afterReturningToForm_shouldKeepEditedValues() throws {
        // Given
        let form = try makeSUT(shopperInformation: Dummy.dummyFullPrefilledInformation)

        // initially form contains the prefilled information
        XCTAssertEqual(form.email, Dummy.dummyFullPrefilledInformation.emailAddress)
        XCTAssertEqual(form.socialSecurityNumber, Dummy.dummyFullPrefilledInformation.socialSecurityNumber)

        form.enableEmailCopy()
        form.enterEmail("edited@adyen.com")
        let editedEmail = form.email

        form.enterSocialSecurityNumber("35184338578")
        let editedSocialSecurityNumber = form.socialSecurityNumber

        // When
        form.navigateAwayAndBack()

        // Then form contains the edited values.
        XCTAssertTrue(form.isEmailCopyEnabled)
        XCTAssertEqual(form.email, editedEmail)
        XCTAssertEqual(form.socialSecurityNumber, editedSocialSecurityNumber)
    }

    func testViewDidLoadShouldSendInitialCall() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)

        let component = BoletoComponent(
            paymentMethod: method,
            context: context,
            configuration: Dummy.getConfiguration(with: Dummy.dummyFullPrefilledInformation, showEmailAddress: true)
        )

        // When
        component.viewDidLoad(viewController: component.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    // MARK: - Private

    private func makeSUT(
        shopperInformation: PrefilledShopperInformation? = nil,
        showEmailAddress: Bool = true
    ) throws -> FormDriver {
        let sut = BoletoComponent(
            paymentMethod: method,
            context: Dummy.context(analyticsProvider: AnalyticsProviderMock()),
            configuration: Dummy.getConfiguration(with: shopperInformation, showEmailAddress: showEmailAddress)
        )
        let navigationController = UINavigationController(rootViewController: sut.viewController)
        setupRootViewController(navigationController)
        return try FormDriver(sut: sut, navigationController: navigationController) { [weak self] condition in
            self?.wait(until: condition, timeout: 2, retryInterval: .milliseconds(10))
        }
    }

    @MainActor
    private final class FormDriver {

        private let sut: BoletoComponent
        private let navigationController: UINavigationController
        private let waitUntil: (_ condition: () -> Bool) -> Void
        private let emailSwitchItem: FormToggleItemView
        private let emailItemView: FormTextItemView<FormTextInputItem>
        private let socialSecurityNumberItemView: FormTextItemView<FormTextInputItem>

        init(
            sut: BoletoComponent,
            navigationController: UINavigationController,
            waitUntil: @escaping (_ condition: () -> Bool) -> Void
        ) throws {
            self.sut = sut
            self.navigationController = navigationController
            self.waitUntil = waitUntil
            let view: UIView = sut.viewController.view
            self.emailSwitchItem = try XCTUnwrap(view.findView(by: "sendCopyToEmailItem") as? FormToggleItemView)
            self.emailItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.emailItem))
            self.socialSecurityNumberItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.socialSecurityNumberItem))
        }

        var isEmailCopyEnabled: Bool {
            emailSwitchItem.item.value
        }

        var email: String {
            emailItemView.item.value
        }

        var emailText: String? {
            emailItemView.textField.text
        }

        var socialSecurityNumber: String {
            socialSecurityNumberItemView.item.value
        }

        var socialSecurityNumberText: String? {
            socialSecurityNumberItemView.textField.text
        }

        func enableEmailCopy() {
            emailSwitchItem.accessibilityActivate()
            waitUntil { [weak self] in
                self?.emailSwitchItem.item.value == true
            }
        }

        func enterEmail(_ email: String) {
            emailItemView.textField.text = email
            emailItemView.textField.sendActions(for: .editingChanged)
        }

        func enterSocialSecurityNumber(_ socialSecurityNumber: String) {
            socialSecurityNumberItemView.textField.text = socialSecurityNumber
            socialSecurityNumberItemView.textField.sendActions(for: .editingChanged)
        }

        func navigateAwayAndBack() {
            let pushedViewController = UIViewController()
            navigationController.pushViewController(pushedViewController, animated: false)
            waitUntil { [weak self] in
                self?.navigationController.topViewController === pushedViewController
            }
            navigationController.popViewController(animated: false)
            waitUntil { [weak self] in
                guard let self else { return false }
                return navigationController.topViewController === sut.viewController
                    && sut.viewController.viewIfLoaded?.window != nil
            }
        }
    }

    private enum ViewIdentifier {
        static let firstNameItem = "firstNameItem"
        static let lastNameItem = "lastNameItem"
        static let emailItem = "emailItem"
        static let socialSecurityNumberItem = "socialSecurityNumberItem"
        static let addressItem = "addressItem"
    }
}
