//
//  MBWayComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 7/31/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class MBWayComponentTests: XCTestCase {

    lazy var paymentMethod = MBWayPaymentMethod(type: "test_type", name: "test_name")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")

    func testLocalizationWithCustomTableName() {
        let sut = MBWayComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        XCTAssertEqual(sut.phoneItem?.title, localizedString(.phoneNumberTitle, sut.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(.phoneNumberPlaceholder, sut.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(.phoneNumberInvalid, sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(.continueTo, sut.localizationParameters, paymentMethod.name))
        XCTAssertTrue(sut.button.title!.contains(paymentMethod.name))
    }

    func testLocalizationWithCustomKeySeparator() {
        let sut = MBWayComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        XCTAssertEqual(sut.phoneItem?.title, localizedString(LocalizationKey(key: "adyen_phoneNumber_title"), sut.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.placeholder, localizedString(LocalizationKey(key: "adyen_phoneNumber_placeholder"), sut.localizationParameters))
        XCTAssertEqual(sut.phoneItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_phoneNumber_invalid"), sut.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_continueTo"), sut.localizationParameters, paymentMethod.name))
    }

    func testUIConfiguration() {
        var style = FormComponentStyle()

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

        let sut = MBWayComponent(paymentMethod: paymentMethod, apiContext: Dummy.context, style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let phoneNumberView: FormPhoneNumberItemView? = sut.viewController.view.findView(with: MBWayViewIdentifier.phone)
            let phoneNumberViewTitleLabel: UILabel? = sut.viewController.view.findView(with: MBWayViewIdentifier.phoneTitleLabel)
            let phoneNumberViewTextField: UITextField? = sut.viewController.view.findView(with: MBWayViewIdentifier.phoneTextField)

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: MBWayViewIdentifier.payButton)
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: MBWayViewIdentifier.payButtonTitleLabel)

            /// Test phone number field
            XCTAssertEqual(phoneNumberView?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textColor, sut.viewController.view.tintColor)
            XCTAssertEqual(phoneNumberViewTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(phoneNumberViewTitleLabel?.textAlignment, .center)
            XCTAssertEqual(phoneNumberViewTitleLabel?.font, .systemFont(ofSize: 20))
            XCTAssertEqual(phoneNumberViewTextField?.backgroundColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.textAlignment, .right)
            XCTAssertEqual(phoneNumberViewTextField?.textColor, .red)
            XCTAssertEqual(phoneNumberViewTextField?.font, .systemFont(ofSize: 13))

            /// Test footer
            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSubmitForm() {
        let sut = MBWayComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        sut.payment = payment

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is MBWayDetails)
            let data = data.paymentMethod as! MBWayDetails
            XCTAssertEqual(data.telephoneNumber, "+3511233456789")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let submitButton: UIControl? = sut.viewController.view.findView(with: MBWayViewIdentifier.payButton)

            let phoneNumberView: FormPhoneNumberItemView! = sut.viewController.view.findView(with: MBWayViewIdentifier.phone)
            self.populate(textItemView: phoneNumberView, with: "1233456789")

            submitButton?.sendActions(for: .touchUpInside)

            dummyExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testBigTitle() {
        let sut = MBWayComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.MBWayComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, self.paymentMethod.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testRequiresModalPresentation() {
        let mbWayPaymentMethod = MBWayPaymentMethod(type: "mbway", name: "Test name")
        let sut = MBWayComponent(paymentMethod: mbWayPaymentMethod, apiContext: Dummy.context)
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testMBWayPrefilling() throws {
        // Given
        let prefillSut = MBWayComponent(paymentMethod: paymentMethod,
                                        apiContext: Dummy.context,
                                        shopperInformation: shopperInformation)
        UIApplication.shared.keyWindow?.rootViewController = prefillSut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = prefillSut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)
    }

    func testMBWay_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 apiContext: Dummy.context,
                                 shopperInformation: nil)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = sut.viewController.view

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: MBWayViewIdentifier.phone))
        let phoneNumber = phoneNumberView.item.value
        XCTAssertTrue(phoneNumber.isEmpty)
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
