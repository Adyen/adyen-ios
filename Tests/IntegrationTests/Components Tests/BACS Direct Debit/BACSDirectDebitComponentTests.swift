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

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentComponentDelegate = PaymentComponentDelegateMock()
        context = Dummy.context

        sut = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        sut.delegate = paymentComponentDelegate
    }

    override func tearDownWithError() throws {
        paymentComponentDelegate = nil
        context = nil
        sut = nil
        try super.tearDownWithError()
    }

    func test_viewController_shouldCreateBACSViewModel() {
        // When
        _ = sut.viewController

        // Then
        XCTAssertNotNil(sut.bacsViewModel)
    }

    func test_performSubmit_withValidData_shouldCallDelegateDidSubmit() throws {
        // Given
        let didSubmitExpectation = expectation(description: "Expect delegate.didSubmit() to be called.")
        paymentComponentDelegate.onDidSubmit = { [weak self] data, component in
            XCTAssertTrue(component === self?.sut)
            let details = data.paymentMethod as! BACSDirectDebitDetails

            XCTAssertEqual(details.holderName, self?.mockHolderName)
            XCTAssertEqual(details.bankAccountNumber, self?.mockBankAccountNumber)
            XCTAssertEqual(details.bankLocationId, self?.mockBankLocationId)

            self?.sut.stopLoading()
            didSubmitExpectation.fulfill()
        }

        // Trigger viewController to create the viewModel
        _ = sut.viewController

        // Populate valid form data
        let viewModel = try XCTUnwrap(sut.bacsViewModel)
        viewModel.viewDidLoad()
        viewModel.amountConsentToggleItem?.value = true
        viewModel.legalConsentToggleItem?.value = true
        viewModel.holderNameItem?.value = mockHolderName
        viewModel.bankAccountNumberItem?.value = mockBankAccountNumber
        viewModel.sortCodeItem?.value = mockBankLocationId
        viewModel.emailItem?.value = mockShopperEmail

        // When
        sut.performSubmit()

        // Then
        waitForExpectations(timeout: 10)
    }

    func test_stopLoading_shouldStopViewModelLoading() throws {
        // Given
        _ = sut.viewController
        let viewModel = try XCTUnwrap(sut.bacsViewModel)
        viewModel.viewDidLoad()
        viewModel.submitButtonItem?.showsActivityIndicator = true

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(viewModel.submitButtonItem?.showsActivityIndicator, false)
    }

    // MARK: - Private

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
