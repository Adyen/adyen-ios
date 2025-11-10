//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class PayToComponentTests: XCTestCase {

    var sut: PayToComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )
    }

    func test_init() throws {
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        XCTAssertNotNil(sut)
    }

    func test_paymentMethodType_isPayto() throws {
        XCTAssertEqual(sut.paymentMethod.type, .payTo)
    }

    func test_flowSelection_titleLabel_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let flowSelectionTitleLabelItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionTitleLabel") as? UILabel

        // Then
        XCTAssertNotNil(flowSelectionTitleLabelItem, "Flow selection title label should exist")
    }

    func test_flowSelectionItem_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let flowSelectionItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.flowSelectionSegmentedControl") as? UISegmentedControl
        flowSelectionItem?.selectedSegmentIndex = 1

        // Then
        XCTAssertNotNil(flowSelectionItem, "Flow selection item should exist")
    }

    func test_phoneNumberItem_viewExists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // When
        let phoneNumberItem: FormPhoneNumberItemView = try XCTUnwrap(
            sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.phoneNumberItem")
        )

        // Then
        XCTAssertNotNil(phoneNumberItem, "Phone number item should exist")
    }

    func test_phoneNumberItem_invalidNumbers() throws {
        // Given
        let invalidNumbers = [
            "" // Empty phone number
        ]

        for number in invalidNumbers {
            // When
            sut.phoneNumberItem.value = number

            // Then
            XCTAssertFalse(sut.phoneNumberItem.isValid(), "Number \(number) should be invalid")
        }
    }

    func test_phoneNumberItem_validNumbers_withoutLeadingZero() throws {
        // Given
        let validNumbers = [
            "9",
            "10",
            "99",
            "01231",
            "41124123", // short AU mobile without leading zero
            "412345678", // common AU mobile number
            "434567890" // common AU mobile number
        ]

        for number in validNumbers {
            // When
            sut.phoneNumberItem.value = number

            // Then
            XCTAssertTrue(sut.phoneNumberItem.isValid(), "Number \(number) should be valid without leading zero")
        }
    }

    func test_phoneNumberItem_validNumbers_withLeadingZero() throws {
        // Given
        let validNumbersWithZero = [
            "041124123",
            "0412345678",
            "0434567890"
        ]

        for number in validNumbersWithZero {
            // When
            sut.phoneNumberItem.value = number

            // Then
            XCTAssertTrue(sut.phoneNumberItem.isValid(), "Number \(number) should be valid with leading zero")
        }
    }

    func test_payid_titleLabel_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let payIdTitleLabelItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.payIdFlowTitleTitleLabel") as? UILabel

        // Then
        XCTAssertNotNil(payIdTitleLabelItem, "PayId flow title label should exist")
    }

    func test_identifierPicker_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let identifierPickerItem: PayToFormPickerItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.identifierPicker"))

        // Then
        XCTAssertNotNil(identifierPickerItem, "identifier picker should exist")
        XCTAssertFalse(identifierPickerItem.canBecomeFirstResponder)
    }

    func test_firstname_textfield() throws {
        sut.firstNameInputItem.value = ""
        XCTAssertFalse(sut.firstNameInputItem.isValid())
        sut.firstNameInputItem.value = "test"
        XCTAssertTrue(sut.firstNameInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let firstNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.firstNameTextfield"))

        // Then
        XCTAssertNotNil(firstNameInputItem, "first name input field should exist")
    }

    func test_lastname_textfield() throws {
        sut.lastNameInputItem.value = ""
        XCTAssertFalse(sut.lastNameInputItem.isValid())
        sut.lastNameInputItem.value = "test"
        XCTAssertTrue(sut.lastNameInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let lastNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.lastNameTextfield"))

        // Then
        XCTAssertNotNil(lastNameInputItem, "last name input field should exist")
    }

    func test_email_textfield() throws {

        // invalid
        sut.emailInputItem.value = ""
        XCTAssertFalse(sut.emailInputItem.isValid())
        sut.emailInputItem.value = "test"
        XCTAssertFalse(sut.emailInputItem.isValid())
        sut.emailInputItem.value = "test@"
        XCTAssertFalse(sut.emailInputItem.isValid())
        sut.emailInputItem.value = "aa@aa.com"

        // valid
        XCTAssertTrue(sut.emailInputItem.isValid())
        sut.emailInputItem.value = "user@example.com"
        XCTAssertTrue(sut.emailInputItem.isValid())
        sut.emailInputItem.value = "test-test@example.co.uk"
        XCTAssertTrue(sut.emailInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let emailInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.emailTextfield"))

        // Then
        XCTAssertNotNil(emailInputItem, "email input field should exist")
    }

    func test_abn_textfield() throws {

        // only 9 or 11 integers are valid

        // invalid
        sut.abnInputItem.value = ""
        XCTAssertFalse(sut.abnInputItem.isValid())
        sut.abnInputItem.value = "12345678"
        XCTAssertFalse(sut.abnInputItem.isValid())
        sut.abnInputItem.value = "1234567890"
        XCTAssertFalse(sut.abnInputItem.isValid())
        sut.abnInputItem.value = "123asd123"
        XCTAssertFalse(sut.abnInputItem.isValid())
        sut.abnInputItem.value = "123456789"

        // valid
        XCTAssertTrue(sut.abnInputItem.isValid())
        sut.abnInputItem.value = "12345678900"
        XCTAssertTrue(sut.abnInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let abnInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.abnTextfield"))

        // Then
        XCTAssertNotNil(abnInputItem, "abn input field should exist")
    }

    func test_organizationID_textfield() throws {
        // invalid
        sut.organizationIdInputItem.value = ""
        XCTAssertFalse(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = " Hello"
        XCTAssertFalse(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "Hello world "
        XCTAssertFalse(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "A valid sentence?"
        XCTAssertFalse(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "!"
        XCTAssertFalse(sut.organizationIdInputItem.isValid())

        // valid
        sut.organizationIdInputItem.value = "123123"
        XCTAssertTrue(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "*hello123.world*"
        XCTAssertTrue(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "34ff34?"
        XCTAssertTrue(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = ".valid."
        XCTAssertTrue(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "+abc+"
        XCTAssertTrue(sut.organizationIdInputItem.isValid())
        sut.organizationIdInputItem.value = "{ }"
        XCTAssertTrue(sut.organizationIdInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let organizationIDInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.organizationIDTextfield"))

        // Then
        XCTAssertNotNil(organizationIDInputItem, "organizationID input field should exist")
    }

    func test_accountNumber_textfield() throws {
        // invalid
        sut.accountNumberInputItem.value = ""
        XCTAssertFalse(sut.accountNumberInputItem.isValid())
        sut.accountNumberInputItem.value = "This string is too long for the limit of 28 characters."
        XCTAssertFalse(sut.accountNumberInputItem.isValid())
        sut.accountNumberInputItem.value = "\nNew line"
        XCTAssertFalse(sut.accountNumberInputItem.isValid())

        // valid
        sut.accountNumberInputItem.value = "Hello!"
        XCTAssertTrue(sut.accountNumberInputItem.isValid())
        sut.accountNumberInputItem.value = " 123 "
        XCTAssertTrue(sut.accountNumberInputItem.isValid())
        sut.accountNumberInputItem.value = "password123!@#"
        XCTAssertTrue(sut.accountNumberInputItem.isValid())
        sut.accountNumberInputItem.value = " this_is valid -~ "
        XCTAssertTrue(sut.accountNumberInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let accountNumberInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.accountNumberTextfield"))

        // Then
        XCTAssertNotNil(accountNumberInputItem, "Bank account number input field should exist")
    }

    func test_bank_state_number_textfield() throws {

        // invalid
        sut.bsbInputItem.value = ""
        XCTAssertFalse(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "12345"
        XCTAssertFalse(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "12345667"
        XCTAssertFalse(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "abcabc"
        XCTAssertFalse(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "  12345"
        XCTAssertFalse(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "12345    "
        XCTAssertFalse(sut.bsbInputItem.isValid())

        // valid
        sut.bsbInputItem.value = "123456"
        XCTAssertTrue(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "666666"
        XCTAssertTrue(sut.bsbInputItem.isValid())
        sut.bsbInputItem.value = "000000"
        XCTAssertTrue(sut.bsbInputItem.isValid())

        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let bankStateNumberInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.bankStateBranchTextfield"))

        // Then
        XCTAssertNotNil(bankStateNumberInputItem, "Bank state number input field should exist")
    }

    func test_payment_instruction_titleLabel_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let paymentInstructionTitleLabelItem = sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.paymentInstructionTitleLabel") as? UILabel

        // Then
        XCTAssertNotNil(paymentInstructionTitleLabelItem, "Payment instruction title label should exist")
    }

    func test_continueButton_exists() throws {
        // Given
        sut.viewController.loadViewIfNeeded()

        // Check by accessibility identifier
        let continueButton: FormButtonItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.continueButton"))

        // Then
        XCTAssertNotNil(continueButton, "ContinueButton should exist")
    }

    func testViewDidLoadShouldSendInitialCall() throws {

        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            analyticsProvider: analyticsProviderMock
        )
        let paymentMethod: PayToPaymentMethod = try AdyenCoder.decode(payto)
        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    func testValidateGivenValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: PayToPaymentMethod = try AdyenCoder.decode(payto)
        let configuration = PayToComponent.Configuration(showsSubmitButton: false)
        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        try populateValidFields(sut: sut)

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateGivenInvalidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: PayToPaymentMethod = try AdyenCoder.decode(payto)
        let configuration = PayToComponent.Configuration(showsSubmitButton: false)
        let sut = PayToComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testSubmit_shouldCallPaymentDelegateDidSubmit() throws {
        // Given

        sut.viewController.loadViewIfNeeded()

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            didSubmitExpectation.fulfill()
        }

        try populateValidFields(sut: sut)

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }

    func testPayToComponent_givenPhonePayIdPaymentOption_submitsCorrectFormattedAccountIdentifier() throws {
        try assertPayToComponentDetailsSubmission(
            option: .payId(.phone),
            fill: { sut in
                sut.phoneNumberItem.value = "0666555444"
            },
            expectedIdentifier: "+61-0666555444" // ensure correct hyphenated format
        )
    }

    func testPayToComponent_givenEmailPayIdPaymentOption_submitsCorrectAccountIdentifier() throws {
        try assertPayToComponentDetailsSubmission(
            option: .payId(.email),
            fill: { sut in
                sut.emailInputItem.value = "katrina.mar@email.com"
            },
            expectedIdentifier: "katrina.mar@email.com"
        )
    }

    func testPayToComponent_givenAbnPayIdPaymentOption_submitsCorrectAccountIdentifier() throws {
        try assertPayToComponentDetailsSubmission(
            option: .payId(.abn),
            fill: { sut in
                sut.abnInputItem.value = "51824753556"
            },
            expectedIdentifier: "51824753556"
        )
    }

    func testPayToComponent_givenOrganizationIdPayIdPaymentOption_submitsCorrectAccountIdentifier() throws {
        try assertPayToComponentDetailsSubmission(
            option: .payId(.organizationId),
            fill: { sut in
                sut.organizationIdInputItem.value = "*hello123.world*"
            },
            expectedIdentifier: "*hello123.world*"
        )
    }

    func testPayToComponent_givenBsbPaymentOption_submitsCorrectAccountIdentifier() throws {
        try assertPayToComponentDetailsSubmission(
            option: .BSB,
            fill: { sut in
                sut.bsbInputItem.value = "123456"
                sut.accountNumberInputItem.value = "987654321"
            },
            expectedIdentifier: "123456-987654321" // ensure correct hyphenated format
        )
    }

    // MARK: - Helper

    private func assertPayToComponentDetailsSubmission(
        option: PayToPaymentOption,
        fill: (PayToComponent) -> Void,
        expectedIdentifier: String
    ) throws {
        // Given
        let payToPaymentMethod: PayToPaymentMethod = try AdyenCoder.decode(payto)
        let paymentMethodMock = PaymentMethodMock(type: payToPaymentMethod.type, name: payToPaymentMethod.name)
        let shopperName = ShopperName(firstName: "Katrina", lastName: "Del Mar")

        let expectedDetails = PayToDetails(
            paymentMethod: paymentMethodMock,
            accountIdentifier: expectedIdentifier,
            shopperName: shopperName
        )

        let sut = PayToComponent(paymentMethod: payToPaymentMethod, context: Dummy.context)
        sut.selectedPaymentOption = option

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        let didSubmitExpectation = expectation(description: "Delegate's didSubmit must be called")

        delegateMock.onDidSubmit = { data, _ in
            didSubmitExpectation.fulfill()
            // Then
            let receivedDetails = try? XCTUnwrap(data.paymentMethod as? PayToDetails)
            XCTAssertTrue(
                self.payToDetailsEqual(expectedDetails, receivedDetails),
                "Submitted PayToDetails should match expected details"
            )
        }

        // When
        fill(sut)
        sut.firstNameInputItem.value = shopperName.firstName
        sut.lastNameInputItem.value = shopperName.lastName
        sut.submit()

        waitForExpectations(timeout: 1.0)
    }

    private func populateValidFields(sut: PayToComponent) throws {
        let phoneNumberItem: FormPhoneNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.phoneNumberItem"))
        let firstNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.firstNameTextfield"))
        let lastNameInputItem: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.PayToComponent.lastNameTextfield"))

        self.populate(textItemView: phoneNumberItem, with: "4123466")
        self.populate(textItemView: firstNameInputItem, with: "test")
        self.populate(textItemView: lastNameInputItem, with: "lastname")
    }

    private func payToDetailsEqual(_ lhs: PayToDetails?, _ rhs: PayToDetails?) -> Bool {
        guard let lhs, let rhs else { return false }

        return lhs.type == rhs.type &&
        lhs.shopperName == rhs.shopperName &&
        lhs.accountIdentifier == rhs.accountIdentifier
    }
}
