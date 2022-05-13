//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
import XCTest

class StoredPaymentMethodComponentTests: XCTestCase {

    private var analyticsProviderMock: AnalyticsProviderMock!
    private var adyenContext: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        adyenContext = AdyenContext(apiContext: Dummy.context, analyticsProvider: analyticsProviderMock)
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        adyenContext = nil
        try super.tearDownWithError()
    }

    func testLocalizationWithCustomTableName() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: .other("test_type"), name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                                              adyenContext: adyenContext)
        let payment = Payment(amount: Amount(value: 34, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, sut.localizationParameters))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testLocalizationWithZeroPayment() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: .other("test_type"), name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                                              adyenContext: adyenContext)
        let payment = Payment(amount: Amount(value: 0, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment

        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, sut.localizationParameters))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))

        XCTAssertEqual(viewController?.actions.last?.title, "Confirm preauthorization")
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: .other("test_type"), name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                                              adyenContext: adyenContext)
        let payment = Payment(amount: Amount(value: 34, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, sut.localizationParameters))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testUI() {
        let method = StoredPaymentMethodMock(identifier: "id",
                                             supportedShopperInteractions: [.shopperPresent],
                                             type: .other("type"),
                                             name: "name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                                              adyenContext: adyenContext)

        let delegate = PaymentComponentDelegateMock()

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? StoredPaymentDetails)

            let details = data.paymentMethod as! StoredPaymentDetails
            XCTAssertEqual(details.type.rawValue, "type")
            XCTAssertEqual(details.storedPaymentMethodIdentifier, "id")

            delegateExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        sut.delegate = delegate

        let payment = Payment(amount: Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payment

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let uiExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController

            XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
            XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: payment.amount, style: .immediate, nil) })

            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: payment.amount, style: .immediate, nil) }!

            payAction.tap()

            uiExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testViewDidLoadShouldSendTelemetryEvent() throws {
        // Given
        let method = StoredPaymentMethodMock(identifier: "id",
                                             supportedShopperInteractions: [.shopperPresent],
                                             type: .other("type"),
                                             name: "name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                                              adyenContext: adyenContext)

        // When
        sut.viewController.viewDidLoad()

        // Then
        XCTAssertEqual(analyticsProviderMock.trackTelemetryEventCallsCount, 1)
    }
}
