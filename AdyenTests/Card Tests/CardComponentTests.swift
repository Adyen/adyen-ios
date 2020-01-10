//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import AdyenCard
@testable import Adyen
@testable import AdyenDropIn

class CardComponentTests: XCTestCase {

    func testLocalizationWithCustomTableName() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        let sut = CardComponent(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey())
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        sut.showsHolderNameField = true

        XCTAssertEqual(sut.expiryDateItem.title, ADYLocalizedString("adyen.card.expiryItem.title", nil))
        XCTAssertEqual(sut.expiryDateItem.placeholder, ADYLocalizedString("adyen.card.expiryItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.expiryDateItem.validationFailureMessage, ADYLocalizedString("adyen.card.expiryItem.invalid", sut.localizationParameters))

        XCTAssertEqual(sut.securityCodeItem.title, ADYLocalizedString("adyen.card.cvcItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.securityCodeItem.placeholder, ADYLocalizedString("adyen.card.cvcItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.securityCodeItem.validationFailureMessage, ADYLocalizedString("adyen.card.cvcItem.invalid", sut.localizationParameters))

        XCTAssertEqual(sut.holderNameItem?.title, ADYLocalizedString("adyen.card.nameItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem?.placeholder, ADYLocalizedString("adyen.card.nameItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem?.validationFailureMessage, ADYLocalizedString("adyen.card.nameItem.invalid", sut.localizationParameters))

        XCTAssertEqual(sut.storeDetailsItem?.title, ADYLocalizedString("adyen.card.storeDetailsButton", sut.localizationParameters))

        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        let sut = CardComponent(paymentMethod: method, publicKey: RandomStringGenerator.generateDummyCardPublicKey())
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        sut.showsHolderNameField = true

        XCTAssertEqual(sut.expiryDateItem.title, ADYLocalizedString("adyen.card.expiryItem.title", nil))
        XCTAssertEqual(sut.expiryDateItem.placeholder, ADYLocalizedString("adyen_card_expiryItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.expiryDateItem.validationFailureMessage, ADYLocalizedString("adyen_card_expiryItem_invalid", sut.localizationParameters))

        XCTAssertEqual(sut.securityCodeItem.title, ADYLocalizedString("adyen_card_cvcItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.securityCodeItem.placeholder, ADYLocalizedString("adyen_card_cvcItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.securityCodeItem.validationFailureMessage, ADYLocalizedString("adyen_card_cvcItem_invalid", sut.localizationParameters))

        XCTAssertEqual(sut.holderNameItem?.title, ADYLocalizedString("adyen_card_nameItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem?.placeholder, ADYLocalizedString("adyen_card_nameItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem?.validationFailureMessage, ADYLocalizedString("adyen_card_nameItem_invalid", sut.localizationParameters))

        XCTAssertEqual(sut.storeDetailsItem?.title, ADYLocalizedString("adyen_card_storeDetailsButton", sut.localizationParameters))

        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }

    // This is not a real public key, this is just a random string with the right pattern.
    private static var randomTestValidCardPublicKey = "59554|59YWNVYSILHQWVXSIYY8XVK5HMLEAFT2JPJBDVHUD2798K12GKE652PYLJYYNBR0HVN0AYLC38VIU0TSBC9JTQZ4AHOHPPIGVH985H6EI5HAFZXZAM0QIXBAYEP180X0MM6HRHZONIM62TI9US8NXHXNKYSRE8ASJLY3KED6KDD6SY4I29CUY5FYTN8XEQ8NS8M0ECUAG0GV08XAX19HEX8IQ35SNRY8P9G0YOTTEFYC8QGM7N4PYRUWTSOEJV8W9AKJ8ZLR851OA0P7NZOJXZ2EOYNWSORS9RL4HGXVXGANDYXOWCD7XYPHJD6EPYGRUDV87EOT5FHR574DJW5881Y88Y2QR6R9W1WG5N0CV3WJGELJ971OR0S0PTKHOFW7PXRRDVQU1TT4Q8KJJLZ2VHS1BYP0VFQY1FOADWZ2YPGXDT6KPSN6OJ81G9B9BO7LMGYIONUDWQZQM41O27RROX44I89WRLHZHNYP5NEF2ACTF1AJHA4SNTUN9Z93HYQ2"

    func testUIConfiguration() {
        var cardComponentStyle = FormComponentStyle()
        cardComponentStyle.backgroundColor = .green


        /// Footer
        cardComponentStyle.footer.button.title.color = .white
        cardComponentStyle.footer.button.title.backgroundColor = .red
        cardComponentStyle.footer.button.title.textAlignment = .center
        cardComponentStyle.footer.button.title.font = .systemFont(ofSize: 22)
        cardComponentStyle.footer.button.backgroundColor = .red
        cardComponentStyle.footer.backgroundColor = .brown

        /// Header
        cardComponentStyle.header.backgroundColor = .magenta
        cardComponentStyle.header.title.color = .white
        cardComponentStyle.header.title.backgroundColor = .black
        cardComponentStyle.header.title.textAlignment = .left
        cardComponentStyle.header.title.font = .systemFont(ofSize: 30)

        /// Text field
        cardComponentStyle.textField.text.color = .yellow
        cardComponentStyle.textField.text.font = .systemFont(ofSize: 5)
        cardComponentStyle.textField.text.textAlignment = .center

        cardComponentStyle.textField.title.backgroundColor = .blue
        cardComponentStyle.textField.title.color = .green
        cardComponentStyle.textField.title.font = .systemFont(ofSize: 18)
        cardComponentStyle.textField.title.textAlignment = .left
        cardComponentStyle.textField.backgroundColor = .blue

        /// Switch
        cardComponentStyle.switch.title.backgroundColor = .green
        cardComponentStyle.switch.title.color = .yellow
        cardComponentStyle.switch.title.font = .systemFont(ofSize: 5)
        cardComponentStyle.switch.title.textAlignment = .left
        cardComponentStyle.switch.backgroundColor = .magenta

        var navigationStyle = NavigationStyle()
        navigationStyle.barBackgroundColor = .green
        navigationStyle.barTitle.color = .red
        navigationStyle.barTintColor = .white
        navigationStyle.tintColor = .red
        navigationStyle.backgroundColor = .brown

        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let sut = CardComponent(paymentMethod: cardPaymentMethod,
                                publicKey: CardComponentTests.randomTestValidCardPublicKey,
                                style: cardComponentStyle,
                                navigationStyle: navigationStyle)
        sut.showsHolderNameField = true

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.textItem")
            let cardNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.titleLabel")
            let cardNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.textField")

            let holderNameItemView: FormTextItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
            let holderNameItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.titleLabel")
            let holderNameItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.textField")

            let expiryDateItemView: FormTextItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
            let expiryDateItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.titleLabel")
            let expiryDateItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.textField")

            let securityCodeItemView: FormTextItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
            let securityCodeItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.titleLabel")
            let securityCodeItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.textField")

            let storeDetailsItemView: FormSwitchItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem")
            let storeDetailsItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem.titleLabel")

            let footerItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton")
            let footerItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton.titleLabel")

            let headerItemView: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name")
            let headerItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name.titleLabel")

            /// Test card number field
            XCTAssertEqual(cardNumberItemView?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(cardNumberItemTitleLabel?.font, .systemFont(ofSize: 18))
            XCTAssertEqual(cardNumberItemTextField?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTextField?.textAlignment, .center)
            XCTAssertEqual(cardNumberItemTextField?.textColor, .yellow)
            XCTAssertEqual(cardNumberItemTextField?.font, .systemFont(ofSize: 5))

            /// Test card holer name field
            XCTAssertEqual(holderNameItemView?.backgroundColor, .blue)
            XCTAssertEqual(holderNameItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(holderNameItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(holderNameItemTitleLabel?.font, .systemFont(ofSize: 18))
            XCTAssertEqual(holderNameItemTitleLabel?.textColor, .green)
            XCTAssertEqual(holderNameItemTextField?.backgroundColor, .blue)
            XCTAssertEqual(holderNameItemTextField?.textAlignment, .center)
            XCTAssertEqual(holderNameItemTextField?.textColor, .yellow)
            XCTAssertEqual(holderNameItemTextField?.font, .systemFont(ofSize: 5))

            /// Test expiry date field
            XCTAssertEqual(expiryDateItemView?.backgroundColor, .blue)
            XCTAssertEqual(expiryDateItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(expiryDateItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(expiryDateItemTitleLabel?.font, .systemFont(ofSize: 18))
            XCTAssertEqual(expiryDateItemTitleLabel?.textColor, .green)
            XCTAssertEqual(expiryDateItemTextField?.backgroundColor, .blue)
            XCTAssertEqual(expiryDateItemTextField?.textAlignment, .center)
            XCTAssertEqual(expiryDateItemTextField?.textColor, .yellow)
            XCTAssertEqual(expiryDateItemTextField?.font, .systemFont(ofSize: 5))

            /// Test security code field
            XCTAssertEqual(securityCodeItemView?.backgroundColor, .blue)
            XCTAssertEqual(securityCodeItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(securityCodeItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(securityCodeItemTitleLabel?.font, .systemFont(ofSize: 18))
            XCTAssertEqual(securityCodeItemTitleLabel?.textColor, .green)
            XCTAssertEqual(securityCodeItemTextField?.backgroundColor, .blue)
            XCTAssertEqual(securityCodeItemTextField?.textAlignment, .center)
            XCTAssertEqual(securityCodeItemTextField?.textColor, .yellow)
            XCTAssertEqual(securityCodeItemTextField?.font, .systemFont(ofSize: 5))

            /// Test store card details switch
            XCTAssertEqual(storeDetailsItemView?.backgroundColor, .magenta)
            XCTAssertEqual(storeDetailsItemTitleLabel?.backgroundColor, .green)
            XCTAssertEqual(storeDetailsItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(storeDetailsItemTitleLabel?.textColor, .yellow)
            XCTAssertEqual(storeDetailsItemTitleLabel?.font, .systemFont(ofSize: 5))

            /// Test footer
            XCTAssertEqual(footerItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(footerItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(footerItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(footerItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(footerItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            /// Test header
            XCTAssertEqual(headerItemView?.backgroundColor, .magenta)
            XCTAssertEqual(headerItemViewTitleLabel?.backgroundColor, .black)
            XCTAssertEqual(headerItemViewTitleLabel?.textAlignment, .left)
            XCTAssertEqual(headerItemViewTitleLabel?.textColor, .white)
            XCTAssertEqual(headerItemViewTitleLabel?.font, .systemFont(ofSize: 30))

            /// Test navigation styling
            XCTAssertEqual((sut.viewController as? ComponentViewController)?.rootViewController.navigationController?.navigationBar.backgroundColor, .green)
            XCTAssertEqual((sut.viewController as? ComponentViewController)?.rootViewController.navigationController?.navigationBar.barTintColor, .green)
            XCTAssertEqual((sut.viewController as? ComponentViewController)?.rootViewController.navigationController?.navigationBar.tintColor, .white)
            XCTAssertEqual((sut.viewController as? ComponentViewController)?.rootViewController.navigationController?.view.tintColor, .red)

            XCTAssertEqual(sut.viewController.view.backgroundColor, .brown)
            XCTAssertEqual(((sut.viewController as? ComponentViewController)?.rootViewController as? FormViewController)?.view.backgroundColor, .green)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

}
