//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenUI
import XCTest

@MainActor
class StoredCardComponentTests: XCTestCase {

    // MARK: - UI Display

    /// Verifies that the component displays a security code field, cancel button, and pay button.
    func testUIWithClientKey() {
        // Given
        let proxy = makeSUT()

        // When
        proxy.present(on: self)

        // Then
        XCTAssertNotNil(proxy.securityCodeText)
        XCTAssertTrue(proxy.hasCancelButton)
        XCTAssertTrue(proxy.hasPayButton)
    }

    // MARK: - Payment Submit

    /// Verifies that submitting a valid security code encrypts and submits card details to the delegate.
    func testPaymentSubmitWithValidPublicKey() throws {
        // Given
        let proxy = makeSUT()
        let delegate = PaymentComponentDelegateMock()
        proxy.component.delegate = delegate

        let submitExpectation = expectation(description: "Expect didSubmit to be called")
        delegate.onDidSubmit = { _, _ in submitExpectation.fulfill() }
        delegate.onDidFail = { _, _ in XCTFail("didFail should not be called") }

        // When
        proxy.present(on: self)
        proxy.enterSecurityCode("737")
        proxy.tapPayButton()

        // Then
        waitForExpectations(timeout: 1)

        let args = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertTrue(args.component === proxy.component)

        let cardDetails = try XCTUnwrap(args.data.paymentMethod as? CardDetails)
        XCTAssertNotNil(cardDetails.encryptedSecurityCode)
        XCTAssertNil(cardDetails.encryptedCardNumber)
        XCTAssertNil(cardDetails.encryptedExpiryYear)
        XCTAssertNil(cardDetails.encryptedExpiryMonth)

        XCTAssertTrue(proxy.securityCodeText?.isEmpty == true)
        XCTAssertFalse(proxy.isPayButtonEnabled)
    }

    /// Verifies that encryption failure with an invalid public key calls didFail on the delegate.
    func testPaymentSubmitWithInvalidPublicKey() throws {
        // Given
        let proxy = makeSUT(publicKey: "invalid_key")
        let delegate = PaymentComponentDelegateMock()
        proxy.component.delegate = delegate

        let failExpectation = expectation(description: "Expect didFail to be called")
        delegate.onDidSubmit = { _, _ in XCTFail("didSubmit should not be called") }
        delegate.onDidFail = { _, _ in failExpectation.fulfill() }

        // When
        proxy.present(on: self)
        proxy.enterSecurityCode("737")
        proxy.tapPayButton()

        // Then
        waitForExpectations(timeout: 1)

        let args = try XCTUnwrap(delegate.didFailReceivedArguments)
        XCTAssertTrue(args.component === proxy.component)
    }

    // MARK: - CVC Validation

    /// Verifies that AMEX cards require exactly 4 digits for the security code.
    func testCVCLimitForAMEX() {
        // Given
        let proxy = makeSUT(brand: .americanExpress)
        proxy.present(on: self)

        // When / Then - non-numeric characters are filtered
        proxy.enterSecurityCode("a")
        XCTAssertEqual(proxy.securityCodeText, "")

        // When / Then - build up to 4 digits
        proxy.enterSecurityCode("1")
        XCTAssertEqual(proxy.securityCodeText, "1")

        proxy.enterSecurityCode("11")
        XCTAssertEqual(proxy.securityCodeText, "11")

        proxy.enterSecurityCode("111")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertFalse(proxy.isPayButtonEnabled)

        proxy.enterSecurityCode("1111")
        XCTAssertEqual(proxy.securityCodeText, "1111")
        XCTAssertTrue(proxy.isPayButtonEnabled)

        // When / Then - cannot exceed 4 digits
        proxy.enterSecurityCode("11111")
        XCTAssertEqual(proxy.securityCodeText, "1111")
    }

    /// Verifies that non-AMEX cards require exactly 3 digits for the security code.
    func testCVCLimitForNonAMEX() {
        // Given
        let proxy = makeSUT(brand: .visa)
        proxy.present(on: self)

        // When / Then - build up to 3 digits
        proxy.enterSecurityCode("11")
        XCTAssertEqual(proxy.securityCodeText, "11")

        proxy.enterSecurityCode("111")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertTrue(proxy.isPayButtonEnabled)

        // When / Then - cannot exceed 3 digits
        proxy.enterSecurityCode("1111")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertTrue(proxy.isPayButtonEnabled)
    }

    // MARK: - Analytics

    /// Verifies that accessing the view controller sends an initial analytics event.
    func testViewDidLoadShouldSendInitialEvent() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let proxy = makeSUT(analyticsProvider: analyticsProviderMock)

        // When
        _ = proxy.component.viewController

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        brand: CardType = .visa,
        publicKey: String = Dummy.publicKey,
        analyticsProvider: AnyAnalyticsProvider? = nil
    ) -> StoredCardComponentProxy {
        let paymentMethod = StoredCardPaymentMethod(
            type: .card,
            name: "name",
            identifier: "id",
            fundingSource: .credit,
            supportedShopperInteractions: [.shopperPresent],
            brand: brand,
            lastFour: "1234",
            expiryMonth: "12",
            expiryYear: "22",
            holderName: "holderName"
        )

        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: publicKey,
            analyticsProvider: analyticsProvider ?? AnalyticsProviderMock()
        )

        let component = StoredCardComponent(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            theme: CheckoutTheme()
        )

        return StoredCardComponentProxy(component: component, context: context)
    }
}

// MARK: - StoredCardComponentProxy

/// A test proxy that abstracts the UI implementation details of StoredCardComponent.
/// This allows tests to be agnostic to whether the component uses UIAlertController
/// or StoredCardInputViewController underneath.
@MainActor
final class StoredCardComponentProxy {

    let component: StoredCardComponent
    let context: AdyenContext

    init(component: StoredCardComponent, context: AdyenContext) {
        self.component = component
        self.context = context
    }

    // MARK: - Presentation

    func present(on testCase: XCTestCase) {
        testCase.presentOnRoot(component.viewController)
    }

    // MARK: - Security Code

    var securityCodeText: String? {
        alertTextField?.text
    }

    func enterSecurityCode(_ code: String) {
        guard let textField = alertTextField else { return }
        textField.text = code
        textField.sendActions(for: .editingChanged)
    }

    // MARK: - Buttons

    var hasCancelButton: Bool {
        alertController?.actions.contains { $0.title == localizedString(.cancelButton, nil) } ?? false
    }

    var hasPayButton: Bool {
        payAction != nil
    }

    var isPayButtonEnabled: Bool {
        payAction?.isEnabled ?? false
    }

    func tapPayButton() {
        payAction?.tap()
    }

    // MARK: - Private (UIAlertController implementation)

    private var alertController: UIAlertController? {
        component.viewController as? UIAlertController
    }

    private var alertTextField: UITextField? {
        alertController?.textFields?.first
    }

    private var payAction: UIAlertAction? {
        let buttonTitle = localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil)
        return alertController?.actions.first { $0.title == buttonTitle }
    }
}

// MARK: - UIAlertAction+Tap

extension UIAlertAction {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tap() {
        let closure = self.value(forKey: "handler")

        let handler = unsafeBitCast(closure as AnyObject, to: AlertHandler.self)

        handler(self)
    }
}
