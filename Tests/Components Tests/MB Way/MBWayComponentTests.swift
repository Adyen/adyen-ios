//
//  MBWayComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 7/31/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class MBWayComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: MBWayPaymentMethod!
    private var payment: Payment!

    override func setUpWithError() throws {
        try super.setUpWithError()

        context = Dummy.context

        paymentMethod = MBWayPaymentMethod(type: .mbWay, name: "test_name")
        payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        payment = nil
        try super.tearDownWithError()
    }

    func testLocalizationWithCustomTableName() throws {
        let config = MBWayComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil))
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)

        XCTAssertEqual(sut.phoneItem?.title, localizedString(.phoneNumberTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(.phoneNumberPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(.phoneNumberInvalid, sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(.continueTo, sut.configuration.localizationParameters, paymentMethod.name))
        XCTAssertTrue(sut.button.title!.contains(paymentMethod.name))
    }

    func testLocalizationWithCustomKeySeparator() throws {
        let config = MBWayComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_"))
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)

        XCTAssertEqual(sut.phoneItem?.title, localizedString(LocalizationKey(key: "adyen_phoneNumber_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(LocalizationKey(key: "adyen_phoneNumber_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_phoneNumber_invalid"), sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_continueTo"), sut.configuration.localizationParameters, paymentMethod.name))
    }

    func testBigTitle() {
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context)

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.MBWayComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, self.paymentMethod.name)
    }

    func testRequiresModalPresentation() {
        let mbWayPaymentMethod = MBWayPaymentMethod(type: .mbWay, name: "Test name")
        let sut = MBWayComponent(paymentMethod: mbWayPaymentMethod, context: context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testMBWayPrefilling() throws {
        // Given
        let config = MBWayComponent.Configuration(shopperInformation: shopperInformation)
        let prefillSut = MBWayComponent(paymentMethod: paymentMethod,
                                        context: context,
                                        configuration: config)
        
        setupRootViewController(prefillSut.viewController)

        // Then
        let view: UIView = prefillSut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)
    }

    func testMBWayGivenNoShopperInformationShouldNotPrefill() throws {
        // Given
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: MBWayComponent.Configuration())
        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        // Then
        let view: UIView = sut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let phoneNumber = phoneNumberView.item.value
        XCTAssertTrue(phoneNumber.isEmpty)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: MBWayComponent.Configuration())

        // When
        sut.viewWillAppear(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialTelemetryEventCallsCount, 1)
    }

    // MARK: - Private

    private enum MBWayViewIdentifier {
        static let phone = "AdyenComponents.MBWayComponent.phoneNumberItem"
        static let phoneTitleLabel = "AdyenComponents.MBWayComponent.phoneNumberItem.titleLabel"
        static let phoneTextField = "AdyenComponents.MBWayComponent.phoneNumberItem.textField"
        static let payButton = "AdyenComponents.MBWayComponent.payButtonItem.button"
        static let payButtonTitleLabel = "AdyenComponents.MBWayComponent.payButtonItem.button.titleLabel"
    }

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }
}
