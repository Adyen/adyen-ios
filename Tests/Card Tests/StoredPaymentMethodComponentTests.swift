//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
import XCTest

class StoredPaymentMethodComponentTests: XCTestCase {

    private var context = Dummy.context

    private let method = StoredPaymentMethodMock(identifier: "id",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 type: .other("type"),
                                                 name: "name")

    func testLocalizationWithCustomTableName() throws {
        let localizationParams = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                               context: context,
                                               configuration: .init(localizationParameters: localizationParams))

        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, localizationParams))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, localizationParams))
    }

    func testLocalizationWithZeroPayment() throws {
        let payment = Payment(amount: Amount(value: 0, currencyCode: "EUR"), countryCode: "DE")
        let context = Dummy.context(with: payment)

        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                               context: context,
                                               configuration: .init())

        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, nil))

        XCTAssertEqual(viewController?.actions.last?.title, "Confirm preauthorization")
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let localizationParams = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                               context: context,
                                               configuration: .init(localizationParameters: localizationParams))

        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, localizationParams))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, localizationParams))
    }

    func testUI() throws {
        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                               context: context,
                                               configuration: .init())

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

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let uiExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController

            XCTAssertTrue(alertController.actions.contains { $0.title == localizedString(.cancelButton, nil) })
            XCTAssertTrue(alertController.actions.contains { $0.title == localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil) })

            let payAction = alertController.actions.first { $0.title == localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil) }!

            payAction.tap()

            uiExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testStoredACHComponent() {
        let paymentMethod = StoredACHDirectDebitPaymentMethod(type: .achDirectDebit,
                                                              name: "ACH",
                                                              identifier: "ach",
                                                              supportedShopperInteractions: [.shopperPresent],
                                                              bankAccountNumber: "5678865")
        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
        
        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, localizedString(.cancelButton, nil))
        XCTAssertEqual(viewController?.actions.last?.title, localizedSubmitButtonTitle(with: Dummy.payment.amount, style: .immediate, nil))
        XCTAssertEqual(viewController?.message, paymentMethod.defaultDisplayInformation(using: nil).title)
    }

    func testViewDidLoadShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        let sut = StoredPaymentMethodComponent(paymentMethod: method,
                                               context: context)

        // When
        sut.viewController.viewDidLoad()

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
