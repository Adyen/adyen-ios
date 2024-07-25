//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class StoredCardComponentTests: XCTestCase {

    private var context = Dummy.context

    let method = StoredCardPaymentMethod(type: .card,
                                         name: "name",
                                         identifier: "id",
                                         fundingSource: .credit,
                                         supportedShopperInteractions: [.shopperPresent],
                                         brand: .visa,
                                         lastFour: "1234",
                                         expiryMonth: "12",
                                         expiryYear: "22",
                                         holderName: "holderName")

    // let payment = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")

    func testUIWithClientKey() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        XCTAssertNotNil(textField)

        XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
        XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) })

        alertController.dismiss(animated: false, completion: nil)
    }

    func testUIWithPublicKey() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)
        PublicKeyProvider.publicKeysCache[Dummy.apiContext.clientKey] = Dummy.publicKey

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        XCTAssertNotNil(textField)

        XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
        XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) })

        alertController.dismiss(animated: false, completion: nil)
    }

    func testPaymentSubmitWithSuccessfulCardPublicKeyFetching() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        let delegate = PaymentComponentDelegateMock()
        delegate.didSubmitClosure = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? CardDetails)

            let cardDetails = data.paymentMethod as! CardDetails
            XCTAssertNotNil(cardDetails.encryptedSecurityCode)
            XCTAssertNil(cardDetails.encryptedCardNumber)
            XCTAssertNil(cardDetails.encryptedExpiryYear)
            XCTAssertNil(cardDetails.encryptedExpiryMonth)

            delegateExpectation.fulfill()
        }
        delegate.didFailClosure = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        sut.delegate = delegate

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        let publicKeyProvider = PublicKeyProviderMock()
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }
        sut.storedCardAlertManager.publicKeyProvider = publicKeyProvider

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        XCTAssertNotNil(textField)

        textField!.text = "737"
        textField!.sendActions(for: .editingChanged)

        let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) }!

        payAction.tap()
        
        XCTAssertTrue(textField!.text!.isEmpty)
        XCTAssertFalse(payAction.isEnabled)

        alertController.dismiss(animated: false, completion: nil)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPaymentSubmitWithFailedCardPublicKeyFetching() throws {
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)

        let delegate = PaymentComponentDelegateMock()
        delegate.didSubmitClosure = { _, _ in
            XCTFail("delegate.didSubmit() should never be called.")
        }
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.didFailClosure = { error, component in
            XCTAssertTrue(error as? Dummy == Dummy.error)
            XCTAssertTrue(component === sut)
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        let publicKeyProvider = PublicKeyProviderMock()
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.failure(Dummy.error))
        }
        sut.storedCardAlertManager.publicKeyProvider = publicKeyProvider

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        XCTAssertNotNil(textField)

        textField.text = "737"
        textField.sendActions(for: .editingChanged)

        let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) }!

        payAction.tap()

        alertController.dismiss(animated: false, completion: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCVCLimitForAMEX() throws {
        let method = StoredCardPaymentMethod(type: .card,
                                             name: "name",
                                             identifier: "id",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: .americanExpress,
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) }!

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
        let sut = StoredCardComponent(storedCardPaymentMethod: method, context: context)

        presentOnRoot(sut.viewController)
        
        let alertController = sut.viewController as! UIAlertController
        let textField: UITextField! = alertController.textFields!.first
        let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: context.payment?.amount, style: .immediate, nil) }!

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

    func testViewDidLoadShouldSendInitialEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let paymentMethod = storedCardPaymentMethod(brand: .masterCard)
        let sut = StoredCardComponent(storedCardPaymentMethod: paymentMethod,
                                      context: context)

        // When
        sut.viewController.viewDidLoad()

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }

    // MARK: - Private

    private func storedCardPaymentMethod(brand: CardType) -> StoredCardPaymentMethod {
        .init(type: .card,
              name: "name",
              identifier: "id",
              fundingSource: .credit,
              supportedShopperInteractions: [.shopperPresent],
              brand: brand,
              lastFour: "1234",
              expiryMonth: "12",
              expiryYear: "22",
              holderName: "holderName")
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
