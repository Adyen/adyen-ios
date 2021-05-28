//
//  StoredCardComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/17/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class StoredCardComponentTests: XCTestCase {

    func testUIWithClientKey() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
            XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) })

            expectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        wait(for: [expectation], timeout: 10)
    }

    func testUIWithPublicKey() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = nil
        CardPublicKeyProvider.cachedCardPublicKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
            XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) })

            expectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        wait(for: [expectation], timeout: 10)
    }

    func testPaymentSubmitWithSuccessfulCardPublicKeyFetching() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

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

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.dummyPublicKey))
        }
        sut.storedCardAlertManager.cardPublicKeyProvider = cardPublicKeyProvider

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            textField?.text = "737"
            textField?.sendActions(for: .editingChanged)

            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) }!

            payAction.tap()

            dummyExpectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPaymentSubmitWithFailedCardPublicKeyFetching() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { _, _ in
            XCTFail("delegate.didSubmit() should never be called.")
        }
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(error as? Dummy == Dummy.dummyError)
            XCTAssertTrue(component === sut)
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.failure(Dummy.dummyError))
        }
        sut.storedCardAlertManager.cardPublicKeyProvider = cardPublicKeyProvider

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            textField?.text = "737"
            textField?.sendActions(for: .editingChanged)

            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) }!

            payAction.tap()

            dummyExpectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCVCLimitForAMEX() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "amex",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField! = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) }!

            textField.insertText("a")
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "a"), false)

            textField.text = "1"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "1"), true)

            textField.text = "11"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 1, length: 1), replacementString: "1"), true)

            textField.text = "111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 2, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, false)

            textField.text = "1111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 3, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, true)

            textField.text = "11111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 4, length: 1), replacementString: "1"), false)

            dummyExpectation.fulfill()
            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCVCLimitForNonAMEX() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "mc",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField! = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) }!

            textField.text = "11"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 1, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, false)

            textField.text = "111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 2, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, true)

            textField.text = "1111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 3, length: 1), replacementString: "1"), false)

            dummyExpectation.fulfill()
            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCVCLimitForUnknownCardType() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "some_brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = Dummy.dummyClientKey

        let payemt = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField! = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payemt.amount, style: .immediate, nil) }!

            textField.text = "11"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 1, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, false)

            textField.text = "111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 2, length: 1), replacementString: "1"), true)
            XCTAssertEqual(payAction.isEnabled, true)

            textField.text = "1111"
            textField?.sendActions(for: .editingChanged)
            XCTAssertEqual(textField.delegate!.textField!(textField, shouldChangeCharactersIn: NSRange(location: 3, length: 1), replacementString: "1"), true)

            dummyExpectation.fulfill()
            alertController.dismiss(animated: false, completion: nil)

        }
        waitForExpectations(timeout: 10, handler: nil)
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
