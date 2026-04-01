//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class StoredCardComponentTests: XCTestCase {

    private var context = Dummy.context

    let method = StoredCardPaymentMethod(
        type: .card,
        name: "name",
        identifier: "id",
        fundingSource: .credit,
        supportedShopperInteractions: [.shopperPresent],
        brand: .visa,
        lastFour: "1234",
        expiryMonth: "12",
        expiryYear: "22",
        holderName: "holderName"
    )

    // let payment = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")

    func testUIWithClientKey() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context, theme: CheckoutTheme())

        presentOnRoot(sut.viewController)
        
        let alertController = try XCTUnwrap(sut.viewController as? UIAlertController)
        let textField: UITextField! = try XCTUnwrap(alertController.textFields?.first)
        XCTAssertNotNil(textField)

        XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
        XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil) })

        alertController.dismiss(animated: false, completion: nil)
    }

    func testPaymentSubmitWithValidPublicKey() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context, theme: CheckoutTheme())

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? CardDetails)

            let cardDetails = data.paymentMethod as! CardDetails
            XCTAssertNotNil(cardDetails.encryptedSecurityCode)
            XCTAssertNil(cardDetails.encryptedCardNumber)
            XCTAssertNil(cardDetails.encryptedExpiryYear)
            XCTAssertNil(cardDetails.encryptedExpiryMonth)

            delegateExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        sut.delegate = delegate

        presentOnRoot(sut.viewController)
        
        let alertController = try XCTUnwrap(sut.viewController as? UIAlertController)
        let textField: UITextField! = try XCTUnwrap(alertController.textFields?.first)
        XCTAssertNotNil(textField)

        textField?.text = "737"
        textField?.sendActions(for: .editingChanged)

        let payAction = try XCTUnwrap(alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil) })

        payAction.tap()
        
        XCTAssertTrue(try XCTUnwrap(textField?.text?.isEmpty))
        XCTAssertFalse(payAction.isEnabled)

        alertController.dismiss(animated: false, completion: nil)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPaymentSubmitWithInvalidPublicKey() throws {
        let contextWithInvalidKey = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: "invalid_key",
            analyticsProvider: AnalyticsProviderMock()
        )
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: contextWithInvalidKey, theme: CheckoutTheme())

        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { _, _ in
            XCTFail("delegate.didSubmit() should never be called.")
        }
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        presentOnRoot(sut.viewController)
        
        let alertController = try XCTUnwrap(sut.viewController as? UIAlertController)
        let textField: UITextField! = try XCTUnwrap(alertController.textFields?.first)
        XCTAssertNotNil(textField)

        textField.text = "737"
        textField.sendActions(for: .editingChanged)

        let payAction = try XCTUnwrap(alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil) })

        payAction.tap()

        alertController.dismiss(animated: false, completion: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCVCLimitForAMEX() throws {
        let method = StoredCardPaymentMethod(
            type: .card,
            name: "name",
            identifier: "id",
            fundingSource: .credit,
            supportedShopperInteractions: [.shopperPresent],
            brand: .americanExpress,
            lastFour: "1234",
            expiryMonth: "12",
            expiryYear: "22",
            holderName: "holderName"
        )
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context, theme: CheckoutTheme())

        presentOnRoot(sut.viewController)
        
        let alertController = try XCTUnwrap(sut.viewController as? UIAlertController)
        let textField: UITextField! = try XCTUnwrap(alertController.textFields?.first)
        let payAction = try XCTUnwrap(alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil) })

        textField.insertText("a")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "")

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "1")

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "11")

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "111")
        
        XCTAssertEqual(payAction.isEnabled, false)

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "1111")
        XCTAssertEqual(payAction.isEnabled, true)

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "1111")

        alertController.dismiss(animated: false, completion: nil)
    }

    func testCVCLimitForNonAMEX() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context, theme: CheckoutTheme())

        presentOnRoot(sut.viewController)
        
        let alertController = try XCTUnwrap(sut.viewController as? UIAlertController)
        let textField: UITextField! = try XCTUnwrap(alertController.textFields?.first)
        let payAction = try XCTUnwrap(alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.amount, style: .immediate, nil) })

        textField.insertText("11")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "11")

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "111")
        
        XCTAssertEqual(payAction.isEnabled, true)

        textField.insertText("1")
        textField?.sendActions(for: .editingChanged)
        XCTAssertEqual(textField.text, "111")
        XCTAssertEqual(payAction.isEnabled, true)

        alertController.dismiss(animated: false, completion: nil)
    }

    func testViewDidLoadShouldSendInitialEvent() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let paymentMethod = storedCardPaymentMethod(brand: .masterCard)
        let sut = StoredCardComponent(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            theme: CheckoutTheme()
        )

        // When
        sut.viewController.viewDidLoad()

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }

    // MARK: - Private

    private func storedCardPaymentMethod(brand: CardType) -> StoredCardPaymentMethod {
        .init(
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
    }
}

extension UIAlertAction {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tap() {
        let closure = self.value(forKey: "handler")

        let handler = unsafeBitCast(closure as AnyObject, to: AlertHandler.self)

        handler(self)
    }
}
