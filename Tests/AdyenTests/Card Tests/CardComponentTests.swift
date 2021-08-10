//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
import XCTest

class CardComponentTests: XCTestCase {

    func testRequiresKeyboardInput() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let sut = CardComponent(paymentMethod: method, apiContext: Dummy.context)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }

    func testLocalizationWithCustomTableName() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        var items = sut.cardViewController.items

        XCTAssertEqual(items.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(items.expiryDateItem.placeholder, localizedString(.cardExpiryItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(items.expiryDateItem.validationFailureMessage, localizedString(.cardExpiryItemInvalid, sut.localizationParameters))

        XCTAssertEqual(items.securityCodeItem.title, localizedString(.cardCvcItemTitle, sut.localizationParameters))
        XCTAssertNil(items.securityCodeItem.placeholder)
        XCTAssertEqual(items.securityCodeItem.validationFailureMessage, localizedString(.cardCvcItemInvalid, sut.localizationParameters))

        XCTAssertEqual(items.holderNameItem.title, localizedString(.cardNameItemTitle, sut.localizationParameters))
        XCTAssertEqual(items.holderNameItem.placeholder, localizedString(.cardNameItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(items.holderNameItem.validationFailureMessage, localizedString(.cardNameItemInvalid, sut.localizationParameters))

        XCTAssertEqual(items.storeDetailsItem.title, localizedString(.cardStoreDetailsButton, sut.localizationParameters))

        XCTAssertEqual(items.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        var items = sut.cardViewController.items
        XCTAssertEqual(items.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(items.expiryDateItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_expiryItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(items.expiryDateItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_expiryItem_invalid"), sut.localizationParameters))

        XCTAssertEqual(items.securityCodeItem.title, localizedString(LocalizationKey(key: "adyen_card_cvcItem_title"), sut.localizationParameters))
        XCTAssertNil(items.securityCodeItem.placeholder)
        XCTAssertEqual(items.securityCodeItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_cvcItem_invalid"), sut.localizationParameters))

        XCTAssertEqual(items.holderNameItem.title, localizedString(LocalizationKey(key: "adyen_card_nameItem_title"), sut.localizationParameters))
        XCTAssertEqual(items.holderNameItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_nameItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(items.holderNameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_nameItem_invalid"), sut.localizationParameters))

        XCTAssertEqual(items.storeDetailsItem.title, localizedString(LocalizationKey(key: "adyen_card_storeDetailsButton"), sut.localizationParameters))

        XCTAssertEqual(items.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }

    func testUIConfiguration() {
        var cardComponentStyle = FormComponentStyle()
        cardComponentStyle.backgroundColor = .green

        /// Footer
        cardComponentStyle.mainButtonItem.button.title.color = .white
        cardComponentStyle.mainButtonItem.button.title.backgroundColor = .red
        cardComponentStyle.mainButtonItem.button.title.textAlignment = .center
        cardComponentStyle.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        cardComponentStyle.mainButtonItem.button.backgroundColor = .red
        cardComponentStyle.mainButtonItem.backgroundColor = .brown

        /// Text field
        cardComponentStyle.textField.text.color = .yellow
        cardComponentStyle.textField.text.font = .systemFont(ofSize: 5)
        cardComponentStyle.textField.text.textAlignment = .center
        cardComponentStyle.textField.placeholderText = TextStyle(font: .preferredFont(forTextStyle: .headline),
                                                                 color: .systemOrange,
                                                                 textAlignment: .center)
        cardComponentStyle.textField.title.backgroundColor = .blue
        cardComponentStyle.textField.title.color = .green
        cardComponentStyle.textField.title.font = .systemFont(ofSize: 18)
        cardComponentStyle.textField.title.textAlignment = .left
        cardComponentStyle.textField.backgroundColor = .blue

        /// Switch
        cardComponentStyle.toggle.title.backgroundColor = .green
        cardComponentStyle.toggle.title.color = .yellow
        cardComponentStyle.toggle.title.font = .systemFont(ofSize: 5)
        cardComponentStyle.toggle.title.textAlignment = .left
        cardComponentStyle.toggle.backgroundColor = .magenta

        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: cardPaymentMethod,
                                apiContext: Dummy.context,
                                configuration: configuration,
                                style: cardComponentStyle)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            let cardNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.titleLabel")
            let cardNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.textField")

            let holderNameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
            let holderNameItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.titleLabel")
            let holderNameItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.textField")

            let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
            let expiryDateItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.titleLabel")
            let expiryDateItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.textField")

            let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
            let securityCodeItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.titleLabel")
            let securityCodeItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.textField")
            let securityCodeCvvHint: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")

            let storeDetailsItemView: FormToggleItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem")
            let storeDetailsItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem.titleLabel")

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
            let payButtonItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button.titleLabel")

            /// Test card number field
            XCTAssertEqual(cardNumberItemView?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTitleLabel?.textColor, sut.viewController.view.tintColor)
            XCTAssertEqual(cardNumberItemTitleLabel?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(cardNumberItemTitleLabel?.font, .systemFont(ofSize: 18))
            XCTAssertEqual(cardNumberItemTextField?.backgroundColor, .blue)
            XCTAssertEqual(cardNumberItemTextField?.textAlignment, .center)
            XCTAssertEqual(cardNumberItemTextField?.textColor, .yellow)
            XCTAssertEqual(cardNumberItemTextField?.font, .systemFont(ofSize: 5))
            XCTAssertEqual(cardNumberItemTextField?.attributedPlaceholder?.foregroundColor, .systemOrange)

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
            XCTAssertEqual(holderNameItemTextField?.attributedPlaceholder?.foregroundColor, .systemOrange)

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
            XCTAssertEqual(expiryDateItemTextField?.attributedPlaceholder?.foregroundColor, .systemOrange)

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
            XCTAssertNotNil(securityCodeCvvHint)
            XCTAssertEqual(securityCodeItemTextField?.attributedPlaceholder?.foregroundColor, .systemOrange)

            /// Test store card details switch
            XCTAssertEqual(storeDetailsItemView?.backgroundColor, .magenta)
            XCTAssertEqual(storeDetailsItemTitleLabel?.backgroundColor, .green)
            XCTAssertEqual(storeDetailsItemTitleLabel?.textAlignment, .left)
            XCTAssertEqual(storeDetailsItemTitleLabel?.textColor, .yellow)
            XCTAssertEqual(storeDetailsItemTitleLabel?.font, .systemFont(ofSize: 5))

            /// Test footer
            XCTAssertEqual(payButtonItemViewButton?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.backgroundColor, .red)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textAlignment, .center)
            XCTAssertEqual(payButtonItemViewButtonTitle?.textColor, .white)
            XCTAssertEqual(payButtonItemViewButtonTitle?.font, .systemFont(ofSize: 22))

            XCTAssertEqual(sut.viewController.view.backgroundColor, .green)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testBigTitle() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, method.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testHideCVVField() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["visa", "amex"])
        var configuration = CardComponent.Configuration()
        configuration.showsSecurityCodeField = false
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let securityCodeView: FormCardSecurityCodeItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

            XCTAssertNil(securityCodeView)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testShowCVVField() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let securityCodeView: FormCardSecurityCodeItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

            XCTAssertNotNil(securityCodeView)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testCVVHintChange() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            let securityCodeCvvHint: FormCardSecurityCodeItemView.HintView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")
            let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

            XCTAssertNotNil(securityCodeCvvHint)
            XCTAssertFalse(securityCodeCvvHint!.showFront)
            XCTAssertEqual(securityCodeItemView?.textField.placeholder, "3 digits")

            self.populate(textItemView: cardNumberItemView!, with: "370000")
            XCTAssertTrue(securityCodeCvvHint!.showFront)
            XCTAssertEqual(securityCodeItemView?.textField.placeholder, "4 digits")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testDelegateCalled() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["visa", "amex"])
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .americanExpress)]))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: .init(),
                                style: .init(),
                                cardPublicKeyProvider: CardPublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let expectationLastFour = XCTestExpectation(description: "LastFour Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
            XCTAssertEqual(value, "670344")
            expectationBin.fulfill()
        }, onCardBrandChange: { value in
            XCTAssertEqual(value, [CardBrand(type: .americanExpress)])
            expectationCardType.fulfill()
        }, onSubmitLastFour: { value in
            XCTAssertEqual(value, "4449")
            expectationLastFour.fulfill()
        })
        sut.cardComponentDelegate = delegateMock

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.fillCard(on: sut.viewController.view, with: Dummy.bancontactCard)
            self.tapSubmitButton(on: sut.viewController.view)
        }

        wait(for: [expectationBin, expectationCardType], timeout: 10)
    }

    func testCVVFormatterChange() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            let securityCodeCvvHint: FormCardSecurityCodeItemView.HintView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")

            XCTAssertNotNil(securityCodeCvvHint)
            self.populate(textItemView: securityCodeItemView!, with: "12345")
            XCTAssertEqual(securityCodeItemView!.textField.text, "123")

            self.populate(textItemView: cardNumberItemView!, with: "370000")
            self.populate(textItemView: securityCodeItemView!, with: "12345")
            XCTAssertEqual(securityCodeItemView!.textField.text, "1234")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testTintColorCustomisation() {
        var style = FormComponentStyle(tintColor: .systemYellow)
        style.textField.title.color = .gray

        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let switchView: UISwitch! = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem.switch")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        XCTAssertEqual(securityCodeItemView!.titleLabel.textColor!, .gray)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.focus(textItemView: securityCodeItemView!)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(switchView.onTintColor, .systemYellow)
                XCTAssertEqual(securityCodeItemView!.titleLabel.textColor!, .systemYellow)
                XCTAssertEqual(securityCodeItemView!.separatorView.backgroundColor?.cgColor, UIColor.systemYellow.cgColor)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }

    func testSuccessTintColorCustomisation() {
        var style = FormComponentStyle(tintColor: .systemYellow)
        style.textField.title.color = .gray

        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                style: style)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        XCTAssertEqual(securityCodeItemView!.titleLabel.textColor!, .gray)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.populate(textItemView: securityCodeItemView!, with: "123")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let successIcon: UIImageView? = sut.viewController.view.findView(by: "cvvHintIcon.imageView")
                XCTAssertNotNil(successIcon)
                XCTAssertEqual(successIcon?.tintColor, .systemYellow)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }

    func testFormViewControllerDelegate() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.success("key"))
        }
        sut.cardPublicKeyProvider = cardPublicKeyProvider

        sut.viewDidLoad(viewController: sut.cardViewController)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testStoredCardPaymentWithNoPayment() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay")
    }

    func testStoredCardPaymentWithPayment() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        sut.payment = Payment(amount: Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay €1,234.56")
    }

    func testStoredCardPaymentWithNoCVV() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        var configuration = CardComponent.Configuration()
        configuration.stored.showsSecurityCodeField = false
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        sut.payment = Payment(amount: Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "•••• 1234")
        XCTAssertEqual(vc?.title, "Confirm name payment")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay €1,234.56")
    }

    func testStoredCardPaymentWithNoCVVAndNoPayment() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        var configuration = CardComponent.Configuration()
        configuration.stored.showsSecurityCodeField = false
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "•••• 1234")
        XCTAssertEqual(vc?.title, "Confirm name payment")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay")
    }

    func testOneClickPayment() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        var configuration = CardComponent.Configuration()
        configuration.stored.showsSecurityCodeField = false
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        XCTAssertNotNil(sut.viewController as? UIAlertController)
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
    }

    func testShouldShow4CardTypesOnInit() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "cup", "maestro", "jcb"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.cardTypeLogosView as! FormCardNumberItemView.CardsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 6)
            XCTAssertEqual(cardLogoView.subviews.count, 6)
            XCTAssertEqual(cardLogoView.arrangedSubviews.filter { !$0.isHidden }.count, 4)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 8)
    }

    func testShouldShowNoCardTypesOnInvalidPANEnter() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.cardTypeLogosView as! FormCardNumberItemView.CardsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            self.populate(textItemView: cardNumberItemView!, with: "1231")

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 3)
                XCTAssertEqual(cardLogoView.subviews.count, 3)
                XCTAssertTrue(cardLogoView.arrangedSubviews.allSatisfy(\.isHidden))

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 8)
    }

    func testShouldShowCardTypesOnPANEnter() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.CardComponent.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.cardTypeLogosView as! FormCardNumberItemView.CardsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            self.populate(textItemView: cardNumberItemView!, with: "3400")

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 3)
                XCTAssertEqual(cardLogoView.subviews.count, 3)
                XCTAssertEqual(cardLogoView.arrangedSubviews.filter { !$0.isHidden }.count, 1)

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 8)
    }

    func testSubmit() throws {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        // Dummy public key
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: FormComponentStyle(),
                                cardPublicKeyProvider: CardPublicKeyProviderMock(),
                                binProvider: BinInfoProviderMock())

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectedVerificationAddress = PostalAddressMocks.newYorkPostalAddress

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            let details = data.paymentMethod as! CardDetails

            XCTAssertNotEqual(details.encryptedCardNumber, "4917 6100 0000 0000")
            XCTAssertNotEqual(details.encryptedExpiryYear, "30")
            XCTAssertNotEqual(details.encryptedExpiryMonth, "03")
            XCTAssertNotEqual(details.encryptedSecurityCode, "737")
            XCTAssertEqual(data.storePaymentMethod, true)
            XCTAssertEqual(data.billingAddress, expectedVerificationAddress)

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()

            XCTAssertEqual(sut.cardViewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.cardViewController.items.button.showsActivityIndicator, false)
        }

        wait(for: .seconds(1))

        let view: UIView = sut.viewController.view

        fillCard(on: view, with: Dummy.visaCard)

        let storeDetailsItemView: FormToggleItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        storeDetailsItemView.accessibilityActivate()

        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: "AdyenCard.CardComponent.billingAddress"))
        fill(addressView: billingAddressView, with: expectedVerificationAddress)

        tapSubmitButton(on: view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testDateShouldPassFocusToCVC() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            expiryDateItemView?.becomeFirstResponder()
            self.append(textItemView: expiryDateItemView!, with: "3")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                XCTAssertTrue(expiryDateItemView!.textField.isFirstResponder)
                self.append(textItemView: expiryDateItemView!, with: "3")
                self.append(textItemView: expiryDateItemView!, with: "0")

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    XCTAssertTrue(securityCodeItemView!.textField.isFirstResponder)
                    XCTAssertFalse(expiryDateItemView!.textField.isFirstResponder)

                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }

    func testAddressNL() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "NL")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        // When
        wait(for: .seconds(1))

        let view: UIView = sut.viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.houseNumberOrName"))
        let countryItemView: FormRegionPickerItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.street"))
        let apartmentSuiteItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.apartment"))
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.city"))
        let provinceOrTerritoryItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.postalCode"))
        let headerItemView: UILabel = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.title"))

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.inputControl.label, "Netherlands")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertEqual(headerItemView.text, "Billing address")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)

        let payButtonItemViewButton: UIControl? = view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        XCTAssertFalse(houseNumberItemView.alertLabel.isHidden)
        XCTAssertFalse(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertFalse(cityItemView.alertLabel.isHidden)
        XCTAssertFalse(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertFalse(postalCodeItemView.alertLabel.isHidden)
    }

    func testAddressUS() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        // When
        wait(for: .seconds(1))

        let view: UIView = sut.viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.houseNumberOrName"))
        let countryItemView: FormRegionPickerItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.street"))
        let apartmentSuiteItemView = view.findView(with: "AdyenCard.CardComponent.billingAddress.apartment") as? FormTextInputItemView
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.city"))
        let provinceOrTerritoryItemView: FormRegionPickerItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.postalCode"))
        let headerItemView: UILabel = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.title"))

        // Then
        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.inputControl.label, "United States")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Zip code")
        XCTAssertEqual(headerItemView.text, "Billing address")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)

        let payButtonItemViewButton: UIControl? = view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertFalse(addressItemView.alertLabel.isHidden)
        XCTAssertFalse(cityItemView.alertLabel.isHidden)
        XCTAssertFalse(postalCodeItemView.alertLabel.isHidden)
    }

    func testAddressUK() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "GBP"), countryCode: "GB")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let houseNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.houseNumberOrName")
            let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.country")
            let addressItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.street")
            let apartmentSuiteItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.apartment")
            let cityItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.city")
            let provinceOrTerritoryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.stateOrProvince")
            let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.postalCode")
            let headerItemView: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.title")

            XCTAssertNil(apartmentSuiteItemView)

            XCTAssertEqual(countryItemView!.titleLabel.text, "Country")
            XCTAssertEqual(countryItemView!.inputControl.label, "United Kingdom")
            XCTAssertEqual(houseNumberItemView!.titleLabel.text, "House number")
            XCTAssertEqual(addressItemView!.titleLabel.text, "Street")
            XCTAssertEqual(cityItemView!.titleLabel.text, "City / Town")
            XCTAssertNil(provinceOrTerritoryItemView)
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
            XCTAssertEqual(headerItemView!.text, "Billing address")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testAddressSelectCountry() throws {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "CA")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .seconds(1))

        let view: UIView = sut.viewController.view

        var houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.houseNumberOrName"))
        var countryItemView: FormRegionPickerItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.country"))
        var addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.street"))
        var apartmentSuiteItemView: FormTextInputItemView! = view.findView(with: "AdyenCard.CardComponent.billingAddress.apartment")
        var cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.city"))
        var provinceOrTerritoryItemView: FormRegionPickerItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.stateOrProvince"))
        var postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.postalCode"))

        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.inputControl.label, "Canada")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertNil(apartmentSuiteItemView)

        countryItemView.item.value = countryItemView.item.selectableValues.first { $0.identifier == "BR" }!

        wait(for: .seconds(1))

        houseNumberItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.houseNumberOrName"))
        countryItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.country"))
        addressItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.street"))
        apartmentSuiteItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.apartment"))
        cityItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.city"))
        provinceOrTerritoryItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.stateOrProvince"))
        postalCodeItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.billingAddress.postalCode"))

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.inputControl.label, "Brazil")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
    }

    func testPostalCode() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                cardPublicKeyProvider: CardPublicKeyProviderMock(),
                                binProvider: BinInfoProviderMock())
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertNil(data.billingAddress?.apartment)
            XCTAssertNil(data.billingAddress?.houseNumberOrName)
            XCTAssertNil(data.billingAddress?.street)
            XCTAssertNil(data.billingAddress?.stateOrProvince)
            XCTAssertNil(data.billingAddress?.city)
            XCTAssertNil(data.billingAddress?.country)
            XCTAssertEqual(data.billingAddress?.postalCode, "12345")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            self.fillCard(on: sut.viewController.view, with: Dummy.visaCard)

            let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem")
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
            XCTAssertTrue(postalCodeItemView!.alertLabel.isHidden)
            self.populate(textItemView: postalCodeItemView!, with: "12345")

            self.tapSubmitButton(on: sut.viewController.view)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testKCP() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "korean_local_card"])
        let config = CardComponent.Configuration(koreanAuthenticationMode: .auto)
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .koreanLocalCard)],
                                 issuingCountryCode: "KR"))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                cardPublicKeyProvider: CardPublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let paymentDetails = data.paymentMethod as? CardDetails
            XCTAssertNotNil(paymentDetails)

            XCTAssertNotEqual(paymentDetails?.password, "12")
            XCTAssertTrue(paymentDetails!.password!.starts(with: "adyenio_0_1_25$"))
            XCTAssertEqual(paymentDetails?.taxNumber, "121212")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let taxNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthCodeItem")
            let passwordItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthPasswordItem")
            XCTAssertTrue(taxNumberItemView!.isHidden)
            XCTAssertTrue(passwordItemView!.isHidden)

            self.fillCard(on: sut.viewController.view, with: Dummy.kcpCard)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(passwordItemView!.titleLabel.text, "First 2 digits of card password")
                XCTAssertEqual(taxNumberItemView!.titleLabel.text, "Birthday or Corporate registration number")
                XCTAssertFalse(taxNumberItemView!.isHidden)
                XCTAssertFalse(passwordItemView!.isHidden)
                self.populate(textItemView: taxNumberItemView!, with: "121212")
                self.populate(textItemView: passwordItemView!, with: "12")

                self.tapSubmitButton(on: sut.viewController.view)
            }
        }

        waitForExpectations(timeout: 20, handler: nil)
    }

    func testBrazilSSNs() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        let config = CardComponent.Configuration(socialSecurityNumberMode: .auto)
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: true)],
                                 issuingCountryCode: "BR"))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                cardPublicKeyProvider: CardPublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let paymentDetails = data.paymentMethod as? CardDetails
            XCTAssertNotNil(paymentDetails)
            XCTAssertEqual(paymentDetails?.socialSecurityNumber, "12312312312")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        wait(for: .seconds(1))
        let brazilSSNItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem")
        XCTAssertTrue(brazilSSNItemView!.isHidden)

        self.fillCard(on: sut.viewController.view, with: Dummy.visaCard)

        wait(for: .seconds(1))
        XCTAssertEqual(brazilSSNItemView!.titleLabel.text, "CPF/CNPJ")
        XCTAssertFalse(brazilSSNItemView!.isHidden)
        populate(textItemView: brazilSSNItemView!, with: "123.123.123-12")

        self.tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 20, handler: nil)
    }

    func testLuhnCheck() {
        let allEnabledLuhns = [CardBrand(type: .visa, isLuhnCheckEnabled: true), CardBrand(type: .masterCard, isLuhnCheckEnabled: true)]
        let atLeastOneDisabledLuhn = [CardBrand(type: .visa, isLuhnCheckEnabled: true), CardBrand(type: .masterCard, isLuhnCheckEnabled: false)]

        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)

        let cardNumberItem = sut.cardViewController.items.numberItem
        cardNumberItem.validator = CardNumberValidator(isLuhnCheckEnabled: allEnabledLuhns.luhnCheckRequired)
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertFalse(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())

        cardNumberItem.validator = CardNumberValidator(isLuhnCheckEnabled: atLeastOneDisabledLuhn.luhnCheckRequired)
        XCTAssertTrue(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())

    }

    func testClearShouldResetPostalCodeItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.postalCodeItem.value = "1501 NH"

        // When
        sut.clear()

        // Then
        XCTAssertTrue(sut.cardViewController.items.postalCodeItem.value.isEmpty)
    }

    func testClearShouldResetNumberItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.numberItem.value = "4111 1111 1111 1111"

        // When
        sut.clear()

        // Then
        XCTAssertTrue(sut.cardViewController.items.numberItem.value.isEmpty)
    }

    func testClearShouldResetExpiryDateItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.expiryDateItem.value = "03/24"

        // When
        sut.clear()

        // Then
        XCTAssertTrue(sut.cardViewController.items.expiryDateItem.value.isEmpty)
    }

    func testClearShouldResetSecurityCodeItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.securityCodeItem.value = "935"

        // When
        sut.clear()

        // Then
        XCTAssertTrue(sut.cardViewController.items.securityCodeItem.value.isEmpty)
    }

    func testClearShouldResetHolderNameItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.holderNameItem.value = "Katrina del Mar"

        // When
        sut.clear()

        // Then
        XCTAssertTrue(sut.cardViewController.items.holderNameItem.value.isEmpty)
    }

    func testClearShouldDisableStoreDetailsItem() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.storeDetailsItem.value = true

        // When
        sut.clear()

        // Then
        XCTAssertFalse(sut.cardViewController.items.storeDetailsItem.value)
    }

    func testClearShouldAssignEmptyPostalAddressToBillingAddressItem() throws {
        // Given
        let expectedPostalAddress = PostalAddress()
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        // When
        sut.clear()

        // Then
        let postalAddress = sut.cardViewController.items.billingAddressItem.value
        XCTAssertEqual(expectedPostalAddress, postalAddress)
    }

    private func focus<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U) {
        textItemView.textField.becomeFirstResponder()
    }
}

extension UIView {

    func printForTesting(indent: String) {
        print("\(indent) \(self.accessibilityIdentifier ?? "\(String(describing: type(of: self)))")")
        for view in self.subviews {
            print(view.printForTesting(indent: indent + " -"))
        }
    }
}

extension XCTestCase {

    func fillCard(on view: UIView, with card: Card) {
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = view.findView(with: "AdyenCard.CardComponent.numberItem")
        let expiryDateItemView: FormTextItemView<FormTextInputItem>? = view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

        populate(textItemView: cardNumberItemView!, with: card.number ?? "")
        populate(textItemView: expiryDateItemView!, with: "\(card.expiryMonth ?? "") \(card.expiryYear ?? "")")
        populate(textItemView: securityCodeItemView!, with: card.securityCode ?? "")
    }

    func tapSubmitButton(on view: UIView) {
        let payButtonItemViewButton: UIControl? = view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)
    }
}

extension NSAttributedString {

    var foregroundColor: UIColor? {
        var range = NSRange(location: 0, length: string.count)
        return attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: &range) as? UIColor
    }

    var font: UIFont? {
        var range = NSRange(location: 0, length: string.count)
        return attribute(NSAttributedString.Key.font, at: 0, effectiveRange: &range) as? UIFont
    }
}
