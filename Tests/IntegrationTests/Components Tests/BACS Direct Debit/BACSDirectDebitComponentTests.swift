//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class BACSDirectDebitComponentTests: XCTestCase {

    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var context: AdyenContext!
    var sut: BACSDirectDebitComponent!

    let paymentMethod = BACSDirectDebitPaymentMethod(
        type: .bacsDirectDebit,
        name: "BACS Direct Debit"
    )

    override func setUp() async throws {
        try await super.setUp()
        paymentComponentDelegate = PaymentComponentDelegateMock()
        context = Dummy.context
    }

    override func tearDown() async throws {
        paymentComponentDelegate = nil
        context = nil
        sut = nil
        try await super.tearDown()
    }

    func test_amountConsentToggle_shouldIncludeContextAmount() {
        // Given
        sut = makeSUT()

        // Then
        let title = sut.bacsViewModel.amountConsentToggleItem.title
        XCTAssertTrue(title?.contains(Dummy.amount.formatted) == true)
    }

    func test_performSubmit_whenFormIsValid_shouldCallDelegateDidSubmitWithDetails() throws {
        // Given
        sut = makeSUT()
        populateValidFormData()

        // When
        sut.performSubmit()

        // Then
        let arguments = try XCTUnwrap(paymentComponentDelegate.didSubmitReceivedArguments)
        XCTAssertTrue(arguments.component === sut)

        let details = try XCTUnwrap(arguments.data.paymentMethod as? BACSDirectDebitDetails)
        XCTAssertEqual(details.holderName, mockHolderName)
        XCTAssertEqual(details.bankAccountNumber, mockBankAccountNumber)
        XCTAssertEqual(details.bankLocationId, mockBankLocationId)
        XCTAssertEqual(details.shopperEmail, mockShopperEmail)
    }

    func test_performSubmit_whenFormIsInvalid_shouldNotCallDelegateDidSubmit() {
        // Given
        sut = makeSUT()

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(paymentComponentDelegate.didSubmitCallsCount, 0)
        XCTAssertEqual(sut.bacsViewModel.state, .invalid)
    }

    func test_stopLoading_shouldSetViewModelStateToIdle() {
        // Given
        sut = makeSUT()
        populateValidFormData()
        sut.performSubmit()
        XCTAssertEqual(sut.bacsViewModel.state, .submitting)

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(sut.bacsViewModel.state, .idle)
    }

    // MARK: - Private

    private func makeSUT() -> BACSDirectDebitComponent {
        let configuration = BasicComponentConfiguration()
        let sut = BACSDirectDebitFactory().create(
            with: paymentMethod,
            context: context,
            configuration: configuration,
            callbacks: nil
        )
        sut.delegate = paymentComponentDelegate
        return sut
    }

    private func populateValidFormData() {
        let viewModel = sut.bacsViewModel
        viewModel.amountConsentToggleItem.value = true
        viewModel.legalConsentToggleItem.value = true
        viewModel.holderNameItem.value = mockHolderName
        viewModel.bankAccountNumberItem.value = mockBankAccountNumber
        viewModel.sortCodeItem.value = mockBankLocationId
        viewModel.emailItem.value = mockShopperEmail
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
