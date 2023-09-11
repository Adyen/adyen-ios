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
        
        wait(for: .seconds(1))
        
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let cardNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.titleLabel")
        let cardNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.textField")
        
        let holderNameItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
        let holderNameItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.titleLabel")
        let holderNameItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.textField")
        
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
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
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
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
                                publicKeyProvider: PublicKeyProviderMock(),
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
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
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
    
    func testTintColorCustomization() {
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
        
        wait(for: .seconds(1))
        
        self.focus(textItemView: securityCodeItemView!)
        
        wait(for: .seconds(1))
        
        XCTAssertEqual(switchView.onTintColor, .systemYellow)
        XCTAssertEqual(securityCodeItemView!.titleLabel.textColor!, .systemYellow)
        XCTAssertEqual(securityCodeItemView!.separatorView.backgroundColor?.cgColor, UIColor.systemYellow.cgColor)
    }
    
    func testSuccessTintColorCustomization() throws {
        // Given
        var style = FormComponentStyle(tintColor: .systemYellow)
        style.textField.title.color = .gray
        
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                style: style)
        
        // When
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .seconds(1))
        
        // Then
        let view: UIView = sut.viewController.view
        
        let securityCodeItemView: FormCardSecurityCodeItemView? = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
        XCTAssertEqual(securityCodeItemView?.titleLabel.textColor, .gray)
        
        populate(textItemView: securityCodeItemView!, with: "123")
        wait(for: .seconds(1))
        
        let successIcon: UIImageView? = try XCTUnwrap(securityCodeItemView?.cardHintView)
        XCTAssertEqual(successIcon?.tintColor, .systemYellow)
    }
    
    func testFormViewControllerDelegate() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        
        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        let publicKeyProvider = PublicKeyProviderMock()
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success("key"))
        }
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: CardComponent.Configuration(),
                                shopperInformation: nil,
                                style: FormComponentStyle(),
                                publicKeyProvider: publicKeyProvider,
                                binProvider: BinInfoProviderMock())
        
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
    
    func testStoredCardPaymentLocalization() throws {
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
        
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        sut.payment = Payment(amount: Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Test-Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Test-Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Test-Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Test-Pay €1,234.56")
    }
    
    func testStoredCardPaymentLocalizationWithNoCVV() throws {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "Payment Method Name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        var config = CardComponent.Configuration()
        config.stored.showsSecurityCodeField = false
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        sut.payment = Payment(amount: Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "•••• 1234")
        XCTAssertEqual(vc?.title, "Test-Confirm Payment Method Name payment")
        XCTAssertEqual(vc?.actions[0].title, "Test-Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Test-Pay €1,234.56")
    }
    
    func testStoredCardPaymentWithNoCVV() throws {
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
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.detectedBrandsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 6)
            XCTAssertFalse(cardLogoView.primaryLogoView.isHidden)
            XCTAssertTrue(cardLogoView.secondaryLogoView.isHidden)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 8)
    }
    
    func testShouldShowNoCardTypesOnInvalidPANEnter() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.detectedBrandsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            self.populate(textItemView: cardNumberItemView!, with: "1231")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 3)
                XCTAssertFalse(cardLogoView.primaryLogoView.isHidden)
                XCTAssertTrue(cardLogoView.secondaryLogoView.isHidden)
                
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
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.detectedBrandsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            self.populate(textItemView: cardNumberItemView!, with: "3400")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 3)
                XCTAssertFalse(cardLogoView.primaryLogoView.isHidden)
                XCTAssertTrue(cardLogoView.secondaryLogoView.isHidden)
                
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
                                publicKeyProvider: PublicKeyProviderMock(),
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
    
    func testCardNumberShouldPassFocusToDate() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        
        // no focus change without panglength till max (19)
        
        var newResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView?.becomeFirstResponder()
        
        XCTAssertTrue(cardNumberItemView!.isFirstResponder)
        
        populate(textItemView: cardNumberItemView, with: Dummy.amexCard.number!)
        wait(for: .seconds(1))
        
        XCTAssertTrue(cardNumberItemView!.isFirstResponder)
        XCTAssertFalse(expiryDateItemView!.isFirstResponder)
        
        // focus should change with pan length set
        newResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress, panLength: 15)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView?.becomeFirstResponder()
        
        XCTAssertTrue(cardNumberItemView!.isFirstResponder)
        
        populate(textItemView: cardNumberItemView, with: Dummy.amexCard.number!)
        wait(for: .seconds(1))
        
        XCTAssertFalse(cardNumberItemView!.isFirstResponder)
        XCTAssertTrue(expiryDateItemView!.isFirstResponder)
        
        // focus should also change when reaching default max length 19
        newResponse = BinLookupResponse(brands: [CardBrand(type: .maestro)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView?.becomeFirstResponder()
        
        XCTAssertTrue(cardNumberItemView!.isFirstResponder)
        
        populate(textItemView: cardNumberItemView, with: "6771830000000000006")
        wait(for: .seconds(1))
        
        XCTAssertFalse(cardNumberItemView!.isFirstResponder)
        XCTAssertTrue(expiryDateItemView!.isFirstResponder)
    }
    
    func testDateShouldPassFocusToCVC() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        
        wait(for: .seconds(1))
        
        expiryDateItemView?.becomeFirstResponder()
        self.append(textItemView: expiryDateItemView!, with: "3")
        
        wait(for: .seconds(2))
        
        XCTAssertTrue(expiryDateItemView!.textField.isFirstResponder)
        self.append(textItemView: expiryDateItemView!, with: "3")
        self.append(textItemView: expiryDateItemView!, with: "0")
        
        wait(for: .seconds(1))
        
        XCTAssertTrue(securityCodeItemView!.textField.isFirstResponder)
        XCTAssertFalse(expiryDateItemView!.textField.isFirstResponder)
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
        
        wait(for: .seconds(1))
        
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
                                publicKeyProvider: PublicKeyProviderMock(),
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
            
            let postalCodeItemView: FormTextItemView<FormPostalCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem")
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
                                publicKeyProvider: PublicKeyProviderMock(),
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
            XCTAssertTrue(paymentDetails!.password!.starts(with: "eyJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwiYWxnIjoiUlNBLU9BRVAtMjU2IiwidmVyc2lvbiI6IjEifQ"))
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
                XCTAssertEqual(taxNumberItemView!.titleLabel.text, "Birthdate or Corporate registration number")
                XCTAssertFalse(taxNumberItemView!.isHidden)
                XCTAssertFalse(passwordItemView!.isHidden)
                self.populate(textItemView: taxNumberItemView!, with: "121212")
                self.populate(textItemView: passwordItemView!, with: "12")
                
                self.tapSubmitButton(on: sut.viewController.view)
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testBrazilSSNAuto() {
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
                                publicKeyProvider: PublicKeyProviderMock(),
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
        
        fillCard(on: sut.viewController.view, with: Dummy.visaCard)
        
        wait(for: .seconds(1))
        XCTAssertEqual(brazilSSNItemView!.titleLabel.text, "CPF/CNPJ")
        XCTAssertFalse(brazilSSNItemView!.isHidden)
        populate(textItemView: brazilSSNItemView!, with: "123.123.123-12")
        
        tapSubmitButton(on: sut.viewController.view)
        
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: false)])
        sut.cardViewController.update(binInfo: newResponse)
        
        wait(for: .seconds(1))
        
        XCTAssertTrue(brazilSSNItemView!.isHidden)
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testBrazilSSNDisabled() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        let config = CardComponent.Configuration(socialSecurityNumberMode: .hide)
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init())
        
        let brazilSSNItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem")
        XCTAssertNil(brazilSSNItemView)
        
        // config is always hide, so item is not added to view
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: true)])
        sut.cardViewController.update(binInfo: newResponse)
        
        XCTAssertNil(brazilSSNItemView)
    }
    
    func testBrazilSSNEnabled() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        let config = CardComponent.Configuration(socialSecurityNumberMode: .show)
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init())
        
        let brazilSSNItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem")
        XCTAssertFalse(brazilSSNItemView!.isHidden)
        
        // config is always show, so bin response is ignored
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: false)])
        sut.cardViewController.update(binInfo: newResponse)
        
        XCTAssertFalse(brazilSSNItemView!.isHidden)
    }
    
    func testLuhnCheck() {
        let brands = [CardBrand(type: .visa, isLuhnCheckEnabled: true),
                      CardBrand(type: .masterCard, isLuhnCheckEnabled: false)]
        
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        
        let cardNumberItem = sut.cardViewController.items.numberContainerItem.numberItem
        cardNumberItem.update(brands: brands)
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertFalse(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())
        
        cardNumberItem.selectBrand(at: 1)
        XCTAssertTrue(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())
    }
    
    func testCardLogos() throws {

        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: CardComponent.Configuration())

        XCTAssertTrue(sut.cardViewController.items.numberContainerItem.showsSupportedCardLogos)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(30))

        let supportedCardLogosItemId = "AdyenCard.CardComponent.numberContainerItem.supportedCardLogosItem"

        var supportedCardLogosItem: FormCardLogosItemView = try XCTUnwrap(sut.viewController.view.findView(with: supportedCardLogosItemId))
        XCTAssertFalse(supportedCardLogosItem.isHidden)

        // Valid input
        
        fillCard(on: sut.viewController.view, with: Dummy.visaCard)
        var binResponse = BinLookupResponse(brands: [CardBrand(type: .visa, isSupported: true)])
        sut.cardViewController.update(binInfo: binResponse)
        
        wait(for: .milliseconds(30))
        
        supportedCardLogosItem = try XCTUnwrap(sut.viewController.view.findView(with: supportedCardLogosItemId))
        XCTAssertTrue(supportedCardLogosItem.isHidden)
    }
    
    func testCVCDisplayMode() {
        let brands = [CardBrand(type: .visa, cvcPolicy: .required),
                      CardBrand(type: .americanExpress, cvcPolicy: .optional),
                      CardBrand(type: .masterCard, cvcPolicy: .hidden)]
        
        let method = CardPaymentMethod(type: "visa",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        let config = CardComponent.Configuration()
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        
        let cvcItem = sut.cardViewController.items.securityCodeItem
        cvcItem.value = ""
        cvcItem.displayMode = brands[0].securityCodeItemDisplayMode
        XCTAssertFalse(cvcItem.isValid())
        cvcItem.value = "1"
        XCTAssertFalse(cvcItem.isValid())
        cvcItem.value = "123"
        XCTAssertTrue(cvcItem.isValid())

        cvcItem.displayMode = brands[1].securityCodeItemDisplayMode
        XCTAssertTrue(cvcItem.isValid())
        cvcItem.value = "1"
        XCTAssertFalse(cvcItem.isValid())
        cvcItem.value = "" // no value or correct value (3-4 digits) is valid
        XCTAssertTrue(cvcItem.isValid())

        cvcItem.displayMode = brands[2].securityCodeItemDisplayMode
        XCTAssertTrue(cvcItem.isValid())
        cvcItem.value = "1"
        XCTAssertTrue(cvcItem.isValid())
        cvcItem.value = ""
        XCTAssertTrue(cvcItem.isValid())

        cvcItem.displayMode = .required
        cvcItem.value = "123"
        cvcItem.displayMode = .hidden
        XCTAssertEqual(cvcItem.value, "")
    }
    
    func testExpiryDateOptionality() {
        let brands = [CardBrand(type: .visa, expiryDatePolicy: .required),
                      CardBrand(type: .masterCard, expiryDatePolicy: .optional),
                      CardBrand(type: .masterCard, expiryDatePolicy: .hidden)]
        
        let method = CardPaymentMethod(type: "visa",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        let config = CardComponent.Configuration()
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        
        let expDateItem = sut.cardViewController.items.expiryDateItem
        expDateItem.value = ""
        expDateItem.isOptional = brands[0].isExpiryDateOptional
        // mixed means non option, valid value must be entered
        XCTAssertFalse(expDateItem.isValid())
        expDateItem.value = "1"
        XCTAssertFalse(expDateItem.isValid())
        XCTAssertEqual(sut.cardViewController.card.expiryYear, "20")
        XCTAssertEqual(sut.cardViewController.card.expiryMonth, "1")
        expDateItem.value = "0224"
        XCTAssertTrue(expDateItem.isValid())
        XCTAssertEqual(sut.cardViewController.card.expiryYear, "2024")
        XCTAssertEqual(sut.cardViewController.card.expiryMonth, "02")
        
        expDateItem.isOptional = brands[1].isExpiryDateOptional
        XCTAssertTrue(expDateItem.isValid())
        expDateItem.value = "1"
        XCTAssertEqual(sut.cardViewController.card.expiryYear, "20")
        XCTAssertEqual(sut.cardViewController.card.expiryMonth, "1")
        XCTAssertFalse(expDateItem.isValid())
        // no value or correct value (3-4 digits) is valid
        expDateItem.value = ""
        XCTAssertNil(sut.cardViewController.card.expiryYear)
        XCTAssertNil(sut.cardViewController.card.expiryMonth)
        XCTAssertTrue(expDateItem.isValid())
    }
    
    func testInstallmentsWithDefaultAndCardBasedOptions() {
        let method = CardPaymentMethod(type: "visa", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let cardBasedInstallmentOptions: [CardType: InstallmentOptions] = [.visa:
            InstallmentOptions(maxInstallmentMonth: 8, includesRevolving: true)]
        let defaultInstallmentOptions = InstallmentOptions(monthValues: [3, 6, 9, 12], includesRevolving: false)
        let config = CardComponent.Configuration(installmentConfiguration: InstallmentConfiguration(cardBasedOptions: cardBasedInstallmentOptions, defaultOptions: defaultInstallmentOptions))
        let cardTypeProviderMock = BinInfoProviderMock()
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let installmentItemView: FormCardInstallmentsItemView? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
        XCTAssertEqual(installmentItemView!.titleLabel.text, "Number of installments")
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        XCTAssertFalse(installmentItemView!.isHidden)
        
        sut.cardViewController.items.installmentsItem?.update(cardType: .visa)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 9)
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[2])
        XCTAssertEqual(installmentItemView!.inputControl.label, "2 months")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        sut.cardViewController.items.installmentsItem?.update(cardType: .americanExpress)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 5)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertNil(sut.cardViewController.installments)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[2])
        XCTAssertEqual(installmentItemView!.inputControl.label, "6 months")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        // nil card type refers to default options if exists
        sut.cardViewController.items.installmentsItem?.update(cardType: nil)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 5)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertEqual(installmentItemView!.inputControl.label, "6 months")
        XCTAssertNotNil(sut.cardViewController.installments)
    }
    
    func testInstallmentsWithDefaultOptions() {
        let method = CardPaymentMethod(type: "visa", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let defaultInstallmentOptions = InstallmentOptions(monthValues: [3, 6, 9, 12], includesRevolving: false)
        let config = CardComponent.Configuration(installmentConfiguration: InstallmentConfiguration(defaultOptions: defaultInstallmentOptions))
        let cardTypeProviderMock = BinInfoProviderMock()
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let installmentItemView: FormCardInstallmentsItemView? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
        XCTAssertEqual(installmentItemView!.titleLabel.text, "Number of installments")
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        XCTAssertFalse(installmentItemView!.isHidden)
        
        sut.cardViewController.items.installmentsItem?.update(cardType: .americanExpress)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 5)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertNil(sut.cardViewController.installments)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[2])
        XCTAssertEqual(installmentItemView!.inputControl.label, "6 months")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        sut.cardViewController.items.installmentsItem?.update(cardType: .visa)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 5)
        XCTAssertEqual(installmentItemView!.inputControl.label, "6 months")
        XCTAssertNotNil(sut.cardViewController.installments)
    }
    
    func testInstallmentsWitCardBasedOptions() {
        let method = CardPaymentMethod(type: "visa", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let cardBasedInstallmentOptions: [CardType: InstallmentOptions] = [.visa:
            InstallmentOptions(maxInstallmentMonth: 8, includesRevolving: true)]
        let config = CardComponent.Configuration(installmentConfiguration: InstallmentConfiguration(cardBasedOptions: cardBasedInstallmentOptions))
        let cardTypeProviderMock = BinInfoProviderMock()
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let installmentItemView: FormCardInstallmentsItemView? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
        XCTAssertEqual(installmentItemView!.titleLabel.text, "Number of installments")
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        XCTAssertTrue(installmentItemView!.isHidden)
        
        sut.cardViewController.items.installmentsItem?.update(cardType: .americanExpress)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 1)
        XCTAssertTrue(installmentItemView!.isHidden)
        XCTAssertNil(sut.cardViewController.installments)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        
        // set card type one that has installment options
        sut.cardViewController.items.installmentsItem?.update(cardType: .visa)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 9)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
        XCTAssertNil(sut.cardViewController.installments)
        
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[2])
        XCTAssertEqual(installmentItemView!.inputControl.label, "2 months")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[1])
        XCTAssertEqual(installmentItemView!.inputControl.label, "Revolving payment")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        // nil card type means no options since there is no default option
        sut.cardViewController.items.installmentsItem?.update(cardType: nil)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 1)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
    }
    
    func testSupportedCardLogoVisibility() {
        let method = CardPaymentMethod(type: "visa",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        let config = CardComponent.Configuration()
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let numberItem = sut.cardViewController.items.numberContainerItem.numberItem
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let logoItemView: FormCardLogosItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberContainerItem.supportedCardLogosItem")
        
        XCTAssertFalse(logoItemView!.isHidden)
        
        // valid card but still active. logos should be visible
        populate(textItemView: cardNumberItemView, with: Dummy.visaCard.number!)
        XCTAssertFalse(logoItemView!.isHidden)
        
        // with valid card and inactive, logos should hide
        numberItem.isActive = false
        XCTAssertTrue(logoItemView!.isHidden)
        
        // invalid card and active/inactive numberitem, logos should be visible
        populate(textItemView: cardNumberItemView, with: "1234")
        numberItem.isActive = true
        wait(for: .seconds(1))
        XCTAssertFalse(logoItemView!.isHidden)
        numberItem.isActive = false
        wait(for: .seconds(1))
        XCTAssertFalse(logoItemView!.isHidden)
    }
    
    func testDualBrandNoSelection() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        var config = CardComponent.Configuration(socialSecurityNumberMode: .show)
        config.allowedCardTypes = [.visa, .carteBancaire]
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init())
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        
        let binResponse = BinLookupResponse(brands: [CardBrand(type: .visa), CardBrand(type: .carteBancaire)], isCreatedLocally: false)
        sut.cardViewController.update(binInfo: binResponse)
        wait(for: .milliseconds(300))
        
        XCTAssertFalse(cardNumberItemView!.detectedBrandsView.secondaryLogoView.isHidden)
        XCTAssertFalse(cardNumberItemView?.detectedBrandsView.primaryLogoView.alpha == 1)
        XCTAssertFalse(cardNumberItemView?.detectedBrandsView.secondaryLogoView.alpha == 1)
    }
    
    func testSupportedCardLogoAlpha() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "elo"])
        let config = CardComponent.Configuration(socialSecurityNumberMode: .show)
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: .init())
        
        let logoItem = sut.cardViewController.items.numberContainerItem.supportedCardLogosItem
        XCTAssertEqual(logoItem.alpha, 1)
        
        var binResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress)])
        sut.cardViewController.update(binInfo: binResponse)
        XCTAssertTrue(logoItem.isHidden.wrappedValue)
        
        binResponse = BinLookupResponse(brands: [])
        sut.cardViewController.update(binInfo: binResponse)
        XCTAssertFalse(logoItem.isHidden.wrappedValue)
        
        binResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress, isSupported: false)])
        sut.cardViewController.update(binInfo: binResponse)
        XCTAssertFalse(logoItem.isHidden.wrappedValue)
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
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
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
        sut.cardViewController.items.numberContainerItem.numberItem.value = "4111 1111 1111 1111"
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
        // Then
        XCTAssertTrue(sut.cardViewController.items.numberContainerItem.numberItem.value.isEmpty)
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
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
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
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
        // Then
        XCTAssertTrue(sut.cardViewController.items.securityCodeItem.value.isEmpty)
    }
    
    func testClearShouldResetHolderNameItemToEmptyValue() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration(showsHolderNameField: true)
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        sut.cardViewController.items.holderNameItem.value = "Katrina del Mar"
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
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
        
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
        // Then
        XCTAssertFalse(sut.cardViewController.items.storeDetailsItem.value)
    }
    
    func testClearShouldAssignEmptyPostalAddressToBillingAddressItem() throws {
        // Given
        let expectedPostalAddress = PostalAddress(city: "",
                                                  country: "US",
                                                  houseNumberOrName: "",
                                                  postalCode: "",
                                                  stateOrProvince: "AL",
                                                  street: "",
                                                  apartment: nil)
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        // show view controller
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        // When
        // hide view controller
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        
        wait(for: .seconds(1))
        
        // Then
        let postalAddress = sut.cardViewController.items.billingAddressItem.value
        XCTAssertEqual(expectedPostalAddress, postalAddress)
    }
    
    func testCardPrefillingGivenBillingAddressInFullModeShouldPrefillItems() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        configuration.billingAddressMode = .full
        
        let prefilledSut = CardComponent(paymentMethod: method,
                                         apiContext: Dummy.context,
                                         configuration: configuration,
                                         shopperInformation: shopperInformation)
        
        // When
        UIApplication.shared.keyWindow?.rootViewController = prefilledSut.cardViewController
        
        wait(for: .seconds(1))
        
        // Then
        let view: UIView = prefilledSut.cardViewController.view
        
        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let expectedHoldername = try XCTUnwrap(shopperInformation.card?.holderName)
        let holdername = holdernameView.item.value
        XCTAssertEqual(expectedHoldername, holdername)
        
        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let expectedSocialSecurityNumber = try XCTUnwrap(shopperInformation.socialSecurityNumber)
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertEqual(expectedSocialSecurityNumber, socialSecurityNumber)
        
        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
    }
    
    func testCardPrefillingGivenBillingAddressInPostalCodeModeShouldPrefillItems() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        configuration.billingAddressMode = .postalCode
        
        let prefilledSut = CardComponent(paymentMethod: method,
                                         apiContext: Dummy.context,
                                         configuration: configuration,
                                         shopperInformation: shopperInformation)
        
        // When
        UIApplication.shared.keyWindow?.rootViewController = prefilledSut.cardViewController
        
        wait(for: .seconds(1))
        
        // Then
        let view: UIView = prefilledSut.cardViewController.view
        
        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let expectedHoldername = try XCTUnwrap(shopperInformation.card?.holderName)
        let holdername = holdernameView.item.value
        XCTAssertEqual(expectedHoldername, holdername)

        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let expectedSocialSecurityNumber = try XCTUnwrap(shopperInformation.socialSecurityNumber)
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertEqual(expectedSocialSecurityNumber, socialSecurityNumber)
        
        let postalCodeView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        let expectedPostalCode = try XCTUnwrap(shopperInformation.billingAddress?.postalCode)
        let postalCode = postalCodeView.item.value
        XCTAssertEqual(expectedPostalCode, postalCode)
    }
    
    func testCardPrefillingGivenNoShopperInformationAndFullAddressModeShouldNotPrefillItems() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        configuration.billingAddressMode = .full
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        
        // When
        UIApplication.shared.keyWindow?.rootViewController = sut.cardViewController
        
        wait(for: .seconds(1))
        
        // Then
        let view: UIView = sut.cardViewController.view
        
        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let holdername = holdernameView.item.value
        XCTAssertTrue(holdername.isEmpty)
        
        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertTrue(socialSecurityNumber.isEmpty)
        
        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = PostalAddressMocks.emptyUSPostalAddress
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
    }
    
    func testCardPrefillingGivenNoShopperInformationAndPostalCodeModeShouldNotPrefillItems() throws {
        // Given
        let method = CardPaymentMethod(type: "bcmc",
                                       name: "Test name",
                                       fundingSource: .credit,
                                       brands: ["visa", "amex", "mc"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        configuration.billingAddressMode = .postalCode
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration)
        
        // When
        UIApplication.shared.keyWindow?.rootViewController = sut.cardViewController
        
        wait(for: .seconds(1))
        
        // Then
        let view: UIView = sut.cardViewController.view
        
        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let holdername = holdernameView.item.value
        XCTAssertTrue(holdername.isEmpty)
        
        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertTrue(socialSecurityNumber.isEmpty)
        
        let postalCodeView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        let postalCode = postalCodeView.item.value
        XCTAssertTrue(postalCode.isEmpty)
    }
    
    func testAddressWithSupportedCountries() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        config.billingAddressCountryCodes = ["UK"]
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config)
        
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "GBP"), countryCode: "GB")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.country")
        
        XCTAssertEqual(sut.cardViewController.items.billingAddressItem.supportedCountryCodes, ["UK"])
        XCTAssertEqual(countryItemView?.inputControl.label, "United Kingdom")
    }
    
    func testAddressWithSupportedCountriesWithMatchingPrefill() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        config.billingAddressCountryCodes = ["US", "JP"]
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config, shopperInformation: shopperInformation)
        
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.country")
        
        XCTAssertEqual(sut.cardViewController.items.billingAddressItem.supportedCountryCodes, ["US", "JP"])
        XCTAssertEqual(countryItemView?.inputControl.label, "United States")
    }
    
    func testAddressWithSupportedCountriesWithNonMatchingPrefill() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        config.billingAddressCountryCodes = ["UK"]
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config, shopperInformation: shopperInformation)
        
        sut.payment = .init(amount: Amount(value: 100, currencyCode: "GBP"), countryCode: "GB")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .seconds(1))
        
        let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.billingAddress.country")
        
        XCTAssertEqual(sut.cardViewController.items.billingAddressItem.supportedCountryCodes, ["UK"])
        XCTAssertEqual(countryItemView?.inputControl.label, "United Kingdom")
    }
    
    func testOptionalInvalidFullAddressWithCertainSchemes() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        config.billingAddressCountryCodes = ["US"]
        config.billingAddressRequirementPolicy = .optionalForCardTypes([.visa])
        
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        sut.payment = Payment(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let view: UIView = sut.cardViewController.view
        
        wait(for: .milliseconds(300))
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        
        let postalCodeField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.fullAddressZipCode))
        
        let cityField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.city))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        populate(textItemView: postalCodeField, with: "123")
        populate(textItemView: cityField, with: "Amsterdam")
        
        wait(for: .milliseconds(800))
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            
            XCTAssertNotNil(sut.cardViewController.validAddress)
            XCTAssertNotNil(data.billingAddress?.country)
            XCTAssertNotNil(data.billingAddress?.stateOrProvince)
            
            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOptionalValidFullAddressWithCertainSchemes() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        config.billingAddressCountryCodes = ["US"]
        config.billingAddressRequirementPolicy = .optionalForCardTypes([.visa])
        
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                shopperInformation: shopperInformation,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        sut.payment = Payment(amount: Amount(value: 100, currencyCode: "GBP"), countryCode: "GB")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let view: UIView = sut.cardViewController.view
        
        wait(for: .milliseconds(300))
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        wait(for: .milliseconds(800))
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            
            XCTAssertEqual(data.billingAddress, self.shopperInformation.billingAddress)
            
            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOptionalValidPostalAddressWithCertainSchemes() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        config.billingAddressCountryCodes = ["US"]
        config.billingAddressRequirementPolicy = .optionalForCardTypes([.visa])
        
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        sut.payment = Payment(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let view: UIView = sut.cardViewController.view
        
        wait(for: .milliseconds(300))
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        
        let postalCodeField: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        populate(textItemView: postalCodeField, with: "123")
        
        wait(for: .milliseconds(800))
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            
            XCTAssertEqual(data.billingAddress, PostalAddress(postalCode: "123"))
            
            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOptionalInvalidPostalAddressWithCertainSchemes() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        config.billingAddressCountryCodes = ["US"]
        config.billingAddressRequirementPolicy = .optionalForCardTypes([.visa])
        
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }
        
        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: config,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        sut.payment = Payment(amount: Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let view: UIView = sut.cardViewController.view
        
        wait(for: .milliseconds(300))
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: "AdyenCard.CardComponent.securityCodeItem"))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: "AdyenCard.CardComponent.expiryDateItem"))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        wait(for: .milliseconds(800))
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            
            XCTAssertNil(data.billingAddress)
            
            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOptionalApartmentNameNil() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])

        var configuration = CardComponent.Configuration()
        configuration.billingAddressMode = .full
        configuration.billingAddressCountryCodes = ["US"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let view: UIView = sut.cardViewController.view

        wait(for: .milliseconds(300))

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let postalCodeField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.fullAddressZipCode))

        let cityField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.city))
        let streetField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.street))

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        populate(textItemView: postalCodeField, with: "123")
        populate(textItemView: cityField, with: "Seattle")
        populate(textItemView: streetField, with: "Test Street")

        wait(for: .milliseconds(800))

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testOptionalApartmentNameNonNil() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])

        var configuration = CardComponent.Configuration()
        configuration.billingAddressMode = .full
        configuration.billingAddressCountryCodes = ["US"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .visa)],
                                 issuingCountryCode: "US"))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let view: UIView = sut.cardViewController.view

        wait(for: .milliseconds(300))

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let postalCodeField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.fullAddressZipCode))

        let cityField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.city))
        let houseNumberOrNameField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.houseNumberOrName))
        let streetField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.street))

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        populate(textItemView: postalCodeField, with: "123")
        populate(textItemView: cityField, with: "Seattle")
        populate(textItemView: houseNumberOrNameField, with: "12")
        populate(textItemView: streetField, with: "Test Street")

        wait(for: .milliseconds(800))

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testNoStateOrProvincePresentInBillingAddress() throws {
        let method = CardPaymentMethod(type: "scheme", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])

        var configuration = CardComponent.Configuration()
        configuration.billingAddressMode = .full
        configuration.billingAddressCountryCodes = ["GB"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bijenkorfCard)],
                                 issuingCountryCode: "GB"))
        }

        let sut = CardComponent(paymentMethod: method,
                                apiContext: Dummy.context,
                                configuration: configuration,
                                style: FormComponentStyle(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let view: UIView = sut.cardViewController.view

        wait(for: .milliseconds(300))

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let postalCodeField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.fullAddressZipCode))

        let cityField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.city))
        let houseNumberOrNameField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.houseNumberOrName))
        let streetField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.street))

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4596 1234 2345 087")
        populate(textItemView: expiryDateField, with: "12/30")

        populate(textItemView: postalCodeField, with: "123")
        populate(textItemView: cityField, with: "London")
        populate(textItemView: houseNumberOrNameField, with: "12")
        populate(textItemView: streetField, with: "Test Street")

        wait(for: .milliseconds(800))

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - Private
    
    private func focus(textItemView: some FormTextItemView<some FormTextItem>) {
        textItemView.textField.becomeFirstResponder()
    }
    
    private enum CardViewIdentifier {
        static let holdername = "AdyenCard.CardComponent.holderNameItem"
        static let billingAddress = "AdyenCard.CardComponent.billingAddress"
        static let zipCode = "AdyenCard.CardComponent.postalCodeItem"
        static let fullAddressZipCode = "AdyenCard.CardComponent.billingAddress.postalCode"
        static let fullAddress = "AdyenCard.CardComponent.billingAddress"
        static let city = "AdyenCard.CardComponent.billingAddress.city"
        static let houseNumberOrName = "AdyenCard.CardComponent.billingAddress.houseNumberOrName"
        static let street = "AdyenCard.CardComponent.billingAddress.street"
        static let stateOrProvince = "AdyenCard.CardComponent.billingAddress.stateOrProvince"
        static let socialSecurityNumber = "AdyenCard.CardComponent.socialSecurityNumberItem"
        static let securityCode = "AdyenCard.CardComponent.securityCodeItem"
        static let expiryDate = "AdyenCard.CardComponent.expiryDateItem"
        static let cardNumber = "AdyenCard.FormCardNumberContainerItem.numberItem"
    }
    
    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370",
                                                             card: .init(holderName: "Katrina del Mar"))
        return shopperInformation
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

extension CardComponentTests {
    
    func fillCard(on view: UIView, with card: Card) {
        let cardNumberItemView: FormCardNumberItemView? = view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
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
