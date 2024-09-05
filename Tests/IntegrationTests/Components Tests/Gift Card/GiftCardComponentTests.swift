//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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

    var giftCardPaymentMethod: GiftCardPaymentMethod!

    var amountToPay: Amount { Dummy.payment.amount }

    var errorView: FormErrorItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.errorItem")
    }

    var numberItemView: FormTextInputItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.numberItem")
    }

    var securityCodeItemTitleLabel: UILabel? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.securityCodeItem.titleLabel")
    }
    
    var securityCodeItemView: FormTextInputItemView? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.securityCodeItem")
    }
    
    var expiryDateItemView: FormItemView<FormCardExpiryDateItem>? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.expiryDateItem")
    }

    var payButtonItemViewButton: UIControl? {
        sut.viewController.view.findView(with: "AdyenCard.GiftCardComponent.payButtonItem.button")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        giftCardPaymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "testName", brand: "testBrand")
        publicKeyProvider = PublicKeyProviderMock()

        context = Dummy.context

        sut = GiftCardComponent(
            partialPaymentMethodType: .giftCard(giftCardPaymentMethod),
            context: context,
            amount: amountToPay,
            publicKeyProvider: publicKeyProvider
        )
        delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        partialPaymentDelegate = PartialPaymentDelegateMock()
        sut.partialPaymentDelegate = partialPaymentDelegate
        readyToSubmitPaymentComponentDelegate = ReadyToSubmitPaymentComponentDelegateMock()
        sut.readyToSubmitComponentDelegate = readyToSubmitPaymentComponentDelegate
    }

    override func tearDownWithError() throws {
        giftCardPaymentMethod = nil
        publicKeyProvider = nil
        context = nil
        delegateMock = nil
        partialPaymentDelegate = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGiftCardUI() {
        
        // Given
        let paymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "testName", brand: "testBrand")
        sut = GiftCardComponent(
            partialPaymentMethodType: .giftCard(paymentMethod),
            context: context,
            amount: amountToPay,
            publicKeyProvider: publicKeyProvider
        )
        
        // When
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        // Then
        XCTAssertNil(expiryDateItemView, "should not have expiry date field for gift card")
        XCTAssertNotNil(securityCodeItemView, "security code should be shown by default")
        XCTAssertEqual(securityCodeItemTitleLabel?.text, "Pin", "cvc title changes based on payment method")
    }
    
    func testMealVoucherUI() {
        
        // Given
        let paymentMethod = MealVoucherPaymentMethod(type: .mealVoucherSodexo, name: "Sodexo")
        sut = GiftCardComponent(
            partialPaymentMethodType: .mealVoucher(paymentMethod),
            context: context,
            amount: amountToPay,
            publicKeyProvider: publicKeyProvider
        )
        
        // When
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))
        
        // Then
        XCTAssertNotNil(expiryDateItemView, "should have expiry date field for meal voucher")
        XCTAssertNotNil(securityCodeItemView, "security code should be shown by default")
        XCTAssertEqual(securityCodeItemTitleLabel?.text, "Security code", "cvc title changes based on payment method")
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

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "An unknown error occurred")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCheckBalanceCardNumberFormatting() throws {

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "123456781234567812345678", pin: "73737")

        XCTAssertEqual(numberItemView?.textField.text, "1234 5678 1234 5678 1234 5678")

        populate(cardNumber: "123456781234567812345", pin: "73737")

        XCTAssertEqual(numberItemView?.textField.text, "1234 5678 1234 5678 1234 5")
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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

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

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        XCTAssertTrue(errorView!.isHidden)

        populate(cardNumber: "60643650100000000000", pin: "73737")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        wait(for: .seconds(1))

        XCTAssertFalse(errorView!.isHidden)
        XCTAssertEqual(sut.errorItem.message, "An unknown error occurred")

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        sut = GiftCardComponent(
            partialPaymentMethodType: .giftCard(giftCardPaymentMethod),
            context: context,
            amount: amountToPay,
            publicKeyProvider: publicKeyProvider
        )

        let mockViewController = UIViewController()

        // When
        sut.viewDidLoad(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }
    
    func testGiftCardHidingSecurityCodeItemView() throws {
        
        // Given
        sut = GiftCardComponent(
            partialPaymentMethodType: .giftCard(giftCardPaymentMethod),
            context: context,
            amount: amountToPay,
            showsSecurityCodeField: false,
            publicKeyProvider: publicKeyProvider
        )

        // When
        let mockViewController = UIViewController()
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertNotNil(numberItemView)
        XCTAssertNil(securityCodeItemView)
    }
    
    func testMealVoucherHidingSecurityCodeItemView() {
        
        // Given
        let paymentMethod = MealVoucherPaymentMethod(type: .mealVoucherSodexo, name: "Sodexo")
        sut = GiftCardComponent(
            partialPaymentMethodType: .mealVoucher(paymentMethod),
            context: context,
            amount: amountToPay,
            showsSecurityCodeField: false,
            publicKeyProvider: publicKeyProvider
        )
        
        // When
        let mockViewController = UIViewController()
        sut.viewWillAppear(viewController: mockViewController)
        
        // Then
        XCTAssertNotNil(numberItemView)
        XCTAssertNotNil(expiryDateItemView, "expiry date should still be shown when security code item is hidden")
        XCTAssertNil(securityCodeItemView)
    }
    
    func testPartialConfirmationPaymentMethod() {
        
        let giftCard = GiftCardPaymentMethod(type: .giftcard, name: "Giftcard", brand: "giftcard")
        
        let paymentMethod = PartialConfirmationPaymentMethod(
            paymentMethod: giftCard,
            lastFour: "1234",
            remainingAmount: .init(value: 1000, currencyCode: "USD")
        )
        
        XCTAssertEqual(paymentMethod.type, giftCard.type)
        
        let displayInformation = paymentMethod.defaultDisplayInformation(using: nil)
        
        XCTAssertEqual(displayInformation.title, "•••• 1234")
        XCTAssertEqual(displayInformation.logoName, giftCard.brand)
        XCTAssertEqual(displayInformation.accessibilityLabel, "Giftcard, Last 4 digits: 1, 2, 3, 4, Remaining balance will be $10.00")
    }
    
    func testPartialPaymentOrder() throws {
        
        let order = PartialPaymentOrder(
            pspReference: "psp-reference",
            orderData: "order-data",
            reference: "reference",
            amount: .init(value: 1000, currencyCode: "USD"),
            remainingAmount: .init(value: 500, currencyCode: "USD"),
            expiresAt: Date()
        )
        
        let encodedOrder = try JSONEncoder().encode(order)
        let decodedOrder = try JSONDecoder().decode(PartialPaymentOrder.self, from: encodedOrder)
        
        XCTAssertEqual(order.pspReference, decodedOrder.pspReference)
        XCTAssertEqual(order.orderData, decodedOrder.orderData)
        XCTAssertEqual(order.reference, decodedOrder.reference)
        XCTAssertEqual(order.amount, decodedOrder.amount)
        XCTAssertEqual(order.remainingAmount, decodedOrder.remainingAmount)
        XCTAssertNil(decodedOrder.expiresAt)
        XCTAssertEqual(order.compactOrder, decodedOrder.compactOrder)
    }
}

private extension GiftCardComponentTests {
    
    func populate(cardNumber: String, pin: String) {
        populate(textItemView: numberItemView!, with: cardNumber)
        populate(textItemView: securityCodeItemView!, with: pin)
    }
}
