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
class BACSViewControllerTests: XCTestCase {

    var sut: BACSViewController!
    var tracker: BACSDirectDebitComponentTrackerProtocolMock!
    var itemsFactory: BACSItemsFactoryProtocolMock!
    var viewModel: BACSViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()

        tracker = BACSDirectDebitComponentTrackerProtocolMock()
        itemsFactory = makeItemsFactoryMock()

        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit, name: "BACS Direct Debit")
        let amount = Amount(value: 105.7, currencyCode: "USD", localeIdentifier: nil)
        let configuration = BACSDirectDebitComponent.Configuration(showsSubmitButton: true)

        viewModel = BACSViewModel(
            paymentMethod: paymentMethod,
            amount: amount,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { _ in }
        )

        sut = BACSViewController(
            title: "BACS Direct Debit",
            viewModel: viewModel
        )
    }

    override func tearDownWithError() throws {
        tracker = nil
        itemsFactory = nil
        viewModel = nil
        sut = nil
        try super.tearDownWithError()
    }

    func test_title_shouldBeSetOnCreation() throws {
        // When
        let title = try XCTUnwrap(sut.title)
        XCTAssertFalse(title.isEmpty)
    }

    func test_viewDidLoad_shouldCallViewModelViewDidLoad() {
        // When
        sut.loadViewIfNeeded()

        // Then
        XCTAssertEqual(tracker.sendInitialAnalyticsCallsCount, 1)
        XCTAssertEqual(tracker.sendDidLoadEventCallsCount, 1)
    }

    func test_viewDidLoad_shouldAddItemsToForm() {
        // When
        sut.loadViewIfNeeded()

        // Then - items should be added (11 items from viewModel.createItems())
        XCTAssertEqual(viewModel.items.count, 11)
    }

    func test_viewDidLoad_shouldNotShowLoading() throws {
        // When
        sut.loadViewIfNeeded()

        // Then
        let submitButtonItem = try XCTUnwrap(viewModel.submitButtonItem)
        XCTAssertFalse(submitButtonItem.showsActivityIndicator)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }

    func test_performSubmit_whenFormIsValid_shouldShowLoading() throws {
        // Given
        sut.loadViewIfNeeded()
        populateValidFormData()

        // When
        viewModel.performSubmit()

        // Then
        let submitButtonItem = try XCTUnwrap(viewModel.submitButtonItem)
        XCTAssertTrue(submitButtonItem.showsActivityIndicator)
        XCTAssertFalse(sut.view.isUserInteractionEnabled)
    }

    func test_performSubmit_whenFormIsInvalid_shouldNotShowLoading() throws {
        // Given
        sut.loadViewIfNeeded()

        // When
        viewModel.performSubmit()

        // Then
        let submitButtonItem = try XCTUnwrap(viewModel.submitButtonItem)
        XCTAssertEqual(viewModel.state, .invalid)
        XCTAssertFalse(submitButtonItem.showsActivityIndicator)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }

    func test_stopLoading_shouldHideLoading() throws {
        // Given
        sut.loadViewIfNeeded()
        populateValidFormData()
        viewModel.performSubmit()

        // When
        viewModel.stopLoading()

        // Then
        let submitButtonItem = try XCTUnwrap(viewModel.submitButtonItem)
        XCTAssertFalse(submitButtonItem.showsActivityIndicator)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }

    // MARK: - Private

    private func populateValidFormData() {
        viewModel.amountConsentToggleItem.value = true
        viewModel.legalConsentToggleItem.value = true
        viewModel.holderNameItem.value = "Katrina del Mar"
        viewModel.bankAccountNumberItem.value = "90583742"
        viewModel.sortCodeItem.value = "743082"
        viewModel.emailItem.value = "katrina.mar@mail.com"
    }

    private func makeItemsFactoryMock() -> BACSItemsFactoryProtocolMock {
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
}
