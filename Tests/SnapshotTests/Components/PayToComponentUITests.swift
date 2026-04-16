//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class PayToComponentUITests: XCTestCase {

    private lazy var paymentMethod: PayToPaymentMethod = .init(
        type: .payTo,
        name: "payto"
    )
    private var context: AdyenContext {
        Dummy.context
    }

    private var style: FormComponentStyle {
        FormComponentStyle()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    func test_UI_configuration() {
        var style = style
        style.backgroundColor = .green

        // Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 12)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        // Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .left
        style.textField.placeholderText = TextStyle(
            font: .preferredFont(forTextStyle: .caption2),
            color: .systemOrange,
            textAlignment: .left

        )

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 12)
        style.textField.title.textAlignment = .left
        style.textField.backgroundColor = .blue

        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        self.wait(for: .aMoment)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func test_UI_configuration_for_first_segment() throws {
        var style = style
        style.backgroundColor = .green

        // Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 12)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        // Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .center
        style.textField.placeholderText = TextStyle(
            font: .preferredFont(forTextStyle: .caption2),
            color: .systemOrange,
            textAlignment: .center
        )

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 12)
        style.textField.title.textAlignment = .left
        style.textField.backgroundColor = .blue

        // segmentedControlStyle
        style.segmentedControlStyle.tintColor = .yellow
        style.segmentedControlStyle.backgroundColor = .blue
        style.segmentedControlStyle.textStyle.backgroundColor = .systemPink
        style.segmentedControlStyle.textStyle.font = .systemFont(ofSize: 10)
        style.segmentedControlStyle.textStyle.textAlignment = .center
        style.segmentedControlStyle.textStyle.color = .red

        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        sut.viewController.loadViewIfNeeded()
        self.wait(for: .aMoment)

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)

        self.wait(for: .aMoment)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration_segment_One")
    }

    // MARK: - PayId flow tests

    func test_UI_elements_for_PayId_flowType() {
        // Assert
        var style = style
        style.textField.placeholderText?.color = .white
        style.textField.placeholderText?.font = .preferredFont(forTextStyle: .caption2)
        style.textField.text.textAlignment = .right
        style.textField.title.backgroundColor = .red
        style.textField.backgroundColor = .brown

        let config = PayToComponent.Configuration(style: style)
        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
        assertViewControllerImage(matching: sut.viewController, named: "all_required_fields_exist")
    }

    func test_payTo_component_details_for_pay_id_flow_using_mobile() throws {
        // Given
        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)

        wait(for: .aMoment)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        // Then
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton.button"))

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! PayToDetails
            XCTAssertEqual(details.type, .payTo)
            XCTAssertEqual(details.accountIdentifier, "+61-4123466")
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "pay_id_flow_mobile")
            didSubmitExpectation.fulfill()
        }

        let identifierPickerItem: BaseFormPickerItemView<FormStringPickerElement> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))
        identifierPickerItem.select(value: .init(
            identifier: localizedString(.paytoPayidOptionPhone, config.localizationParameters),
            element: FormStringPickerElement(
                identifier: localizedString(.paytoPayidOptionPhone, config.localizationParameters),
                title: localizedString(.paytoPayidOptionPhone, config.localizationParameters)
            )
        ))
        sut.selectedPaymentOption = .payId(.phone)

        wait(for: .aMoment)

        wait { sut.phoneNumberItem.isVisible == true }
        wait(for: .aMoment)

        try populateMobileNumberField(sut: sut)
        try populateShopperNameField(sut: sut)

        continueButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_payTo_component_details_for_pay_id_flow_using_email() throws {
        // Given
        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)

        wait(for: .aMoment)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        // Then
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton.button"))

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! PayToDetails
            XCTAssertEqual(details.type, .payTo)
            XCTAssertEqual(details.accountIdentifier, "test@adyen.com")
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "pay_id_flow_using_email")

            didSubmitExpectation.fulfill()
        }

        let identifierPickerItem: BaseFormPickerItemView<FormStringPickerElement> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))
        identifierPickerItem.select(value: .init(
            identifier: localizedString(.paytoPayidOptionEmail, config.localizationParameters),
            element: FormStringPickerElement(
                identifier: localizedString(.paytoPayidOptionEmail, config.localizationParameters),
                title: localizedString(.paytoPayidOptionEmail, config.localizationParameters)
            )
        ))
        sut.selectedPaymentOption = .payId(.email)

        wait(for: .aMoment)

        wait { sut.phoneNumberItem.isVisible == false }
        wait { sut.emailInputItem.isVisible == true }
        wait(for: .aMoment)

        try populateEmailField(sut: sut)
        try populateShopperNameField(sut: sut)

        wait(for: .aMoment)

        continueButton.sendActions(for: .touchUpInside)
        wait(for: [didSubmitExpectation], timeout: 10)
    }

    func test_payTo_component_details_for_pay_id_flow_using_abn() throws {
        // Given
        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)

        wait(for: .aMoment)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        // Then
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton.button"))

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! PayToDetails
            XCTAssertEqual(details.type, .payTo)
            XCTAssertEqual(details.accountIdentifier, "12345678900")
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "pay_id_flow_using_abn")

            didSubmitExpectation.fulfill()
        }

        let identifierPickerItem: BaseFormPickerItemView<FormStringPickerElement> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))
        identifierPickerItem.select(value: .init(
            identifier: localizedString(LocalizationKey(key: "ABN"), config.localizationParameters),
            element: FormStringPickerElement(
                identifier: localizedString(LocalizationKey(key: "ABN"), config.localizationParameters),
                title: localizedString(LocalizationKey(key: "ABN"), config.localizationParameters)
            )
        ))
        sut.selectedPaymentOption = .payId(.abn)

        wait(for: .aMoment)

        wait { sut.phoneNumberItem.isVisible == false }
        wait { sut.emailInputItem.isVisible == false }
        wait { sut.abnInputItem.isVisible == true }
        wait(for: .aMoment)

        try populateABNField(sut: sut)
        try populateShopperNameField(sut: sut)

        wait(for: .aMoment)

        continueButton.sendActions(for: .touchUpInside)
        wait(for: [didSubmitExpectation], timeout: 10)
    }

    func test_payTo_component_details_for_pay_id_flow_using_organizationId() throws {
        // Given
        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)

        wait(for: .aMoment)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        // Then
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton.button"))

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! PayToDetails
            XCTAssertEqual(details.type, .payTo)
            XCTAssertEqual(details.accountIdentifier, "123123")
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "pay_id_flow_using_organizationId")

            didSubmitExpectation.fulfill()
        }

        let identifierPickerItem: BaseFormPickerItemView<FormStringPickerElement> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))
        identifierPickerItem.select(value: .init(
            identifier: localizedString(.paytoPayidLabelOrgid, config.localizationParameters),
            element: FormStringPickerElement(
                identifier: localizedString(.paytoPayidLabelOrgid, config.localizationParameters),
                title: localizedString(.paytoPayidLabelOrgid, config.localizationParameters)
            )
        ))
        sut.selectedPaymentOption = .payId(.organizationId)

        wait(for: .aMoment)

        wait { sut.phoneNumberItem.isVisible == false }
        wait { sut.emailInputItem.isVisible == false }
        wait { sut.abnInputItem.isVisible == false }
        wait { sut.organizationIdInputItem.isVisible == true }
        wait(for: .aMoment)

        try populateOrganizationIdField(sut: sut)
        try populateShopperNameField(sut: sut)

        wait(for: .aMoment)

        continueButton.sendActions(for: .touchUpInside)
        wait(for: [didSubmitExpectation], timeout: 10)
    }

    // MARK: - BSB flow tests

    func test_payTo_component_details_for_bsb_flow() throws {
        // Given
        let config = PayToComponent.Configuration(style: style)

        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)

        wait(for: .aMoment)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        // Then
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton.button"))

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! PayToDetails
            XCTAssertEqual(details.type, .payTo)
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "payto_bsb_flow")
            didSubmitExpectation.fulfill()
        }

        sut.selectedPaymentOption = .BSB

        try populateShopperNameField(sut: sut)
        try populateBSBFields(sut: sut)

        wait(for: .aMoment)

        continueButton.sendActions(for: .touchUpInside)
        wait(for: [didSubmitExpectation], timeout: 10)
    }

    private func populateMobileNumberField(sut: PayToComponent) throws {
        let phoneNumberItem: FormPhoneNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.phoneNumberItem"))
        self.populate(textItemView: phoneNumberItem, with: "4123466")
    }

    private func populateEmailField(sut: PayToComponent) throws {
        let emailItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.emailTextfield"))
        self.populate(textItemView: emailItem, with: "test@adyen.com")
    }

    private func populateABNField(sut: PayToComponent) throws {
        let abnItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.abnTextfield"))
        self.populate(textItemView: abnItem, with: "12345678900")
    }

    private func populateOrganizationIdField(sut: PayToComponent) throws {
        let organizationIdItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.organizationIDTextfield"))
        self.populate(textItemView: organizationIdItem, with: "123123")
    }

    private func populateBSBFields(sut: PayToComponent) throws {
        let bankStateBranchInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.bankStateBranchTextfield"))
        let accountNumberInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.accountNumberTextfield"))

        self.populate(textItemView: bankStateBranchInputItem, with: "123456")
        self.populate(textItemView: accountNumberInputItem, with: "NLAB13343455")
        accountNumberInputItem.resignFirstResponder()
    }

    private func populateShopperNameField(sut: PayToComponent) throws {
        let firstNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.firstNameTextfield"))
        let lastNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.lastNameTextfield"))

        self.populate(textItemView: firstNameInputItem, with: "test")
        self.populate(textItemView: lastNameInputItem, with: "lastname")
    }

}
