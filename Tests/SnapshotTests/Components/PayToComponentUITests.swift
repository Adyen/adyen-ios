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
    private var context: AdyenContext { Dummy.context }
    private var style: FormComponentStyle { FormComponentStyle() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    func test_UI_configuration() throws {
        var style = style
        style.backgroundColor = .green

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .center
        style.textField.placeholderText = TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: .systemOrange,
            textAlignment: .center
        )

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 18)
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

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .center
        style.textField.placeholderText = TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: .systemOrange,
            textAlignment: .center
        )

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 18)
        style.textField.title.textAlignment = .left
        style.textField.backgroundColor = .blue

        /// segmentedControlStyle
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

        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)

        self.wait(for: .aMoment)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration_segment_One")
    }

    func test_UI_elements_for_PayId_flowType() {
        // Assert
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
            XCTAssertEqual(details.accountIdentifier, "+614123466")
            XCTAssertEqual(details.shopperName?.firstName, "test")
            XCTAssertEqual(details.shopperName?.lastName, "lastname")

            sut.stopLoadingIfNeeded()
            self.wait(for: .aMoment)

            self.assertViewControllerImage(matching: sut.viewController, named: "payto_pay_id_flow")
            didSubmitExpectation.fulfill()
        }

        let identifierPickerItem: BaseFormPickerItemView<FormStringPickerElement> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))
        identifierPickerItem.select(value: BasePickerElement<FormStringPickerElement>(identifier: "identifierPickerItem", element: FormStringPickerElement(identifier: "Mobile", title: "Mobile")))

        try populateMobileNumberField(sut: sut)
        try populateShopperNameField(sut: sut)

        continueButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 10, handler: nil)
    }

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

        try populateBSBFields(sut: sut)
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
        identifierPickerItem.select(value: .init(identifier: "", element: FormStringPickerElement(identifier: "Email", title: "Email")))

        wait(for: .aMoment)

        wait { sut.phoneNumberItem.isVisible == false }
        wait(for: .aMoment)

        try populateEmailField(sut: sut)
        try populateShopperNameField(sut: sut)

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

    private func populateBSBFields(sut: PayToComponent) throws {
        let bankStateBranchInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.bankStateBranchTextfield"))
        let accountNumberInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.accountNumberTextfield"))

        self.populate(textItemView: bankStateBranchInputItem, with: "123456")
        self.populate(textItemView: accountNumberInputItem, with: "NLAB13343455")
    }

    private func populateShopperNameField(sut: PayToComponent) throws {
        let firstNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.firstNameTextfield"))
        let lastNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.lastNameTextfield"))

        self.populate(textItemView: firstNameInputItem, with: "test")
        self.populate(textItemView: lastNameInputItem, with: "lastname")
    }

}
