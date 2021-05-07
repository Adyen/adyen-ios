//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
import XCTest

class CardComponentTests: XCTestCase {

    func testClientKeyInitializatpion() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let sut = CardComponent(paymentMethod: method, clientKey: Dummy.dummyClientKey)

        XCTAssertEqual(sut.cardBrandProvider.clientKey, Dummy.dummyClientKey)
        XCTAssertEqual(sut.cardPublicKeyProvider.clientKey, Dummy.dummyClientKey)
        XCTAssertEqual(sut.environment.clientKey, Dummy.dummyClientKey)

        sut.clientKey = "locall_ORSXG5C7MNWGSZLOORPWWZLZ"

        XCTAssertEqual(sut.cardBrandProvider.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")
        XCTAssertEqual(sut.cardPublicKeyProvider.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")
        XCTAssertEqual(sut.environment.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")

        sut.environment = .test

        XCTAssertEqual(sut.cardBrandProvider.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")
        XCTAssertEqual(sut.cardPublicKeyProvider.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")
        XCTAssertEqual(sut.environment.clientKey, "locall_ORSXG5C7MNWGSZLOORPWWZLZ")

        sut.clientKey = "localll_ORSXG5C7MNWGSZLOORPWWZLZ2"

        XCTAssertEqual(sut.cardBrandProvider.clientKey, "localll_ORSXG5C7MNWGSZLOORPWWZLZ2")
        XCTAssertEqual(sut.cardPublicKeyProvider.clientKey, "localll_ORSXG5C7MNWGSZLOORPWWZLZ2")
        XCTAssertEqual(sut.environment.clientKey, "localll_ORSXG5C7MNWGSZLOORPWWZLZ2")
    }

    func testRequiresKeyboardInput() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let sut = CardComponent(paymentMethod: method, clientKey: Dummy.dummyClientKey)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: method,
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        XCTAssertEqual(sut.cardViewController.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(sut.cardViewController.expiryDateItem.placeholder, localizedString(.cardExpiryItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.expiryDateItem.validationFailureMessage, localizedString(.cardExpiryItemInvalid, sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.securityCodeItem.title, localizedString(.cardCvcItemTitle, sut.localizationParameters))
        XCTAssertNil(sut.cardViewController.securityCodeItem.placeholder)
        XCTAssertEqual(sut.cardViewController.securityCodeItem.validationFailureMessage, localizedString(.cardCvcItemInvalid, sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.holderNameItem.title, localizedString(.cardNameItemTitle, sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.holderNameItem.placeholder, localizedString(.cardNameItemPlaceholder, sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.holderNameItem.validationFailureMessage, localizedString(.cardNameItemInvalid, sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.storeDetailsItem.title, localizedString(.cardStoreDetailsButton, sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: method,
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        XCTAssertEqual(sut.cardViewController.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(sut.cardViewController.expiryDateItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_expiryItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.expiryDateItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_expiryItem_invalid"), sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.securityCodeItem.title, localizedString(LocalizationKey(key: "adyen_card_cvcItem_title"), sut.localizationParameters))
        XCTAssertNil(sut.cardViewController.securityCodeItem.placeholder)
        XCTAssertEqual(sut.cardViewController.securityCodeItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_cvcItem_invalid"), sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.holderNameItem.title, localizedString(LocalizationKey(key: "adyen_card_nameItem_title"), sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.holderNameItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_nameItem_placeholder"), sut.localizationParameters))
        XCTAssertEqual(sut.cardViewController.holderNameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_nameItem_invalid"), sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.storeDetailsItem.title, localizedString(LocalizationKey(key: "adyen_card_storeDetailsButton"), sut.localizationParameters))
        
        XCTAssertEqual(sut.cardViewController.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.localizationParameters))
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
        
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = CardComponent(paymentMethod: cardPaymentMethod,
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey,
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
            
            let storeDetailsItemView: FormSwitchItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem")
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
            XCTAssertNotNil(securityCodeCvvHint)
            
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
                                clientKey: Dummy.dummyClientKey)

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
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
        
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
                                clientKey: Dummy.dummyClientKey)
        
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
                                clientKey: Dummy.dummyClientKey)

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
        let sut = CardComponent(paymentMethod: method,
                                clientKey: Dummy.dummyClientKey)

        let cardTypeProviderMock = CardTypeProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .americanExpress)]))
        }

        sut.cardBrandProvider = cardTypeProviderMock
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
            XCTAssertEqual(value, "370000")
            expectationBin.fulfill()
        }, onCardBrandChange: { value in
            XCTAssertEqual(value, [CardBrand(type: .americanExpress)])
            expectationCardType.fulfill()
        })
        sut.cardComponentDelegate = delegateMock
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "37000000000")
        }
        
        wait(for: [expectationBin, expectationCardType], timeout: 10)
    }
    
    func testCVVFormatterChange() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: Dummy.dummyClientKey)

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
                                clientKey: Dummy.dummyClientKey,
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
                                clientKey: Dummy.dummyClientKey,
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
                                clientKey: Dummy.dummyClientKey)

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
                                clientKey: Dummy.dummyClientKey)
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
                                clientKey: Dummy.dummyClientKey)
        sut.payment = Payment(amount: Payment.Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
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
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = Payment(amount: Payment.Amount(value: 123456, currencyCode: "EUR"), countryCode: "NL")
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
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
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
                                configuration: configuration,
                                clientKey: Dummy.dummyClientKey)
        XCTAssertNotNil(sut.viewController as? UIAlertController)
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
    }

    func testShouldShow4CardTypesOnInit() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "cup", "maestro", "jcb"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: Dummy.dummyClientKey)
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
                                clientKey: Dummy.dummyClientKey)
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
                                clientKey: Dummy.dummyClientKey)
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

    func testSubmit() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        // Dummy public key
        let cardPublicKey = Dummy.dummyPublicKey
        let cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: cardPublicKey)
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                configuration: config,
                                cardPublicKeyProvider: cardPublicKeyProvider,
                                clientKey: Dummy.dummyClientKey)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

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

            XCTAssertNil(data.billingAddress?.apartment)
            XCTAssertEqual(data.billingAddress?.houseNumberOrName, "House Number")
            XCTAssertEqual(data.billingAddress?.street, "Address")
            XCTAssertEqual(data.billingAddress?.stateOrProvince, "AL")
            XCTAssertEqual(data.billingAddress?.city, "City")
            XCTAssertEqual(data.billingAddress?.country, "US")
            XCTAssertEqual(data.billingAddress?.postalCode, "Postal Code")

            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.cardViewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.cardViewController.button.showsActivityIndicator, false)
        }

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
        let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
        let storeDetailsItemView: FormSwitchItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem")

        let houseNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.houseNumberOrName")
        let addressItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.street")
        let cityItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.city")
        let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.postalCode")

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            self.populate(textItemView: cardNumberItemView!, with: "4917 6100 0000 0000")
            self.populate(textItemView: expiryDateItemView!, with: "03/30")
            self.populate(textItemView: securityCodeItemView!, with: "737")

            self.populate(textItemView: houseNumberItemView!, with: "House Number")
            self.populate(textItemView: addressItemView!, with: "Address")
            self.populate(textItemView: cityItemView!, with: "City")
            self.populate(textItemView: postalCodeItemView!, with: "Postal Code")

            _ = storeDetailsItemView!.accessibilityActivate()

            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testDateShouldPassFocusToCVC() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: Dummy.dummyClientKey)
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

    func testAddressNL() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                configuration: config,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = .init(amount: Payment.Amount(value: 100, currencyCode: "USD"), countryCode: "NL")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let houseNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.houseNumberOrName")
            let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.country")
            let addressItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.street")
            let apartmentSuiteItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.appartment")
            let cityItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.city")
            let provinceOrTerritoryItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.stateOrProvince")
            let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.postalCode")
            let headerItemView: UILabel? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.title")

            XCTAssertEqual(countryItemView!.titleLabel.text, "Country")
            XCTAssertEqual(countryItemView!.inputControl.label, "Netherlands")
            XCTAssertEqual(houseNumberItemView!.titleLabel.text, "House number")
            XCTAssertEqual(addressItemView!.titleLabel.text, "Street")
            XCTAssertEqual(apartmentSuiteItemView!.titleLabel.text, "Apartment / Suite (optional)")
            XCTAssertEqual(cityItemView!.titleLabel.text, "City")
            XCTAssertEqual(provinceOrTerritoryItemView!.titleLabel.text, "Province or Territory")
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
            XCTAssertEqual(headerItemView!.text, "Billing address")

            XCTAssertTrue(houseNumberItemView!.alertLabel.isHidden)
            XCTAssertTrue(addressItemView!.alertLabel.isHidden)
            XCTAssertTrue(apartmentSuiteItemView!.alertLabel.isHidden)
            XCTAssertTrue(cityItemView!.alertLabel.isHidden)
            XCTAssertTrue(provinceOrTerritoryItemView!.alertLabel.isHidden)
            XCTAssertTrue(postalCodeItemView!.alertLabel.isHidden)

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertFalse(houseNumberItemView!.alertLabel.isHidden)
                XCTAssertFalse(addressItemView!.alertLabel.isHidden)
                XCTAssertTrue(apartmentSuiteItemView!.alertLabel.isHidden)
                XCTAssertFalse(cityItemView!.alertLabel.isHidden)
                XCTAssertFalse(provinceOrTerritoryItemView!.alertLabel.isHidden)
                XCTAssertFalse(postalCodeItemView!.alertLabel.isHidden)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testAddressUS() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                configuration: config,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = .init(amount: Payment.Amount(value: 100, currencyCode: "USD"), countryCode: "US")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            let houseNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.houseNumberOrName")
            let countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.country")
            let addressItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.street")
            let apartmentSuiteItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.appartment")
            let cityItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.city")
            let provinceOrTerritoryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.stateOrProvince")
            let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.postalCode")
            let headerItemView: UILabel? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.title")

            XCTAssertNil(apartmentSuiteItemView)

            XCTAssertEqual(countryItemView!.titleLabel.text, "Country")
            XCTAssertEqual(countryItemView!.inputControl.label, "United States")
            XCTAssertEqual(houseNumberItemView!.titleLabel.text, "Apartment / Suite (optional)")
            XCTAssertEqual(addressItemView!.titleLabel.text, "Address")
            XCTAssertEqual(cityItemView!.titleLabel.text, "City")
            XCTAssertEqual(provinceOrTerritoryItemView!.titleLabel.text, "State")
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Zip code")
            XCTAssertEqual(headerItemView!.text, "Billing address")

            XCTAssertTrue(houseNumberItemView!.alertLabel.isHidden)
            XCTAssertTrue(addressItemView!.alertLabel.isHidden)
            XCTAssertTrue(cityItemView!.alertLabel.isHidden)
            XCTAssertTrue(postalCodeItemView!.alertLabel.isHidden)

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertTrue(houseNumberItemView!.alertLabel.isHidden)
                XCTAssertFalse(addressItemView!.alertLabel.isHidden)
                XCTAssertFalse(cityItemView!.alertLabel.isHidden)
                XCTAssertFalse(postalCodeItemView!.alertLabel.isHidden)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testAddressSelectCountry() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .full
        let sut = CardComponent(paymentMethod: method,
                                configuration: config,
                                clientKey: Dummy.dummyClientKey)
        sut.payment = .init(amount: Payment.Amount(value: 100, currencyCode: "USD"), countryCode: "CA")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            var houseNumberItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.houseNumberOrName")
            var countryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.country")
            var addressItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.street")
            var apartmentSuiteItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.appartment")
            var cityItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.city")
            var provinceOrTerritoryItemView: FormRegionPickerItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.stateOrProvince")
            var postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.postalCode")

            XCTAssertNil(apartmentSuiteItemView)

            XCTAssertEqual(countryItemView!.titleLabel.text, "Country")
            XCTAssertEqual(countryItemView!.inputControl.label, "Canada")
            XCTAssertEqual(houseNumberItemView!.titleLabel.text, "Apartment / Suite (optional)")
            XCTAssertEqual(addressItemView!.titleLabel.text, "Address")
            XCTAssertEqual(cityItemView!.titleLabel.text, "City")
            XCTAssertEqual(provinceOrTerritoryItemView!.titleLabel.text, "Province or Territory")
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
            XCTAssertNil(apartmentSuiteItemView)

            countryItemView!.item.value = countryItemView!.item.selectableValues.first { $0.identifier == "BR" }!

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

                houseNumberItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.houseNumberOrName")
                countryItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.country")
                addressItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.street")
                apartmentSuiteItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.appartment")
                cityItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.city")
                provinceOrTerritoryItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.stateOrProvince")
                postalCodeItemView = sut.viewController.view.findView(with: "Adyen.FullFormAddressItem.postalCode")

                XCTAssertEqual(countryItemView!.titleLabel.text, "Country")
                XCTAssertEqual(countryItemView!.inputControl.label, "Brazil")
                XCTAssertEqual(houseNumberItemView!.titleLabel.text, "House number")
                XCTAssertEqual(addressItemView!.titleLabel.text, "Street")
                XCTAssertEqual(cityItemView!.titleLabel.text, "City")
                XCTAssertEqual(provinceOrTerritoryItemView!.titleLabel.text, "State")
                XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
                XCTAssertEqual(apartmentSuiteItemView!.titleLabel.text, "Apartment / Suite (optional)")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testPostalCode() {
        let cardPublicKey = Dummy.dummyPublicKey
        let cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: cardPublicKey)
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        var config = CardComponent.Configuration()
        config.billingAddressMode = .postalCode
        let sut = CardComponent(paymentMethod: method,
                                configuration: config,
                                clientKey: Dummy.dummyClientKey)
        sut.cardPublicKeyProvider = cardPublicKeyProvider
        sut.payment = .init(amount: Payment.Amount(value: 100, currencyCode: "USD"), countryCode: "US")
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

            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
            let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
            let postalCodeItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem")
            XCTAssertEqual(postalCodeItemView!.titleLabel.text, "Postal code")
            XCTAssertTrue(postalCodeItemView!.alertLabel.isHidden)

            self.populate(textItemView: cardNumberItemView!, with: "4917 6100 0000 0000")
            self.populate(textItemView: expiryDateItemView!, with: "03/30")
            self.populate(textItemView: securityCodeItemView!, with: "737")
            self.populate(textItemView: postalCodeItemView!, with: "12345")

            let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
            payButtonItemViewButton?.sendActions(for: .touchUpInside)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)
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
