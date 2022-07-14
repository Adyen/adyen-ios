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

    func testUIConfiguration() {
        var style = FormComponentStyle()

        style.hintLabel.backgroundColor = .brown
        style.hintLabel.font = .systemFont(ofSize: 10)
        style.hintLabel.textAlignment = .center
        style.hintLabel.color = .cyan

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// background color
        style.backgroundColor = .red

        /// Text field
        style.textField.text.color = .red
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        sut = BLIKComponent(paymentMethod: method, context: context, configuration: .init(style: style))

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))
        let hintView: UILabel! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeHintLabel")

        let blikCodeView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
        let blikCodeViewTitleLabel: UILabel! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem.titleLabel")
        let blikCodeViewTextField: UITextField! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem.textField")

        let payButtonItemViewButton: UIControl! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")
        let payButtonItemViewButtonTitle: UILabel! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button.titleLabel")

        XCTAssertEqual(hintView.backgroundColor, .brown)
        XCTAssertEqual(hintView.textColor, .cyan)
        XCTAssertEqual(hintView.textAlignment, .center)
        XCTAssertEqual(hintView.font, .systemFont(ofSize: 10))

        /// Test BINK code field
        XCTAssertEqual(blikCodeView.backgroundColor, .red)
        XCTAssertEqual(blikCodeViewTitleLabel.textColor, sut.viewController.view.tintColor)
        XCTAssertEqual(blikCodeViewTitleLabel.backgroundColor, .blue)
        XCTAssertEqual(blikCodeViewTitleLabel.textAlignment, .center)
        XCTAssertEqual(blikCodeViewTitleLabel.font, .systemFont(ofSize: 20))
        XCTAssertEqual(blikCodeViewTextField.backgroundColor, .red)
        XCTAssertEqual(blikCodeViewTextField.textAlignment, .right)
        XCTAssertEqual(blikCodeViewTextField.textColor, .red)
        XCTAssertEqual(blikCodeViewTextField.font, .systemFont(ofSize: 13))

        /// Test footer
        XCTAssertEqual(payButtonItemViewButton.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle.backgroundColor, .red)
        XCTAssertEqual(payButtonItemViewButtonTitle.textAlignment, .center)
        XCTAssertEqual(payButtonItemViewButtonTitle.textColor, .white)
        XCTAssertEqual(payButtonItemViewButtonTitle.font, .systemFont(ofSize: 22))
    }

    func testSubmitForm() {
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            XCTAssertTrue(data.paymentMethod is BLIKDetails)
            let data = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(data.blikCode, "123456")

            self.sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(self.sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(self.sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(300))
        let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.payButtonItem.button")

        let blikCodeView: FormTextInputItemView! = sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem")
        self.populate(textItemView: blikCodeView, with: "123456")

        submitButton?.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testVCTitle() {

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

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
