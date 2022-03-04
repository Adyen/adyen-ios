//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitComponentTests: XCTestCase {

    var inputPresenter: BACSInputPresenterProtocolMock!
    var confirmationPresenter: BACSConfirmationPresenterProtocolMock!
    var presentationDelegate: PresentationDelegateMock!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var sut: BACSDirectDebitComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit,
                                                         name: "BACS Direct Debit")
        let apiContext = Dummy.context

        inputPresenter = BACSInputPresenterProtocolMock()
        confirmationPresenter = BACSConfirmationPresenterProtocolMock()
        presentationDelegate = PresentationDelegateMock()
        paymentComponentDelegate = PaymentComponentDelegateMock()

        sut = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext)

        sut.presentationDelegate = presentationDelegate
        sut.delegate = paymentComponentDelegate
    }

    override func tearDownWithError() throws {
        inputPresenter = nil
        confirmationPresenter = nil
        presentationDelegate = nil
        paymentComponentDelegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testPresentConfirmationShouldAssembleConfirmationScene() throws {
        // When
        sut.presentConfirmation(with: bacsDataMock)

        // Then
        XCTAssertNotNil(sut.confirmationPresenter)
    }

    func testPresentConfirmationShouldCallPresentationDelegatePresent() throws {
        // When
        sut.presentConfirmation(with: bacsDataMock)

        // Then
        XCTAssertEqual(presentationDelegate.presentComponentCallsCount, 1)
    }

    func testConfirmPaymentShouldCallConfirmationPresenterStartLoading() throws {
        // Given
        sut.confirmationPresenter = confirmationPresenter

        // When
        sut.confirmPayment(with: bacsDataMock)

        // Then
        XCTAssertEqual(confirmationPresenter.startLoadingCallsCount, 1)
    }

    func testConfirmPaymentShouldCallPaymentComponentDelegateDidSubmit() throws {
        // Given
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called.")
        paymentComponentDelegate.onDidSubmit = { [weak self] data, component in
            XCTAssertTrue(component === self?.sut)
            let details = data.paymentMethod as! BACSDirectDebitDetails

            XCTAssertEqual(details.holderName, self?.bacsDataMock.holderName)
            XCTAssertEqual(details.bankAccountNumber, self?.bacsDataMock.bankAccountNumber)
            XCTAssertEqual(details.bankLocationId, self?.bacsDataMock.bankLocationId)

            self?.sut.stopLoadingIfNeeded()
            didSubmitExpectation.fulfill()
        }

        // When
        sut.confirmPayment(with: bacsDataMock)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testStopLoadingShouldCallConfirmationPresenterStopLoading() throws {
        // Given
        sut.confirmationPresenter = confirmationPresenter

        // When
        sut.stopLoading()

        // Then
        XCTAssertEqual(confirmationPresenter.stopLoadingCallsCount, 1)
    }

    // MARK: - Private

    private var bacsDataMock: BACSDirectDebitData {
        BACSDirectDebitData(holderName: "Katrina del Mar",
                            bankAccountNumber: "90583742",
                            bankLocationId: "743082",
                            shopperEmail: "katrina.mar@mail.com")
    }
}
