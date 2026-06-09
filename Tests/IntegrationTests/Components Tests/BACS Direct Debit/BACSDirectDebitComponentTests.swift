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

    var inputPresenter: BACSInputPresenterProtocolMock!
    var confirmationPresenter: BACSConfirmationPresenterProtocolMock!
    var presentationDelegate: PresentationDelegateMock!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var context: AdyenContext!
    var sut: BACSDirectDebitComponent!

    let paymentMethod = BACSDirectDebitPaymentMethod(
        type: .bacsDirectDebit,
        name: "BACS Direct Debit"
    )

    override func setUpWithError() throws {
        try super.setUpWithError()
        inputPresenter = BACSInputPresenterProtocolMock()
        confirmationPresenter = BACSConfirmationPresenterProtocolMock()
        presentationDelegate = PresentationDelegateMock()
        paymentComponentDelegate = PaymentComponentDelegateMock()
        context = Dummy.context

        sut = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        sut.presentationDelegate = presentationDelegate
        sut.delegate = paymentComponentDelegate
    }

    override func tearDownWithError() throws {
        inputPresenter = nil
        confirmationPresenter = nil
        presentationDelegate = nil
        paymentComponentDelegate = nil
        context = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testPresentConfirmationShouldAssembleConfirmationScene() {
        // When
        sut.presentConfirmation(with: bacsDataMock)

        // Then
        XCTAssertNotNil(sut.confirmationPresenter)
    }
    
    func testUpdatingAmount() throws {
        let amount = Amount(value: 100, currencyCode: "EUR")
        sut = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init()
        )

        let presenter: BACSViewModel = try XCTUnwrap(sut.inputPresenter as? BACSViewModel)
        let expectedConsentTitle1 = presenter.itemsFactory.createConsentText(with: amount)
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(200))
        
        XCTAssertEqual(presenter.amountConsentToggleItem?.title, expectedConsentTitle1)
    }

    func testPresentConfirmationShouldCallPresentationDelegatePresent() {
        // When
        sut.presentConfirmation(with: bacsDataMock)

        // Then
        XCTAssertEqual(presentationDelegate.presentComponentCallsCount, 1)
    }

    func testConfirmPaymentShouldCallConfirmationPresenterStartLoading() {
        // Given
        sut.confirmationPresenter = confirmationPresenter

        // When
        sut.confirmPayment(with: bacsDataMock)

        // Then
        XCTAssertEqual(confirmationPresenter.startLoadingCallsCount, 1)
    }

    func testConfirmPaymentShouldCallPaymentComponentDelegateDidSubmit() {
        // Given
        let didSubmitExpectation = expectation(description: "Expect delegate.didSubmit() to be called.")
        paymentComponentDelegate.onDidSubmit = { [weak self] data, component in
            XCTAssertTrue(component === self?.sut)
            let details = data.paymentMethod as! BACSDirectDebitDetails

            XCTAssertEqual(details.holderName, self?.bacsDataMock.holderName)
            XCTAssertEqual(details.bankAccountNumber, self?.bacsDataMock.bankAccountNumber)
            XCTAssertEqual(details.bankLocationId, self?.bacsDataMock.bankLocationId)

            self?.sut.stopLoading()
            didSubmitExpectation.fulfill()
        }

        // When
        sut.confirmPayment(with: bacsDataMock)

        // Then
        waitForExpectations(timeout: 10)
    }

    func testStopLoadingShouldCallConfirmationPresenterStopLoading() {
        // Given
        sut.confirmationPresenter = confirmationPresenter

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(confirmationPresenter.stopLoadingCallsCount, 1)
    }

    // MARK: - Private

    private var bacsDataMock: BACSDirectDebitData {
        BACSDirectDebitData(
            holderName: "Katrina del Mar",
            bankAccountNumber: "90583742",
            bankLocationId: "743082",
            shopperEmail: "katrina.mar@mail.com"
        )
    }
}
