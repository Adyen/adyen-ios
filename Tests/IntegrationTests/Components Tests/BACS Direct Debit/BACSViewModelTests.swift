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
        let amount = Amount(value: 105.7, currencyCode: "USD", localeIdentifier: nil)
        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit, name: "BACS Direct Debit")
        let configuration = BACSDirectDebitComponent.Configuration(showsSubmitButton: true)

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

    func test_viewDidLoad_shouldCreateItems() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(itemsFactory.createHolderNameItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createBankAccountNumberItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createSortCodeItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createEmailItemCallsCount, 1)
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 1)
        XCTAssertEqual(itemsFactory.createAmountConsentToggleAmountCallsCount, 1)
        XCTAssertEqual(itemsFactory.createLegalConsentToggleCallsCount, 1)
    }

    func test_viewDidLoad_shouldPopulateItems() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(sut.items.count, 11)
    }

    func test_viewDidLoad_shouldCallTrackerSendEvent() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(tracker.sendInitialAnalyticsCallsCount, 1)
        XCTAssertEqual(tracker.sendDidLoadEventCallsCount, 1)
    }

    func test_submit_whenButtonTapped_shouldSetShouldShowValidation() {
        // When
        sut.viewDidLoad()
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertTrue(sut.shouldShowValidation)
    }

    func test_submit_whenAnyTextItemIsNotValid_shouldNotCallOnSubmit() {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = mockHolderName
        sut.bankAccountNumberItem?.value = mockBankAccountNumber
        sut.sortCodeItem?.value = mockBankLocationId
        sut.emailItem?.value = "mail"

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_submit_whenAmountConsentItemIsDisabled_shouldNotCallOnSubmit() {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = false
        sut.legalConsentToggleItem?.value = true

        sut.holderNameItem?.value = mockHolderName
        sut.bankAccountNumberItem?.value = mockBankAccountNumber
        sut.sortCodeItem?.value = mockBankLocationId
        sut.emailItem?.value = mockShopperEmail

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_submit_whenLegalConsentItemIsDisabled_shouldNotCallOnSubmit() {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = false

        sut.holderNameItem?.value = mockHolderName
        sut.bankAccountNumberItem?.value = mockBankAccountNumber
        sut.sortCodeItem?.value = mockBankLocationId
        sut.emailItem?.value = mockShopperEmail

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_submit_whenAnyItemValueIsNil_shouldNotCallOnSubmit() {
        // Given
        sut.viewDidLoad()
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = false

        // Missing bank holder name value
        sut.bankAccountNumberItem?.value = mockBankAccountNumber
        sut.sortCodeItem?.value = mockBankLocationId
        sut.emailItem?.value = mockShopperEmail

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(onSubmitCallsCount, 0)
    }

    func test_submit_whenAllItemsAreValid_shouldCallOnSubmit() {
        // Given
        sut.viewDidLoad()
        populateValidFormData()

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        XCTAssertEqual(onSubmitCallsCount, 1)
    }

    func test_submit_whenAllItemsAreValid_shouldCreateDetailsWithCorrectValues() {
        // Given
        sut.viewDidLoad()
        populateValidFormData()

        // When
        sut.submitButtonItem?.buttonSelectionHandler?()

        // Then
        let receivedDetails = onSubmitReceivedDetails
        XCTAssertNotNil(receivedDetails)
        XCTAssertEqual(mockHolderName, receivedDetails?.holderName)
        XCTAssertEqual(mockBankAccountNumber, receivedDetails?.bankAccountNumber)
        XCTAssertEqual(mockBankLocationId, receivedDetails?.bankLocationId)
        XCTAssertEqual(mockShopperEmail, receivedDetails?.shopperEmail)
    }

    func test_stopLoading_shouldSetActivityIndicatorToFalse() {
        // Given
        sut.viewDidLoad()
        sut.submitButtonItem?.showsActivityIndicator = true

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(sut.submitButtonItem?.showsActivityIndicator, false)
    }

    func test_viewDidLoad_whenShowsSubmitButtonIsFalse_shouldNotCreateSubmitButton() {
        // Given
        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit, name: "BACS Direct Debit")
        let configuration = BACSDirectDebitComponent.Configuration(showsSubmitButton: false)

        let viewModel = BACSViewModel(
            paymentMethod: paymentMethod,
            amount: nil,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { _ in }
        )

        // When
        viewModel.viewDidLoad()

        // Then
        XCTAssertNil(viewModel.submitButtonItem)
        XCTAssertEqual(itemsFactory.createPaymentButtonCallsCount, 0)
    }

    // MARK: - Private

    private func populateValidFormData() {
        sut.amountConsentToggleItem?.value = true
        sut.legalConsentToggleItem?.value = true
        sut.holderNameItem?.value = mockHolderName
        sut.bankAccountNumberItem?.value = mockBankAccountNumber
        sut.sortCodeItem?.value = mockBankLocationId
        sut.emailItem?.value = mockShopperEmail
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
