//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSItemsFactoryTests: XCTestCase {

    var sut: BACSItemsFactory!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let styleProvider = FormComponentStyle()
        sut = BACSItemsFactory(styleProvider: styleProvider,
                               localizationParameters: LocalizationParameters(),
                               scope: "")
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testCreateHolderNameItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Bank account holder name"
        let expectedPlaceholder = "Bank account holder name"
        let expectedValidationFailureMessage = "Invalid bank account holder name"
        let expectedIdentifier = ".holderNameItem"

        // When
        let holderNameItem = sut.createHolderNameItem()

        // Then
        XCTAssertEqual(expectedTitle, holderNameItem.title)
        XCTAssertEqual(expectedPlaceholder, holderNameItem.placeholder)

        let validator = try XCTUnwrap(holderNameItem.validator as? LengthValidator)
        XCTAssertEqual(validator.minimumLength, 1)
        XCTAssertEqual(validator.maximumLength, 70)

        XCTAssertEqual(expectedValidationFailureMessage, holderNameItem.validationFailureMessage)
        XCTAssertTrue(holderNameItem.autocapitalizationType == .words)

        let identifier = try XCTUnwrap(holderNameItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateBankAccountNumberItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Bank account number"
        let expectedPlaceholder = "Bank account number"
        let expectedValidationFailureMessage = "Invalid bank account number"
        let expectedIdentifier = ".bankAccountNumberItem"

        // When
        let bankAccountItem = sut.createBankAccountNumberItem()

        // Then
        XCTAssertEqual(expectedTitle, bankAccountItem.title)
        XCTAssertEqual(expectedPlaceholder, bankAccountItem.placeholder)

        let validator = try XCTUnwrap(bankAccountItem.validator as? NumericStringValidator)
        XCTAssertEqual(validator.minimumLength, 1)
        XCTAssertEqual(validator.maximumLength, 8)

        XCTAssertNotNil(bankAccountItem.formatter as? NumericFormatter)

        XCTAssertEqual(expectedValidationFailureMessage, bankAccountItem.validationFailureMessage)
        XCTAssertTrue(bankAccountItem.autocapitalizationType == .none)
        XCTAssertTrue(bankAccountItem.keyboardType == .numberPad)

        let identifier = try XCTUnwrap(bankAccountItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateSortCodeItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Sort code"
        let expectedPlaceholder = "Sort code"
        let expectedValidationFailureMessage = "Invalid sort code"
        let expectedIdentifier = ".sortCodeItem"

        // When
        let sortCodeItem = sut.createSortCodeItem()

        // Then
        XCTAssertEqual(expectedTitle, sortCodeItem.title)
        XCTAssertEqual(expectedPlaceholder, sortCodeItem.placeholder)

        let validator = try XCTUnwrap(sortCodeItem.validator as? NumericStringValidator)
        XCTAssertEqual(validator.minimumLength, 1)
        XCTAssertEqual(validator.maximumLength, 6)

        XCTAssertNotNil(sortCodeItem.formatter as? NumericFormatter)

        XCTAssertEqual(expectedValidationFailureMessage, sortCodeItem.validationFailureMessage)
        XCTAssertTrue(sortCodeItem.autocapitalizationType == .none)
        XCTAssertTrue(sortCodeItem.keyboardType == .numberPad)

        let identifier = try XCTUnwrap(sortCodeItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateEmailItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Email address"
        let expectedPlaceholder = "Email address"
        let expectedValidationFailureMessage = "Invalid email address"
        let expectedIdentifier = ".emailItem"

        // When
        let emailItem = sut.createEmailItem()

        // Then
        XCTAssertEqual(expectedTitle, emailItem.title)
        XCTAssertEqual(expectedPlaceholder, emailItem.placeholder)
        XCTAssertNotNil(emailItem.validator as? EmailValidator)
        XCTAssertEqual(expectedValidationFailureMessage, emailItem.validationFailureMessage)
        XCTAssertTrue(emailItem.autocapitalizationType == .none)
        XCTAssertTrue(emailItem.keyboardType == .emailAddress)

        let identifier = try XCTUnwrap(emailItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateContinueButtonShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Continue"
        let expectedIdentifier = ".continueButtonItem"

        // When
        let continueButtonItem = sut.createContinueButton()

        // Then
        XCTAssertEqual(expectedTitle, continueButtonItem.title)

        let identifier = try XCTUnwrap(continueButtonItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreatePaymentButtonShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Confirm and pay"
        let expectedIdentifier = ".paymentButtonItem"

        // When
        let paymentButtonItem = sut.createPaymentButton()

        // Then
        XCTAssertEqual(expectedTitle, paymentButtonItem.title)

        let identifier = try XCTUnwrap(paymentButtonItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateAmountConsentToggleWhenAmountIsNotNilShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedAmount = Amount(value: 10560, currencyCode: "USD")
        let expectedTitle = "I agree that \(expectedAmount.formatted) will be deducted from my bank account."
        let expectedIdentifier = ".amountConsentToggleItem"

        // When
        let amountConsentToggleItem = sut.createAmountConsentToggle(amount: expectedAmount)

        // Then
        XCTAssertFalse(amountConsentToggleItem.value)
        XCTAssertEqual(expectedTitle, amountConsentToggleItem.title)

        let identifier = try XCTUnwrap(amountConsentToggleItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateAmountConsentToggleWhenAmountIsNilShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "I agree that the above amount will be deducted from my bank account."
        let expectedIdentifier = ".amountConsentToggleItem"

        // When
        let amountConsentToggleItem = sut.createAmountConsentToggle(amount: nil)

        // Then
        XCTAssertFalse(amountConsentToggleItem.value)
        XCTAssertEqual(expectedTitle, amountConsentToggleItem.title)

        let identifier = try XCTUnwrap(amountConsentToggleItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateLegalConsentToggleShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "I confirm the account is in my name and I am the only signatory required to authorise the Direct Debit on this account."
        let expectedIdentifier = ".legalConsentToggleItem"

        // When
        let legalConsentToggleItem = sut.createLegalConsentToggle()

        // Then
        XCTAssertFalse(legalConsentToggleItem.value)
        XCTAssertEqual(expectedTitle, legalConsentToggleItem.title)

        let identifier = try XCTUnwrap(legalConsentToggleItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }
}
