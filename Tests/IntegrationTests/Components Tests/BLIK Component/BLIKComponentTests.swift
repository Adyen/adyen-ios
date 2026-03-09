//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class BLIKComponentTests: XCTestCase {

    lazy var paymentMethod = BLIKPaymentMethod(type: .blik, name: "test_name")
    let amount = Amount(value: 2, currencyCode: "PLN")
    var context: AdyenContext {
        Dummy.context(with: amount)
    }

    var sut: BLIKComponent!

    override func setUp() {
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context)
    }

    override func tearDown() {
        sut = nil
    }

    func testLocalizationWithCustomTableName() {
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.hintLabelItem.text, localizedString(.blikHelp, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(.blikCode, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(.blikPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(.blikInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithZeroPayment() {
        let zeroAmount = Amount(value: 0, currencyCode: "PLN")
        let context: AdyenContext = Dummy.context(with: zeroAmount)
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context)
        
        XCTAssertEqual(sut.hintLabelItem.text, localizedString(.blikHelp, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(.blikCode, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(.blikPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(.blikInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, localizedSubmitButtonTitle(with: zeroAmount, style: .immediate, sut.configuration.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() throws {
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.hintLabelItem.text, localizedString(LocalizationKey(key: "adyen_blik_help"), sut.configuration.localizationParameters))

        XCTAssertEqual(sut.codeItem.title, localizedString(LocalizationKey(key: "adyen_blik_code"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.placeholder, localizedString(LocalizationKey(key: "adyen_blik_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.codeItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_blik_invalid"), sut.configuration.localizationParameters))

        XCTAssertEqual(sut.button.title, try localizedString(LocalizationKey(key: "adyen_submitButton_formatted"), sut.configuration.localizationParameters, XCTUnwrap(context.amount?.formatted)))
    }
 
    func testVCTitle() {

        sut.viewController.loadViewIfNeeded()

        wait(for: .milliseconds(300))
        XCTAssertEqual(sut.viewController.title, paymentMethod.name.uppercased())
    }

    func testViewDidLoadShouldSendInitialCall() {
        // When
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context)
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    // MARK: - submit

    func testSubmit_shouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        paymentDelegateMock.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }

        let codeItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem"))

        self.populate(textItemView: codeItemView, with: "123456")

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 1)
    }

    func testValidateGivenValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        var configuration = BLIKComponentConfiguration()
        configuration.showsSubmitButton = false
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        sut.viewController.loadViewIfNeeded()

        let codeItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.BLIKComponent.blikCodeItem"))

        self.populate(textItemView: codeItemView, with: "123456")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateGivenInvalidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        var configuration = BLIKComponentConfiguration()
        configuration.showsSubmitButton = false
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        sut.viewController.loadViewIfNeeded()

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }
}
