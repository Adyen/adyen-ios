//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

// TODO: FIX Stored PM Tests after UI changes
// class StoredPaymentMethodComponentTests: XCTestCase {
//
//    private var context = Dummy.context
//
//    private let method = StoredPaymentMethodMock(
//        identifier: "id",
//        supportedShopperInteractions: [.shopperPresent],
//        type: .other("type"),
//        name: "name"
//    )
//
//    func testLocalizationWithCustomTableName() throws {
//        let localizationParams = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
//        let sut = StoredPaymentMethodComponent(
//            paymentMethod: method,
//            context: context
//            // configuration: .init(localizationParameters: localizationParams)
//        )
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, localizationParams))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, localizationParams))
//    }
//
//    func testLocalizationWithZeroPayment() throws {
//        let payment = Payment(amount: Amount(value: 0, currencyCode: "EUR"), countryCode: "DE")
//        let context = Dummy.context(with: payment)
//
//        let sut = StoredPaymentMethodComponent(
//            paymentMethod: method,
//            context: context
//            // configuration: .init()
//        )
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, nil))
//
//        XCTAssertEqual(viewController?.actions.last?.title, "Confirm preauthorization")
//    }
//
//    func testLocalizationWithCustomKeySeparator() throws {
//        let localizationParams = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
//        let sut = StoredPaymentMethodComponent(
//            paymentMethod: method,
//            context: context
//            //  configuration: .init(localizationParameters: localizationParams)
//        )
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, localizationParams))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, localizationParams))
//    }
//
//    func testUI() throws {
//        let sut = StoredPaymentMethodComponent(
//            paymentMethod: method,
//            context: context
//            // configuration: .init()
//        )
//
//        let delegate = PaymentComponentDelegateMock()
//
//        let delegateExpectation = expectation(description: "expect delegate to be called.")
//        delegate.onDidSubmit = { data, component in
//            XCTAssertTrue(component === sut)
//            XCTAssertNotNil(data.paymentMethod as? StoredPaymentDetails)
//
//            let details = data.paymentMethod as! StoredPaymentDetails
//            XCTAssertEqual(details.type.rawValue, "type")
//            XCTAssertEqual(details.storedPaymentMethodIdentifier, "id")
//
//            delegateExpectation.fulfill()
//        }
//        delegate.onDidFail = { _, _ in
//            XCTFail("delegate.didFail() should never be called.")
//        }
//        sut.delegate = delegate
//
//        presentOnRoot(sut.viewController)
//
//        let uiExpectation = expectation(description: "Dummy Expectation")
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//            let alertController = sut.viewController as! UIAlertController
//
//            XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
//            XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil) })
//
//            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil) }!
//
//            payAction.tap()
//
//            uiExpectation.fulfill()
//        }
//        waitForExpectations(timeout: 10, handler: nil)
//    }
//
//    func testStoredACHComponent() {
//        let paymentMethod = StoredACHDirectDebitPaymentMethod(
//            type: .achDirectDebit,
//            name: "ACH",
//            identifier: "ach",
//            supportedShopperInteractions: [.shopperPresent],
//            bankAccountNumber: "5678865"
//        )
//        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil))
//        XCTAssertEqual(viewController?.message, paymentMethod.overriddenDisplayInformation(using: nil).title)
//    }
//
//    func testStoredCashAppPay() {
//        let paymentMethod = StoredCashAppPayPaymentMethod(
//            type: .cashAppPay,
//            name: "Cash App Pay",
//            cashtag: "$cashtag_token",
//            identifier: "cashapp",
//            supportedShopperInteractions: [.shopperPresent]
//        )
//        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil))
//        XCTAssertEqual(viewController?.message, paymentMethod.cashtag)
//        XCTAssertEqual(viewController?.title, localizedString(.dropInStoredTitle, nil, paymentMethod.name))
//    }
//
//    func testStoredTwintComponent() throws {
//        // Given
//        let paymentMethod = StoredTwintPaymentMethod(
//            type: .twint,
//            name: "Twint",
//            identifier: "twint",
//            supportedShopperInteractions: [.shopperPresent]
//        )
//        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
//
//        // When
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil))
//        XCTAssertEqual(viewController?.message, paymentMethod.overriddenDisplayInformation(using: nil).title)
//        XCTAssertEqual(viewController?.title, localizedString(.dropInStoredTitle, nil, paymentMethod.name))
//    }
//
//    func test_storedPaymentComponent_matches_payTo() throws {
//        // Given
//        let paymentMethod = StoredPayToPaymentMethod(
//            type: .payTo,
//            name: "PayTo Account",
//            identifier: "twint",
//            label: "***123",
//            supportedShopperInteractions: [.shopperPresent]
//        )
//        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
//
//        let viewController = sut.viewController as? UIAlertController
//        XCTAssertNotNil(viewController)
//        XCTAssertEqual(viewController?.actions.count, 2)
//        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
//        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil))
//        XCTAssertEqual(viewController?.message, paymentMethod.overriddenDisplayInformation(using: nil).title)
//        XCTAssertEqual(viewController?.title, localizedString(.dropInStoredTitle, nil, paymentMethod.name))
//    }
//
//    func testViewDidLoadShouldSendInitialEvent() throws {
//        // Given
//        let analyticsProviderMock = AnalyticsProviderMock()
//        let context = Dummy.context(with: analyticsProviderMock)
//
//        let sut = StoredPaymentMethodComponent(
//            paymentMethod: method,
//            context: context
//        )
//
//        // When
//        sut.viewController.viewDidLoad()
//
//        // Then
//        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
//    }
// }

