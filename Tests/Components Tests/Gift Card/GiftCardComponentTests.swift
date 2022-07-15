//
//  GiftCardComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class GiftCardComponentTests: XCTestCase {

    var partialPaymentDelegate: PartialPaymentDelegateMock!

    var readyToSubmitPaymentComponentDelegate: ReadyToSubmitPaymentComponentDelegateMock!

    var delegateMock: PaymentComponentDelegateMock!

    var publicKeyProvider: PublicKeyProviderMock!

    var context: AdyenContext!

    var sut: GiftCardComponent!

    var paymentMethod: GiftCardPaymentMethod!

    var amountToPay: Amount { Dummy.payment.amount }

    var errorView: FormErrorItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.errorItem")
    }

    var numberItemView: FormTextInputItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.numberItem")
    }

    var securityCodeItemView: FormTextInputItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.securityCodeItem")
    }

    var payButtonItemViewButton: UIControl? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.payButtonItem.button")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "testName", brand: "testBrand")
        publicKeyProvider = PublicKeyProviderMock()

        context = Dummy.context

        sut = GiftCardComponent(paymentMethod: paymentMethod,
                                context: context,
                                amount: amountToPay,
                                publicKeyProvider: publicKeyProvider)
        delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        partialPaymentDelegate = PartialPaymentDelegateMock()
        sut.partialPaymentDelegate = partialPaymentDelegate
        readyToSubmitPaymentComponentDelegate = ReadyToSubmitPaymentComponentDelegateMock()
        sut.readyToSubmitComponentDelegate = readyToSubmitPaymentComponentDelegate
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        publicKeyProvider = nil
        context = nil
        delegateMock = nil
        partialPaymentDelegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testCheckBalanceFailure() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        let didFailExpectation = expectation(description: "Expect delegateMock.onDidFail to be called.")
        didFailExpectation.assertForOverFulfill = true
        delegateMock.onDidFail = { error, component in
            XCTAssertTrue(component === self.sut)
            XCTAssertNotNil(error as? Dummy)
            didFailExpectation.fulfill()
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")

        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.failure(Dummy.error))
            onCheckBalanceExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "An unknown error occurred")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testBalanceAndTransactionLimitCurrencyMismatch() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 200, currencyCode: "EUR"), transactionLimit: .init(value: 1000, currencyCode: "USD"))
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "Gift cards are only valid in the currency they were issued in")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPaymentAndBalanceCurrencyMissmatch() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 200, currencyCode: "USD"), transactionLimit: .init(value: 1000, currencyCode: "USD"))
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "Gift cards are only valid in the currency they were issued in")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testZeroBalance() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 0, currencyCode: "EUR"), transactionLimit: .init(value: 1000, currencyCode: "EUR"))
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "This gift card has zero balance")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testEnoughBalanceIsAvailableWithNilReadyToSubmitDelegate() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        sut.readyToSubmitComponentDelegate = nil

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 200, currencyCode: "EUR"), transactionLimit: nil)
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        partialPaymentDelegate.onRequestOrder = { _ in
            XCTFail("partialPaymentDelegate.onRequestOrder must not be called.")
        }

        let onSubmitExpectation = expectation(description: "Expect delegateMock.onDidSubmit to be called.")
        delegateMock.onDidSubmit = { data, component in
            XCTAssertNil(data.order)
            XCTAssertTrue(component === self.sut)
            onSubmitExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertTrue(errorView!.isHidden)
        XCTAssertNil(sut.errorItem.message)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testEnoughBalanceIsAvailableWithReadyToSubmitDelegate() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 200, currencyCode: "EUR"), transactionLimit: nil)
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        partialPaymentDelegate.onRequestOrder = { _ in
            XCTFail("partialPaymentDelegate.onRequestOrder must not be called.")
        }

        delegateMock.onDidSubmit = { data, component in
            XCTFail("delegateMock.onDidSubmit must not be called")
        }

        let onShowConfirmationExpectation = expectation(description: "Expect readyToSubmitPaymentComponentDelegate.onShowConfirmation to be called.")
        readyToSubmitPaymentComponentDelegate.onShowConfirmation = { _, order in
            XCTAssertNil(order)
            onShowConfirmationExpectation.fulfill()
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertTrue(errorView!.isHidden)
        XCTAssertNil(sut.errorItem.message)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNotAvailableBalanceRequestOrderSuccess() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 50, currencyCode: "EUR"), transactionLimit: nil)
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        let expectedOrder = PartialPaymentOrder(pspReference: "reference", orderData: "orderData")
        let onRequestOrderExpectation = expectation(description: "Expect partialPaymentDelegate.onRequestOrder to be called.")
        partialPaymentDelegate.onRequestOrder = { completion in
            completion(.success(expectedOrder))
            onRequestOrderExpectation.fulfill()
        }

        let onSubmitExpectation = expectation(description: "Expect delegateMock.onDidSubmit to be called.")
        delegateMock.onDidSubmit = { data, component in
            XCTAssertEqual(data.order, expectedOrder)
            onSubmitExpectation.fulfill()
        }

        readyToSubmitPaymentComponentDelegate.onShowConfirmation = { _, _ in
            XCTFail("readyToSubmitPaymentComponentDelegate.onShowConfirmation must not be called")
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertTrue(errorView!.isHidden)
        XCTAssertNil(sut.errorItem.message)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNotAvailableBalanceOrderAlreadyExists() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        sut.order = PartialPaymentOrder(pspReference: "pspreference", orderData: "data")

        delegateMock.onDidFail = { error, component in
            XCTFail("delegateMock.onDidFail shouldn't be reported back to merchant.")
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 50, currencyCode: "EUR"), transactionLimit: nil)
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        let expectedOrder = sut.order
        partialPaymentDelegate.onRequestOrder = { completion in
            XCTFail("This should never be called because there is already an order")
        }

        let onSubmitExpectation = expectation(description: "Expect delegateMock.onDidSubmit to be called.")
        delegateMock.onDidSubmit = { data, component in
            XCTAssertEqual(data.order, expectedOrder)
            onSubmitExpectation.fulfill()
        }

        readyToSubmitPaymentComponentDelegate.onShowConfirmation = { _, _ in
            XCTFail("readyToSubmitPaymentComponentDelegate.onShowConfirmation must not be called")
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertTrue(errorView!.isHidden)
        XCTAssertNil(sut.errorItem.message)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNotAvailableBalanceRequestOrderFailure() throws {

        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        publicKeyProviderExpectation.expectedFulfillmentCount = 2
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success(Dummy.publicKey))
        }

        let onDidFailExpectation = expectation(description: "Expect delegateMock.onDidFail to be called.")
        delegateMock.onDidFail = { error, component in
            XCTAssertEqual(error as? Dummy, .error)
            onDidFailExpectation.fulfill()
        }

        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")
        let balance = Balance(availableAmount: .init(value: 50, currencyCode: "EUR"), transactionLimit: nil)
        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.success(balance))
            onCheckBalanceExpectation.fulfill()
        }

        let onRequestOrderExpectation = expectation(description: "Expect partialPaymentDelegate.onRequestOrder to be called.")
        partialPaymentDelegate.onRequestOrder = { completion in
            completion(.failure(Dummy.error))
            onRequestOrderExpectation.fulfill()
        }

        delegateMock.onDidSubmit = { data, component in
            XCTFail("delegateMock.onDidSubmit must not be called")
        }

        readyToSubmitPaymentComponentDelegate.onShowConfirmation = { _, _ in
            XCTFail("readyToSubmitPaymentComponentDelegate.onShowConfirmation must not be called")
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "An unknown error occurred")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        sut = GiftCardComponent(paymentMethod: paymentMethod,
                                context: context,
                                amount: amountToPay,
                                publicKeyProvider: publicKeyProvider)

        let mockViewController = UIViewController()

        // When
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }

    private func populate(cardNumber: String, pin: String) {
        populate(textItemView: numberItemView!, with: cardNumber)
        populate(textItemView: securityCodeItemView!, with: pin)
    }
}
