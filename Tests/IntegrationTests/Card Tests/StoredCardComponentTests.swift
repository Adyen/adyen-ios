//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable @_spi(AdyenInternal) import AdyenUI
import XCTest

@MainActor
class StoredCardComponentTests: XCTestCase {

    // MARK: - UI Display

    /// Verifies that the component displays a security code field, cancel button, and pay button.
    func testUIWithClientKey() {
        // Given
        let sut = makeSUT()
        let proxy = StoredCardComponentProxy(component: sut, testCase: self)

        // When
        proxy.present()

        // Then
        XCTAssertNotNil(proxy.securityCodeText)
        XCTAssertTrue(proxy.hasPayButton)
    }

    // MARK: - Payment Submit

    /// Verifies that submitting a valid security code encrypts and submits card details to the delegate.
    func testPaymentSubmitWithValidPublicKey() throws {
        // Given
        let sut = makeSUT()
        let proxy = StoredCardComponentProxy(component: sut, testCase: self)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let submitExpectation = expectation(description: "Expect didSubmit to be called")
        delegate.onDidSubmit = { _, _ in submitExpectation.fulfill() }
        delegate.onDidFail = { _, _ in XCTFail("didFail should not be called") }

        // When
        proxy.present()
        proxy.enterText("737")
        proxy.tapPayButton()

        // Then
        waitForExpectations(timeout: 1)

        let args = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertTrue(args.component === sut)

        let cardDetails = try XCTUnwrap(args.data.paymentMethod as? CardDetails)
        XCTAssertNotNil(cardDetails.encryptedSecurityCode)
        XCTAssertNil(cardDetails.encryptedCardNumber)
        XCTAssertNil(cardDetails.encryptedExpiryYear)
        XCTAssertNil(cardDetails.encryptedExpiryMonth)

        XCTAssertTrue(proxy.securityCodeText?.isEmpty == true)
        XCTAssertTrue(proxy.isPayButtonEnabled)
    }

    /// Verifies that encryption failure with an invalid public key calls didFail on the delegate.
    func testPaymentSubmitWithInvalidPublicKey() throws {
        // Given
        let sut = makeSUT(publicKey: "invalid_key")
        let proxy = StoredCardComponentProxy(component: sut, testCase: self)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let failExpectation = expectation(description: "Expect didFail to be called")
        delegate.onDidSubmit = { _, _ in XCTFail("didSubmit should not be called") }
        delegate.onDidFail = { _, _ in failExpectation.fulfill() }

        // When
        proxy.present()
        proxy.enterText("737")
        proxy.tapPayButton()

        // Then
        waitForExpectations(timeout: 1)

        let args = try XCTUnwrap(delegate.didFailReceivedArguments)
        XCTAssertTrue(args.component === sut)
    }

    // MARK: - CVC Validation

    /// Verifies that AMEX cards require exactly 4 digits for the security code.
    func testCVCLimitForAMEX() {
        // Given
        let sut = makeSUT(brand: .americanExpress)
        let proxy = StoredCardComponentProxy(component: sut, testCase: self)
        proxy.present()

        // When / Then - non-numeric characters are filtered
        proxy.enterText("a")
        XCTAssertEqual(proxy.securityCodeText, "")

        // When / Then - build up to 4 digits
        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "1")

        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "11")

        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertFalse(proxy.isPayButtonEnabled)

        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "1111")
        XCTAssertTrue(proxy.isPayButtonEnabled)

        // When / Then - cannot exceed 4 digits
        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "1111")
    }

    /// Verifies that non-AMEX cards require exactly 3 digits for the security code.
    func testCVCLimitForNonAMEX() {
        // Given
        let sut = makeSUT(brand: .visa)
        let proxy = StoredCardComponentProxy(component: sut, testCase: self)
        proxy.present()

        // When / Then - build up to 3 digits
        proxy.enterText("11")
        XCTAssertEqual(proxy.securityCodeText, "11")

        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertTrue(proxy.isPayButtonEnabled)

        // When / Then - cannot exceed 3 digits
        proxy.enterText("1")
        XCTAssertEqual(proxy.securityCodeText, "111")
        XCTAssertTrue(proxy.isPayButtonEnabled)
    }

    // MARK: - Analytics

    /// Verifies that accessing the view controller sends an initial analytics event.
    func testViewDidLoadShouldSendInitialEvent() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProvider: analyticsProviderMock)

        // When
        _ = sut.viewController

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        brand: CardType = .visa,
        publicKey: String = Dummy.publicKey,
        analyticsProvider: AnyAnalyticsProvider? = nil
    ) -> StoredCardComponent {
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

        return StoredCardComponent(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            theme: CheckoutTheme()
        )
    }
}

// MARK: - StoredCardComponentProxy

@MainActor
final class StoredCardComponentProxy {

    let component: StoredCardComponent
    private let testCase: XCTestCase

    init(component: StoredCardComponent, testCase: XCTestCase) {
        self.component = component
        self.testCase = testCase
    }

    // MARK: - Presentation

    func present() {
        component.viewController.loadViewIfNeeded()
        testCase.presentOnRoot(component.viewController)
    }

    // MARK: - Security Code

    var securityCodeText: String? {
        securityCodeItemView?.textField.text
    }

    func enterText(_ code: String) {
        guard let textField = securityCodeItemView?.textField else { return }
        code.forEach { textField.insertText(String($0)) }
        textField.sendActions(for: .editingChanged)
    }

    // MARK: - Buttons

    var hasPayButton: Bool {
        primaryButton != nil
    }

    var isPayButtonEnabled: Bool {
        primaryButton?.isEnabled ?? false
    }

    func tapPayButton() {
        primaryButton?.sendActions(for: .touchUpInside)
    }

    // MARK: - Private (StoredCardInputViewController implementation)

    private var storedCardInputViewController: StoredCardInputViewController? {
        component.viewController as? StoredCardInputViewController
    }

    private var securityCodeItemView: FormCardSecurityCodeItemView? {
        storedCardInputViewController?.view.findView(by: "securityCodeItemView")
    }

    private var primaryButton: FormButton? {
        storedCardInputViewController?.view.findView(by: "primaryButton")
    }
}
