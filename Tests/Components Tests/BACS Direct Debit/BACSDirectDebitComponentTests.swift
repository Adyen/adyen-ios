//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitComponentTests: XCTestCase {

    var inputPresenter: BACSInputPresenterProtocolMock!
    var confirmationPresenter: BACSConfirmationPresenterProtocolMock!
    var presentationDelegate: PresentationDelegateMock!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var context: AdyenContext!
    var sut: BACSDirectDebitComponent!

    let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit,
                                                     name: "BACS Direct Debit")

    override func setUpWithError() throws {
        try super.setUpWithError()
        inputPresenter = BACSInputPresenterProtocolMock()
        confirmationPresenter = BACSConfirmationPresenterProtocolMock()
        presentationDelegate = PresentationDelegateMock()
        paymentComponentDelegate = PaymentComponentDelegateMock()
        context = Dummy.context

        sut = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                       context: context)

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

    func testPresentConfirmationShouldAssembleConfirmationScene() throws {
        // When
        sut.presentConfirmation(with: bacsDataMock)

        // Then
        XCTAssertNotNil(sut.confirmationPresenter)
    }
    
    func testUpdatingAmount() throws {
        let payment = Payment(amount: .init(value: 100, currencyCode: "EUR"), countryCode: "NL")
        sut = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                       context: context,
                                       configuration: .init())

        let presenter: BACSInputPresenter = sut.inputPresenter as! BACSInputPresenter
        let expectedConsentTitle1 = presenter.itemsFactory.createConsentText(with: payment.amount)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(200))
        
        XCTAssertEqual(presenter.amountConsentToggleItem?.title, expectedConsentTitle1)
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
