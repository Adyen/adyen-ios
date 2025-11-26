//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class QiwiWalletComponentTests: XCTestCase {

    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }
    
    lazy var phoneExtensions = [PhoneExtension(value: "+1", countryCode: "US"), PhoneExtension(value: "+3", countryCode: "UK")]
    lazy var method = QiwiWalletPaymentMethod(type: .qiwiWallet, name: "test_name", phoneExtensions: phoneExtensions)
    let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
    
    func testLocalizationWithCustomTableName() throws {
        let config = QiwiWalletComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil))
        let sut = QiwiWalletComponent(paymentMethod: method, context: context, configuration: config)
        
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.selectableValues, phoneExtensions)
        
        XCTAssertEqual(sut.phoneItem?.title, localizedString(.phoneNumberTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(.phoneNumberPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(.phoneNumberInvalid, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.prefix, "+1")
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.selectableValues, phoneExtensions)
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.value?.identifier, "US")
        
        XCTAssertEqual(sut.button.title, localizedString(.continueTo, sut.configuration.localizationParameters, method.name))
        XCTAssertTrue(sut.button.title!.contains(method.name))
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let config = QiwiWalletComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_"))
        let sut = QiwiWalletComponent(paymentMethod: method, context: context, configuration: config)
        
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.selectableValues, phoneExtensions)
        
        XCTAssertEqual(sut.phoneItem?.title, localizedString(LocalizationKey(key: "adyen_phoneNumber_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(LocalizationKey(key: "adyen_phoneNumber_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_phoneNumber_invalid"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.prefix, "+1")
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.selectableValues, phoneExtensions)
        XCTAssertEqual(sut.phoneItem?.phonePrefixItem.value?.identifier, "US")
        
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_continueTo"), sut.configuration.localizationParameters, method.name))
    }
    
    func testUIConfiguration() throws {
        // Given
        let customColors = AdyenColors(container: .systemYellow, primary: .systemPink, highlight: .systemBlue)
        let customTheme = AdyenTheme(colors: customColors).primaryButton(backgroundColor: .systemRed, textColor: .white)

        var config = QiwiWalletComponent.Configuration()
        config.theme = customTheme
        let sut = QiwiWalletComponent(paymentMethod: method, context: context, configuration: config)

        // When
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // Then
        let view = sut.viewController.view
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view?.findView(with: "AdyenComponents.QiwiWalletComponent.phoneNumberItem"))
        let phoneNumberViewTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: "AdyenComponents.QiwiWalletComponent.phoneNumberItem.titleLabel"))
        let phoneNumberViewTextField: UITextField = try XCTUnwrap(view?.findView(with: "AdyenComponents.QiwiWalletComponent.phoneNumberItem.textField"))
        let phoneExtensionViewLabel: UILabel = try XCTUnwrap(view?.findView(with: "Adyen.FormPhoneNumberItem.phoneExtensionPickerItem.label"))
        let payButtonItemView: FormButtonItemView = try XCTUnwrap(view?.findView(with: "AdyenComponents.QiwiWalletComponent.payButtonItem"))

        XCTAssertEqual(phoneNumberViewTitleLabel.textColor, .systemPink)
        XCTAssertEqual(phoneNumberViewTextField.textColor, .systemPink)
        XCTAssertEqual(phoneExtensionViewLabel.textColor, .systemPink)
        XCTAssertEqual(phoneNumberView.backgroundColor, .systemYellow)
        XCTAssertEqual(payButtonItemView.button.backgroundColor, .systemRed)
    }
    
    func testBigTitle() {
        let sut = QiwiWalletComponent(paymentMethod: method, context: context, configuration: QiwiWalletComponent.Configuration())

        setupRootViewController(sut.viewController)
        
        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.CardComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, self.method.name)
    }
    
    func testRequiresModalPresentation() {
        let qiwiPaymentMethod = QiwiWalletPaymentMethod(type: .qiwiWallet, name: "Test name")
        let sut = QiwiWalletComponent(paymentMethod: qiwiPaymentMethod, context: context, configuration: QiwiWalletComponent.Configuration())
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testSubmit() {
        let phoneExtensions = [PhoneExtension(value: "+3", countryCode: "UK")]
        let method = QiwiWalletPaymentMethod(type: .qiwiWallet, name: "test_name", phoneExtensions: phoneExtensions)
        let sut = QiwiWalletComponent(paymentMethod: method, context: context, configuration: QiwiWalletComponent.Configuration())
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is QiwiWalletDetails)
            let data = data.paymentMethod as! QiwiWalletDetails
            XCTAssertEqual(data.phonePrefix, "+3")
            XCTAssertEqual(data.phoneNumber, "7455573152")

            sut.stopLoading()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: "AdyenComponents.QiwiWalletComponent.phoneNumberItem")

        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.QiwiWalletComponent.payButtonItem.button")

        self.populate(textItemView: phoneNumberView!, with: "7455573152")

        payButtonItemViewButton?.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10)

    }

    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let phoneExtensions = [PhoneExtension(value: "+3", countryCode: "UK")]
        let paymentMethod = QiwiWalletPaymentMethod(type: .qiwiWallet, name: "test_name", phoneExtensions: phoneExtensions)
        let sut = QiwiWalletComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: QiwiWalletComponent.Configuration()
        )

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }
}
