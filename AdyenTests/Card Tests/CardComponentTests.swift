//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
import XCTest

class CardComponentTests: XCTestCase {

    func testRequiresKeyboardInput() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let sut = CardComponent(paymentMethod: method, clientKey: "test_client_key")

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        let sut = CardComponent(paymentMethod: method, clientKey: "test_client_key")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        sut.showsHolderNameField = true
        
        XCTAssertEqual(sut.expiryDateItem.title, ADYLocalizedString("adyen.card.expiryItem.title", nil))
        XCTAssertEqual(sut.expiryDateItem.placeholder, ADYLocalizedString("adyen.card.expiryItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.expiryDateItem.validationFailureMessage, ADYLocalizedString("adyen.card.expiryItem.invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.securityCodeItem.title, ADYLocalizedString("adyen.card.cvcItem.title", sut.localizationParameters))
        XCTAssertNil(sut.securityCodeItem.placeholder)
        XCTAssertEqual(sut.securityCodeItem.validationFailureMessage, ADYLocalizedString("adyen.card.cvcItem.invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.holderNameItem.title, ADYLocalizedString("adyen.card.nameItem.title", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.placeholder, ADYLocalizedString("adyen.card.nameItem.placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.validationFailureMessage, ADYLocalizedString("adyen.card.nameItem.invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.storeDetailsItem.title, ADYLocalizedString("adyen.card.storeDetailsButton", sut.localizationParameters))
        
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = CardPaymentMethodMock(type: "test_type", name: "test_name", brands: ["bcmc"])
        let payment = Payment(amount: Payment.Amount(value: 2, currencyCode: "EUR"), countryCode: "BE")
        let sut = CardComponent(paymentMethod: method, clientKey: "test_client_key")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        sut.showsHolderNameField = true
        
        XCTAssertEqual(sut.expiryDateItem.title, ADYLocalizedString("adyen.card.expiryItem.title", nil))
        XCTAssertEqual(sut.expiryDateItem.placeholder, ADYLocalizedString("adyen_card_expiryItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.expiryDateItem.validationFailureMessage, ADYLocalizedString("adyen_card_expiryItem_invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.securityCodeItem.title, ADYLocalizedString("adyen_card_cvcItem_title", sut.localizationParameters))
        XCTAssertNil(sut.securityCodeItem.placeholder)
        XCTAssertEqual(sut.securityCodeItem.validationFailureMessage, ADYLocalizedString("adyen_card_cvcItem_invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.holderNameItem.title, ADYLocalizedString("adyen_card_nameItem_title", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.placeholder, ADYLocalizedString("adyen_card_nameItem_placeholder", sut.localizationParameters))
        XCTAssertEqual(sut.holderNameItem.validationFailureMessage, ADYLocalizedString("adyen_card_nameItem_invalid", sut.localizationParameters))
        
        XCTAssertEqual(sut.storeDetailsItem.title, ADYLocalizedString("adyen_card_storeDetailsButton", sut.localizationParameters))
        
        XCTAssertEqual(sut.footerItem.submitButtonTitle, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
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
        
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let sut = CardComponent(paymentMethod: cardPaymentMethod,
                                clientKey: "test_client_key",
                                style: cardComponentStyle)
        sut.showsHolderNameField = true
        
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
            
            let footerItemViewButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton")
            let footerItemViewButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton.titleLabel")
            
            let headerItemView: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name")
            let headerItemViewTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name.titleLabel")
            
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
            
            XCTAssertEqual(sut.viewController.view.backgroundColor, .green)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testBigTitle() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: "test_client_key")
        sut.showsLargeTitle = false
        
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
        let sut = CardComponent(paymentMethod: method,
                                clientKey: "test_client_key")
        sut.showsSecurityCodeField = false
        
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
                                clientKey: "test_client_key")
        
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
                                clientKey: "test_client_key")
        sut.showsLargeTitle = false
        
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
                                clientKey: "test_client_key")
        sut.showsLargeTitle = false

        let cardTypeProviderMock = CardTypeProviderMock()
        cardTypeProviderMock.onFetch = {
            $0([.americanExpress])
        }

        sut.cardTypeProvider = cardTypeProviderMock
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
            XCTAssertEqual(value, "370000")
            expectationBin.fulfill()
        }, onCardTypeChange: { value in
            XCTAssertEqual(value, [CardType.americanExpress])
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
                                clientKey: "test_client_key")
        sut.showsLargeTitle = false
        
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
                                clientKey: "test_client_key",
                                style: style)
        sut.showsLargeTitle = false
        
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
                                clientKey: "test_client_key",
                                style: style)
        sut.showsLargeTitle = false
        
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
                                clientKey: "test_client_key")

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.success("key"))
        }
        sut.cardPublicKeyProvider = cardPublicKeyProvider

        sut.viewDidLoad(formViewController: sut.formViewController)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testStoredCardPayment() {
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
                                clientKey: "test_client_key")
        XCTAssertNotNil(sut.viewController as? UIAlertController)
        XCTAssertNotNil(sut.storedCardComponent)
    }

    func testShouldShow4CardTypesOnInit() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc", "cup", "maestro", "jcb"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: "test_client_key")
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
            XCTAssertEqual(cardLogoView.arrangedSubviews.filter{ !$0.isHidden }.count, 4)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 8)
    }

    func testShouldShowNoCardTypesOnInvalidPANEnter() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: "test_client_key")
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
                XCTAssertTrue(cardLogoView.arrangedSubviews.allSatisfy { $0.isHidden })

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 8)
    }

    func testShouldShowCardTypesOnPANEnter() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["visa", "amex", "mc"])
        let sut = CardComponent(paymentMethod: method,
                                clientKey: "test_client_key")
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
                XCTAssertEqual(cardLogoView.arrangedSubviews.filter{ !$0.isHidden }.count, 1)

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 8)
    }
    
    private func focus<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U) {
        textItemView.textField.becomeFirstResponder()
    }
    
    private func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }
}
