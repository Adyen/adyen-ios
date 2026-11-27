//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class MBWayComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: MBWayPaymentMethod!

    override func setUpWithError() throws {
        try super.setUpWithError()

        context = Dummy.context

        paymentMethod = MBWayPaymentMethod(type: .mbWay, name: "test_name")
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        try super.tearDownWithError()
    }

    func testLocalizationWithCustomTableName() throws {
        let config = MBWayComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil))
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        XCTAssertEqual(sut.phoneItem?.title, localizedString(.phoneNumberTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(.phoneNumberPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(.phoneNumberInvalid, sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(.continueTo, sut.configuration.localizationParameters, paymentMethod.name))
        XCTAssertTrue(try XCTUnwrap(sut.button.title?.contains(paymentMethod.name)))
    }

    func testLocalizationWithCustomKeySeparator() {
        let config = MBWayComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_"))
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        XCTAssertEqual(sut.phoneItem?.title, localizedString(LocalizationKey(key: "adyen_phoneNumber_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(LocalizationKey(key: "adyen_phoneNumber_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_phoneNumber_invalid"), sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_continueTo"), sut.configuration.localizationParameters, paymentMethod.name))
    }

    func testBigTitle() {
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.MBWayComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, self.paymentMethod.name)
    }

    func testMBWayPrefilling() throws {
        // Given
        let config = MBWayComponent.Configuration(shopperInformation: shopperInformation)
        let prefillSut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
        
        setupRootViewController(prefillSut.viewController)

        // Then
        let view: UIView = prefillSut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.phoneNumber?.value)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)
    }

    func testMBWayGivenNoShopperInformationShouldNotPrefill() throws {
        // Given
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: MBWayComponent.Configuration()
        )
        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        // Then
        let view: UIView = sut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let phoneNumber = phoneNumberView.item.value
        XCTAssertTrue(phoneNumber.isEmpty)
    }

    func test_phoneNumber_afterReturningToForm_shouldKeepPrefilledValue() throws {
        // Given
        let form = try makeSUT(shopperInformation: shopperInformation)

        // When
        form.navigateAwayAndBack()

        // Then
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.phoneNumber?.value)
        XCTAssertEqual(form.phoneNumber, expectedPhoneNumber)
    }

    func test_phoneNumber_afterReturningToForm_shouldKeepEditedValue() throws {
        // Given
        let form = try makeSUT(shopperInformation: shopperInformation)
        form.enterPhoneNumber("987654321")
        let editedValue = form.phoneNumber

        // When
        form.navigateAwayAndBack()

        // Then
        XCTAssertEqual(form.phoneNumber, editedValue)
    }

    func testViewDidLoadShouldSendInitialCall() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: MBWayComponent.Configuration()
        )

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    // MARK: - Private

    private func makeSUT(shopperInformation: PrefilledShopperInformation? = nil) throws -> FormDriver {
        let config = MBWayComponent.Configuration(shopperInformation: shopperInformation)
        let sut = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
        let navigationController = UINavigationController(rootViewController: sut.viewController)
        setupRootViewController(navigationController)
        return try FormDriver(sut: sut, navigationController: navigationController) { [weak self] condition in
            self?.wait(until: condition, timeout: 2, retryInterval: .milliseconds(10))
        }
    }

    @MainActor
    private final class FormDriver {

        private let sut: MBWayComponent
        private let navigationController: UINavigationController
        private let waitUntil: (_ condition: () -> Bool) -> Void
        private let phoneNumberView: FormPhoneNumberItemView

        init(
            sut: MBWayComponent,
            navigationController: UINavigationController,
            waitUntil: @escaping (_ condition: () -> Bool) -> Void
        ) throws {
            self.sut = sut
            self.navigationController = navigationController
            self.waitUntil = waitUntil
            self.phoneNumberView = try XCTUnwrap(sut.viewController.view.findView(by: MBWayViewIdentifier.phone))
        }

        var phoneNumber: String {
            phoneNumberView.item.value
        }

        func enterPhoneNumber(_ phoneNumber: String) {
            phoneNumberView.textField.text = phoneNumber
            phoneNumberView.textField.sendActions(for: .editingChanged)
        }

        func navigateAwayAndBack() {
            let pushedViewController = UIViewController()
            navigationController.pushViewController(pushedViewController, animated: false)
            waitUntil { [weak self] in
                self?.navigationController.topViewController === pushedViewController
            }
            navigationController.popViewController(animated: false)
            waitUntil { [weak self] in
                guard let self else { return false }
                return navigationController.topViewController === sut.viewController
                    && sut.viewController.viewIfLoaded?.window != nil
            }
        }
    }

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
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370"
        )
    }
}