@MainActor
internal final class StoredPaymentMethodComponentTests: XCTestCase {

    internal func test_validStoredPaymentMethod_whenSubmitting_thenProvidesStoredPaymentDetails() {
        let sut = makeSUT()
        let delegate = PaymentComponentDelegateMock()
        let expectation = expectation(description: "Stored payment details submitted")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let details = try? XCTUnwrap(data.paymentMethod as? StoredPaymentDetails)
            XCTAssertEqual(details?.type, .other("type"))
            XCTAssertEqual(details?.storedPaymentMethodIdentifier, "id")
            expectation.fulfill()
        }
        sut.delegate = delegate

        sut.performSubmit()

        waitForExpectations(timeout: 1)
    }

    internal func test_directStoredPaymentMethod_whenAccessingViewController_thenReturnsPaymentButton() {
        let sut = makeSUT()

        XCTAssertTrue(sut.viewController is PaymentButtonViewController)
        XCTAssertFalse(sut.requiresUserInteraction)
    }

    internal func test_directStoredPaymentMethod_whenAccessedTwice_thenReturnsSameViewController() {
        let sut = makeSUT()

        XCTAssertTrue(sut.viewController === sut.viewController)
    }

    internal func test_directStoredPaymentMethod_whenSubmittingFromPaymentButton_thenSubmitsStoredDetails() throws {
        let sut = makeSUT()
        let delegate = PaymentComponentDelegateMock()
        let expectation = expectation(description: "Stored payment details submitted")
        delegate.onDidSubmit = { data, _ in
            XCTAssertTrue(data.paymentMethod is StoredPaymentDetails)
            expectation.fulfill()
        }
        sut.delegate = delegate
        let viewController = try XCTUnwrap(sut.viewController as? PaymentButtonViewController)

        viewController.onSubmit?()

        waitForExpectations(timeout: 1)
    }

    internal func test_directStoredPaymentMethod_whenSubmittingMultipleTimes_thenSendsInitialAnalyticsOnce() {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))

        sut.performSubmit()
        sut.performSubmit()

        XCTAssertEqual(analyticsProvider.initialEventCallsCount, 1)
    }

    internal func test_directStoredPaymentMethod_whenViewControllerLoads_thenSendsRenderedEvent() throws {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))
        let viewController = try XCTUnwrap(sut.viewController as? PaymentButtonViewController)

        viewController.loadViewIfNeeded()

        XCTAssertEqual(analyticsProvider.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProvider.infos.count, 1)
        XCTAssertEqual(analyticsProvider.infos.first?.type, .rendered)
        XCTAssertEqual(analyticsProvider.infos.first?.isStoredPaymentMethod, true)
    }

    internal func test_directStoredPaymentMethod_whenRenderedThenSubmitted_thenSendsInitialAnalyticsOnce() throws {
        let analyticsProvider = AnalyticsProviderMock()
        let sut = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))
        let viewController = try XCTUnwrap(sut.viewController as? PaymentButtonViewController)

        viewController.loadViewIfNeeded()
        sut.performSubmit()

        XCTAssertEqual(analyticsProvider.initialEventCallsCount, 1)
    }

    private func makeContext(analyticsProvider: AnalyticsProviderMock) -> AdyenContext {
        AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: analyticsProvider
        )
    }

    private func makeSUT(context: AdyenContext = Dummy.context) -> StoredPaymentMethodComponent {
        let paymentMethod = StoredPaymentMethodMock(
            identifier: "id",
            supportedShopperInteractions: [.shopperPresent],
            type: .other("type"),
            name: "name"
        )
        return StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
    }
}
