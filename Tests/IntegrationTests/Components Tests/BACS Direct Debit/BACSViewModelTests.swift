//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class BACSViewModelTests: XCTestCase {

    var tracker: BACSDirectDebitComponentTrackerProtocolMock!
    var itemsFactory: BACSItemsFactoryProtocolMock!
    var sut: BACSViewModel!
    var onSubmitCallsCount: Int = 0
    var onSubmitReceivedDetails: BACSDirectDebitDetails?

    override func setUpWithError() throws {
        try super.setUpWithError()

        tracker = BACSDirectDebitComponentTrackerProtocolMock()
        itemsFactory = itemsFactoryMock
        let amount = Amount(value: 10570, currencyCode: "USD", localeIdentifier: nil)
        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit, name: "BACS Direct Debit")
        let configuration = BasicComponentConfiguration(showsSubmitButton: true)

        onSubmitCallsCount = 0
        onSubmitReceivedDetails = nil

        sut = BACSViewModel(
            paymentMethod: paymentMethod,
            amount: amount,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { [weak self] details in
                self?.onSubmitCallsCount += 1
                self?.onSubmitReceivedDetails = details
            }
        )
    }

    override func tearDownWithError() throws {
        tracker = nil
        itemsFactory = nil
        sut = nil
        onSubmitCallsCount = 0
        onSubmitReceivedDetails = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization

    func test_init_shouldCreateFormItems() {
        // Then
        XCTAssertEqual(itemsFactory.createHolderNameItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createBankAccountNumberItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createSortCodeItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createEmailItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createAmountConsentToggleAmountCallsCount, 1)
        XCTAssertEqual(itemsFactory.createLegalConsentToggleCallsCount, 1)
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 0)
    }

    func test_init_shouldSetStateToIdle() {
        // Then
        XCTAssertEqual(sut.state, .idle)
    }

    func test_items_shouldContainAllFormItems() {
        // When
        let items = sut.items

        // Then
        XCTAssertEqual(items.count, 11)
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 1)
    }

    func test_items_whenShowsSubmitButtonIsFalse_shouldNotCreateSubmitButton() {
        // Given
        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit, name: "BACS Direct Debit")
        let configuration = BasicComponentConfiguration(showsSubmitButton: false)

        let viewModel = BACSViewModel(
            paymentMethod: paymentMethod,
            amount: nil,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { _ in }
        )

        // When
        let items = viewModel.items

        // Then
        XCTAssertEqual(items.count, 10)
        XCTAssertNil(viewModel.submitButtonItem)
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 0)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_shouldCallTrackerSendEvent() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(tracker.sendInitialAnalyticsCallsCount, 1)
        XCTAssertEqual(tracker.sendDidLoadEventCallsCount, 1)
    }

    // MARK: - performSubmit

    func test_performSubmit_whenFormIsInvalid_shouldSetStateToInvalid() {
        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .invalid)
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_performSubmit_whenAnyTextItemIsNotValid_shouldNotCallOnSubmit() {
        // Given
        populateValidFormData()
        sut.emailItem.value = "mail"

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .invalid)
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_performSubmit_whenHolderNameIsEmpty_shouldNotCallOnSubmit() {
        // Given
        populateValidFormData()
        sut.holderNameItem.value = ""

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .invalid)
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_performSubmit_whenAmountConsentItemIsDisabled_shouldNotCallOnSubmit() {
        // Given
        populateValidFormData()
        sut.amountConsentToggleItem.value = false

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .invalid)
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_performSubmit_whenLegalConsentItemIsDisabled_shouldNotCallOnSubmit() {
        // Given
        populateValidFormData()
        sut.legalConsentToggleItem.value = false

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .invalid)
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_performSubmit_whenFormIsValid_shouldSetStateToSubmitting() {
        // Given
        populateValidFormData()

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(sut.state, .submitting)
        XCTAssertEqual(onSubmitCallsCount, 1)
    }

    func test_performSubmit_whenFormIsValid_shouldCreateDetailsWithCorrectValues() throws {
        // Given
        populateValidFormData()

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        let receivedDetails = try XCTUnwrap(onSubmitReceivedDetails)
        XCTAssertEqual(mockHolderName, receivedDetails.holderName)
        XCTAssertEqual(mockBankAccountNumber, receivedDetails.bankAccountNumber)
        XCTAssertEqual(mockBankLocationId, receivedDetails.bankLocationId)
        XCTAssertEqual(mockShopperEmail, receivedDetails.shopperEmail)
    }

    func test_performSubmit_whenSubmitting_shouldIgnoreSubsequentSubmits() {
        // Given
        populateValidFormData()
        sut.performSubmit()

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(sut.state, .submitting)
        XCTAssertEqual(onSubmitCallsCount, 1)
    }

    func test_performSubmit_whenInvalidThenCorrected_shouldSubmit() {
        // Given
        sut.performSubmit()
        XCTAssertEqual(sut.state, .invalid)

        // When
        populateValidFormData()
        sut.performSubmit()

        // Then
        XCTAssertEqual(sut.state, .submitting)
        XCTAssertEqual(onSubmitCallsCount, 1)
    }

    // MARK: - stopLoading

    func test_stopLoading_whenSubmitting_shouldSetStateToIdle() {
        // Given
        populateValidFormData()
        sut.performSubmit()

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(sut.state, .idle)
    }

    func test_stopLoading_whenNotSubmitting_shouldKeepState() {
        // Given
        sut.performSubmit()

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(sut.state, .invalid)
    }

    func test_stopLoading_shouldAllowResubmit() {
        // Given
        populateValidFormData()
        sut.performSubmit()
        sut.stopLoading()

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(sut.state, .submitting)
        XCTAssertEqual(onSubmitCallsCount, 2)
    }

    // MARK: - Private

    private func populateValidFormData() {
        sut.amountConsentToggleItem.value = true
        sut.legalConsentToggleItem.value = true
        sut.holderNameItem.value = mockHolderName
        sut.bankAccountNumberItem.value = mockBankAccountNumber
        sut.sortCodeItem.value = mockBankLocationId
        sut.emailItem.value = mockShopperEmail
    }

    private var itemsFactoryMock: BACSItemsFactoryProtocolMock {
        let styleProvider = FormComponentStyle()

        let itemsFactory = BACSItemsFactoryProtocolMock()

        let holderNameItem = FormTextInputItem()
        holderNameItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)
        itemsFactory.createHolderNameItemReturnValue = holderNameItem

        let bankAccountNumberItem = FormTextInputItem()
        bankAccountNumberItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 8)
        itemsFactory.createBankAccountNumberItemReturnValue = bankAccountNumberItem

        let sortCodeItem = FormTextInputItem()
        sortCodeItem.validator = NumericStringValidator(minimumLength: 1, maximumLength: 6)
        itemsFactory.createSortCodeItemReturnValue = sortCodeItem

        let emailItem = FormTextInputItem()
        emailItem.validator = EmailValidator()
        itemsFactory.createEmailItemReturnValue = emailItem

        itemsFactory.createPaymentButtonReturnValue = FormButtonItem(style: styleProvider.mainButtonItem)
        itemsFactory.createAmountConsentToggleAmountReturnValue = FormToggleItem()
        itemsFactory.createLegalConsentToggleReturnValue = FormToggleItem()

        return itemsFactory
    }

    private var mockHolderName: String {
        "Katrina del Mar"
    }

    private var mockBankAccountNumber: String {
        "90583742"
    }

    private var mockBankLocationId: String {
        "743082"
    }

    private var mockShopperEmail: String {
        "katrina.mar@mail.com"
    }

}
