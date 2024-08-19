//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BLIKComponentTests: XCTestCase {

    lazy var paymentMethod = BLIKPaymentMethod(type: .blik, name: "test_name")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "PLN"), countryCode: "PL")
    var context: AdyenContext { Dummy.context(with: payment) }
    var sut: BLIKComponent!

    override func setUp() {
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context)
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
        sut = BLIKComponent(paymentMethod: paymentMethod, context: context)
        
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
        XCTAssertEqual(sut.viewController.title, paymentMethod.name.uppercased())
    }

    func testRequiresModalPresentation() {
        let blikPaymentMethod = BLIKPaymentMethod(type: .blik, name: "Test name")
        let sut = BLIKComponent(paymentMethod: blikPaymentMethod, context: context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testViewDidLoadShouldSendInitialCall() throws {
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

    func testSubmit_withDefaultSubmitButtonHidden_shouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let configuration = BLIKComponent.Configuration(showsSubmitButton: false)
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
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

    func testSubmit_withDefaultSubmitButtonShown_shouldNotCallPaymentDelegateDidSubmit() throws {
        // Given
        let configuration = BLIKComponent.Configuration(showsSubmitButton: true)
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        // When
        sut.submit()

        // Then
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 0)
    }

    func testValidateGivenValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let configuration = BLIKComponent.Configuration(showsSubmitButton: false)
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
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
        let configuration = BLIKComponent.Configuration(showsSubmitButton: false)
        let sut = BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        paymentDelegateMock.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }
}
