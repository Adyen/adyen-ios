//
//  BLIKComponentTests.swift
//  AdyenTests
//
//  Created by Vladimir Abramichev on 03/11/2020.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BLIKComponentTests: XCTestCase {

    lazy var method = BLIKPaymentMethod(type: .blik, name: "test_name")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
    var context: AdyenContext { Dummy.context(with: payment) }
    var sut: BLIKComponent!

    override func setUp() {
        sut = BLIKComponent(paymentMethod: method, context: context)
    }

    override func tearDown() {
        sut = nil
    }

    func testLocalizationWithCustomTableName() throws {
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.hintLabelItem.text, localizedString(.blikHelp, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(.blikCode, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(.blikPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(.blikInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithZeroPayment() throws {
        let payment = Payment(amount: Amount(value: 0, currencyCode: "PLN"), countryCode: "PL")
        let context: AdyenContext = Dummy.context(with: payment)
        sut = BLIKComponent(paymentMethod: method, context: context)
        
        XCTAssertEqual(sut.hintLabelItem.text, localizedString(.blikHelp, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(.blikCode, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(.blikPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(.blikInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.hintLabelItem.text, localizedString(LocalizationKey(key: "adyen_blik_help"), sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(LocalizationKey(key: "adyen_blik_code"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(LocalizationKey(key: "adyen_blik_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_blik_invalid"), sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_submitButton_formatted"), sut.configuration.localizationParameters, payment.amount.formatted))
    }
 
    func testVCTitle() {

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        XCTAssertEqual(sut.viewController.title, method.name.uppercased())
    }

    func testRequiresModalPresentation() {
        let blikPaymentMethod = BLIKPaymentMethod(type: .blik, name: "Test name")
        let sut = BLIKComponent(paymentMethod: blikPaymentMethod, context: context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // When
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        sut = BLIKComponent(paymentMethod: method, context: context)
        sut.viewWillAppear(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
}
