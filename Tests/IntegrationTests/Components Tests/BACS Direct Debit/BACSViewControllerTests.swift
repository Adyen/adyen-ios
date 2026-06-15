//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

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
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(tracker.initialEventCallsCount, 1)
        XCTAssertEqual(tracker.didLoadEventCallsCount, 1)
    }

    // MARK: - Private

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
