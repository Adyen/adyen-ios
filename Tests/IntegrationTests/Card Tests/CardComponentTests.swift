//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
import XCTest

class CardComponentTests: XCTestCase {

    var context: AdyenContext {
        Dummy.context
    }

    var payment: Payment {
        Dummy.payment
    }
    
    var method: CardPaymentMethod {
        .init(
            type: .bcmc,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
    }
    
    var storedMethod: StoredCardPaymentMethod {
        .init(
            type: .card,
            name: "Test name",
            identifier: "id",
            fundingSource: .credit,
            supportedShopperInteractions: [.shopperPresent],
            brand: .visa,
            lastFour: "1234",
            expiryMonth: "12",
            expiryYear: "22",
            holderName: "holderName"
        )
    }
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func test_cardViewController_shouldRequireKeyboardInput() throws {
        // Given
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        // When
        sut.viewController.loadViewIfNeeded()

        // Then
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<CardViewController>)
        let cardViewController = securedViewController.childViewController
        XCTAssertTrue(cardViewController.requiresKeyboardInput)
    }

    func test_formItems_withCustomTableName_shouldUseLocalizedStrings() {

        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        let items = sut.cardViewController.items

        XCTAssertEqual(items.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(items.expiryDateItem.placeholder, localizedString(.cardExpiryItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(items.expiryDateItem.validationFailureMessage, localizedString(.cardExpiryItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(items.securityCodeItem.title, localizedString(.cardCvcItemTitle, sut.configuration.localizationParameters))
        XCTAssertNil(items.securityCodeItem.placeholder)
        XCTAssertEqual(items.securityCodeItem.validationFailureMessage, localizedString(.cardCvcItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(items.holderNameItem.title, localizedString(.cardNameItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(items.holderNameItem.placeholder, localizedString(.cardNameItemPlaceholder, sut.configuration.localizationParameters))
        XCTAssertEqual(items.holderNameItem.validationFailureMessage, localizedString(.cardNameItemInvalid, sut.configuration.localizationParameters))

        XCTAssertEqual(items.storeDetailsItem.title, localizedString(.cardStoreDetailsButton, sut.configuration.localizationParameters))

        XCTAssertEqual(items.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func test_formItems_withCustomKeySeparator_shouldUseLocalizedStrings() {
        
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        let items = sut.cardViewController.items
        XCTAssertEqual(items.expiryDateItem.title, localizedString(.cardExpiryItemTitle, nil))
        XCTAssertEqual(items.expiryDateItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_expiryItem_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(items.expiryDateItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_expiryItem_invalid"), sut.configuration.localizationParameters))

        XCTAssertEqual(items.securityCodeItem.title, localizedString(LocalizationKey(key: "adyen_card_cvcItem_title"), sut.configuration.localizationParameters))
        XCTAssertNil(items.securityCodeItem.placeholder)
        XCTAssertEqual(items.securityCodeItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_cvcItem_invalid"), sut.configuration.localizationParameters))

        XCTAssertEqual(items.holderNameItem.title, localizedString(LocalizationKey(key: "adyen_card_nameItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(items.holderNameItem.placeholder, localizedString(LocalizationKey(key: "adyen_card_nameItem_placeholder"), sut.configuration.localizationParameters))
        XCTAssertEqual(items.holderNameItem.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_nameItem_invalid"), sut.configuration.localizationParameters))

        XCTAssertEqual(items.storeDetailsItem.title, localizedString(LocalizationKey(key: "adyen_card_storeDetailsButton"), sut.configuration.localizationParameters))

        XCTAssertEqual(items.button.title, localizedSubmitButtonTitle(with: payment.amount, style: .immediate, sut.configuration.localizationParameters))
    }

    func test_component_withCustomTheme_shouldApplyThemeStyles() {
        // Given - custom theme with distinctive colors and button styling
        let colorToTest = UIColor.blue
        let customColors = AdyenColors(
            container: .yellow,
            containerOutline: .purple,
            primary: colorToTest,
            highlight: .blue
        )
        
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.showsStorePaymentMethodField = true
        configuration.theme = AdyenTheme(colors: customColors)
            .primaryButton(backgroundColor: .red, textColor: .white, cornerRadius: 12)
            .cornerRadius(8)

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // MARK: - Test 1: Semantic Primary Color Applied to All Text Fields
        
        // Card number field
        let cardNumberItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.titleLabel")
        let cardNumberItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.textField")
        let cardNumberItemContainer: UIView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        
        XCTAssertEqual(cardNumberItemTitleLabel?.textColor, colorToTest, "Card number title should use theme primary color")
        XCTAssertEqual(cardNumberItemTextField?.textColor, colorToTest, "Card number text should use theme primary color")
        
        // Holder name field
        let holderNameItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.titleLabel")
        let holderNameItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem.textField")
        let holderNameItemContainer: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
        
        XCTAssertEqual(holderNameItemTitleLabel?.textColor, colorToTest, "Holder name title should use theme primary color")
        XCTAssertEqual(holderNameItemTextField?.textColor, colorToTest, "Holder name text should use theme primary color")
        
        // Expiry date field
        let expiryDateItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.titleLabel")
        let expiryDateItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem.textField")
        let expiryDateItemContainer: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        
        XCTAssertEqual(expiryDateItemTitleLabel?.textColor, colorToTest, "Expiry date title should use theme primary color")
        XCTAssertEqual(expiryDateItemTextField?.textColor, colorToTest, "Expiry date text should use theme primary color")
        
        // Security code field
        let securityCodeItemTitleLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.titleLabel")
        let securityCodeItemTextField: UITextField? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.textField")
        let securityCodeItemContainer: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        let securityCodeCvvHint: UIView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")
        
        XCTAssertEqual(securityCodeItemTitleLabel?.textColor, colorToTest, "Security code title should use theme primary color")
        XCTAssertEqual(securityCodeItemTextField?.textColor, colorToTest, "Security code text should use theme primary color")
        XCTAssertNotNil(securityCodeCvvHint, "CVV hint should be present")
        
        // MARK: - Test 2: Containers Exist and Are Styled
        
        // Verify containers exist (background colors will be implemented in later migration phases)
        XCTAssertNotNil(cardNumberItemContainer, "Card number container should exist")
        XCTAssertNotNil(holderNameItemContainer, "Holder name container should exist")
        XCTAssertNotNil(expiryDateItemContainer, "Expiry date container should exist")
        XCTAssertNotNil(securityCodeItemContainer, "Security code container should exist")
        
        // MARK: - Test 3: Pay Button Uses Theme
        
        let payButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button")
        let payButtonTitle: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.payButtonItem.button.titleLabel")
        
        XCTAssertNotNil(payButton, "Pay button should exist")
        XCTAssertEqual(payButton?.backgroundColor, .red, "Pay button should use theme button background color")
        XCTAssertEqual(payButtonTitle?.textColor, .white, "Pay button title should use theme button text color")
        
        // Verify button corner radius
        if let payButton {
            XCTAssertEqual(payButton.layer.cornerRadius, 12, accuracy: 0.1, "Pay button should use theme corner radius")
        }
        
        // MARK: - Test 4: Store Details Toggle Present
        
        let storeDetailsToggle: UISwitch? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem.switch")
        XCTAssertNotNil(storeDetailsToggle, "Store details toggle should be present when configured")
    }

    func test_viewController_shouldNotShowBigTitle() {

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, method.name)
    }

    func test_securityCodeField_whenConfiguredToHide_shouldNotBeVisible() {
        var configuration = CardComponentConfiguration()
        configuration.showsSecurityCodeField = false
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)
        
        let securityCodeView: FormCardSecurityCodeItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

        XCTAssertNil(securityCodeView)
    }

    func test_securityCodeField_shouldBeVisibleByDefault() {

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)
        
        let securityCodeView: FormCardSecurityCodeItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

        XCTAssertNotNil(securityCodeView)
    }

    func test_securityCodeHint_whenCardNumberChanges_shouldUpdateHint() {

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)
        
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let securityCodeCvvHint: FormCardSecurityCodeItemView.HintView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")

        XCTAssertNotNil(securityCodeCvvHint)
        XCTAssertFalse(securityCodeCvvHint!.showFront)
        XCTAssertEqual(securityCodeItemView?.footerLabel.text, "3 digits")

        self.populate(textItemView: cardNumberItemView!, with: "370000")
        XCTAssertTrue(securityCodeCvvHint!.showFront)
        XCTAssertEqual(securityCodeItemView?.footerLabel.text, "4 digits")

    }

    func test_onBinChangeAndOnBinLookup_whenCardNumberEntered_shouldBeCalledWithCorrectValues() {
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .americanExpress)]))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration(),
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )

        setupRootViewController(sut.viewController)

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        
        sut.configuration = sut.configuration
            .onBinChange { value in
                XCTAssertEqual(value, "371449")
                expectationBin.fulfill()
            }
            .onBinLookup { value in
                XCTAssertEqual(value, [CardBrand(type: .americanExpress)])
                expectationCardType.fulfill()
            }
        
        self.fillCard(on: sut.viewController.view, with: Dummy.amexCard)
        self.tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin, expectationCardType], timeout: 10)
    }
    
    func test_billingAddress_withPrefillData_shouldShowPrefilledAddress() throws {
        
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .lookup(
            onAddressLookup: { searchTerm in
                XCTFail("Lookup handler should not be called")
                return []
            }
        )
        configuration.shopperInformation = shopperInformation

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // When
        
        setupRootViewController(component.viewController)

        // Then
        let view: UIView = component.cardViewController.view

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
        
        billingAddressView.item.selectionHandler()
        
        try waitForViewController(
            ofType: AddressLookupViewController.self,
            toBecomeChildOf: UIViewController.topPresenter()
        )
    }

    func test_securityCodeFormatter_whenCardTypeChanges_shouldUpdateMaxLength() {
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)
        
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let securityCodeCvvHint: FormCardSecurityCodeItemView.HintView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem.cvvHintIcon")

        XCTAssertNotNil(securityCodeCvvHint)
        self.populate(textItemView: securityCodeItemView!, with: "12345")
        XCTAssertEqual(securityCodeItemView!.textField.text, "123")

        self.populate(textItemView: cardNumberItemView!, with: "370000")
        self.populate(textItemView: securityCodeItemView!, with: "12345")
        XCTAssertEqual(securityCodeItemView!.textField.text, "1234")

    }

    func test_formFields_withCustomTintColor_shouldApplyTintColor() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("This test is flaky on macos-12 runners that are needed to test on older iOS versions - so we skip it")
        }
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("This test is flaky on iOS 26 beta so far - so we skip it")
        }

        var configuration = CardComponentConfiguration()

        let tintColor: UIColor = .black
        let titleColor: UIColor = .gray

        configuration.style = {
            var style = FormComponentStyle(tintColor: tintColor)
            style.textField.title.color = titleColor
            return style
        }()

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        presentOnRoot(component.viewController)

        let switchView: UISwitch = try XCTUnwrap(component.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem.switch"))
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem> = try XCTUnwrap(component.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))

        XCTAssertEqual(switchView.onTintColor, tintColor)
        XCTAssertEqual(securityCodeItemView.titleLabel.textColor, titleColor)

        try withoutAnimation {
            focus(textItemView: securityCodeItemView)
        }

        XCTAssertEqual(securityCodeItemView.titleLabel.textColor, tintColor)
    }

    // TODO: Fix Later
//    func testSuccessTintColorCustomization() throws {
//        // Given
//        var style = FormComponentStyle(tintColor: .systemYellow)
//        style.textField.title.color = .gray
//        var configuration = CardComponentConfiguration()
//        configuration.style = style
//        let sut = CardComponent(
//            paymentMethod: method,
//            context: context,
//            configuration: configuration
//        )
//
//        // When
//        setupRootViewController(sut.viewController)
//
//        // Then
//        let view: UIView = sut.viewController.view
//
//        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
//
//       XCTAssertEqual(securityCodeItemView.titleLabel.textColor, .gray)
//
//        populate(textItemView: securityCodeItemView, with: "123")
//
//        wait(until: securityCodeItemView, at: \.cardHintView.tintColor, is: .systemYellow)
//    }

    func test_viewDidLoad_shouldTriggerPublicKeyFetch() {
        let publicKeyProviderExpectation = expectation(description: "Expect publicKeyProvider to be called.")
        let publicKeyProvider = PublicKeyProviderMock()
        publicKeyProvider.onFetch = { completion in
            publicKeyProviderExpectation.fulfill()
            completion(.success("key"))
        }
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration(),
            publicKeyProvider: publicKeyProvider,
            binProvider: BinInfoProviderMock()
        )

        sut.viewDidLoad(viewController: sut.cardViewController)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_storedCard_withNoPaymentAmount_shouldShowGenericPayButton() {
        let context = Dummy.context(with: nil)
        let sut = CardComponent(
            paymentMethod: storedMethod,
            context: context
        )
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay")
    }

    func test_storedCard_withPaymentAmount_shouldShowAmountInPayButton() throws {
        let sut = CardComponent(
            paymentMethod: storedMethod,
            context: context
        )
        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Pay €1.00")
    }

    func test_storedCard_withCustomLocalization_shouldUseLocalizedStrings() throws {
        var configuration = CardComponentConfiguration()
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = CardComponent(
            paymentMethod: storedMethod,
            context: context,
            configuration: configuration
        )

        XCTAssertNotNil(sut.storedCardComponent)
        XCTAssertNotNil(sut.storedCardComponent as? StoredCardComponent)
        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
        let vc = sut.viewController as? UIAlertController
        XCTAssertEqual(vc?.message, "Test-Please enter the CVC code for •••• 1234")
        XCTAssertEqual(vc?.title, "Test-Verify your card")
        XCTAssertEqual(vc?.actions[0].title, "Test-Cancel")
        XCTAssertEqual(vc?.actions[1].title, "Test-Pay €1.00")
    }

    // TODO: FIX ME
//    func testStoredCardPaymentLocalizationWithNoCVV() throws {
//        var configuration = CardComponentConfiguration()
//        configuration.stored.showsSecurityCodeField = false
//        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
//        let sut = CardComponent(
//            paymentMethod: storedMethod,
//            context: context,
//            configuration: configuration
//        )
//
//        XCTAssertNotNil(sut.storedCardComponent)
//        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
//        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
//        let vc = sut.viewController as? UIAlertController
//        XCTAssertEqual(vc?.message, "•••• 1234")
//        XCTAssertEqual(vc?.title, "Test-Confirm Test name payment")
//        XCTAssertEqual(vc?.actions[0].title, "Test-Cancel")
//        XCTAssertEqual(vc?.actions[1].title, "Test-Pay €1.00")
//    }

//    func testStoredCardPaymentWithNoCVV() throws {
//        var configuration = CardComponentConfiguration()
//        configuration.stored.showsSecurityCodeField = false
//        let sut = CardComponent(
//            paymentMethod: storedMethod,
//            context: context,
//            configuration: configuration
//        )
//
//        XCTAssertNotNil(sut.storedCardComponent)
//        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
//        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
//        let vc = sut.viewController as? UIAlertController
//        XCTAssertEqual(vc?.message, "•••• 1234")
//        XCTAssertEqual(vc?.title, "Confirm Test name payment")
//        XCTAssertEqual(vc?.actions[0].title, "Cancel")
//        XCTAssertEqual(vc?.actions[1].title, "Pay €1.00")
//    }

//    func testStoredCardPaymentWithNoCVVAndNoPayment() {
//        var configuration = CardComponentConfiguration()
//        configuration.stored.showsSecurityCodeField = false
//        let context = Dummy.context(with: nil)
//        let sut = CardComponent(
//            paymentMethod: storedMethod,
//            context: context,
//            configuration: configuration
//        )
//        XCTAssertNotNil(sut.storedCardComponent)
//        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
//        XCTAssertTrue(sut.storedCardComponent?.viewController is UIAlertController)
//        let vc = sut.viewController as? UIAlertController
//        XCTAssertEqual(vc?.message, "•••• 1234")
//        XCTAssertEqual(vc?.title, "Confirm Test name payment")
//        XCTAssertEqual(vc?.actions[0].title, "Cancel")
//        XCTAssertEqual(vc?.actions[1].title, "Pay")
//    }
//
//    func testOneClickPayment() {
//        var configuration = CardComponentConfiguration()
//        configuration.stored.showsSecurityCodeField = false
//        let sut = CardComponent(
//            paymentMethod: storedMethod,
//            context: context,
//            configuration: configuration
//        )
//        XCTAssertNotNil(sut.viewController as? UIAlertController)
//        XCTAssertNotNil(sut.storedCardComponent)
//        XCTAssertNotNil(sut.storedCardComponent as? StoredPaymentMethodComponent)
//    }

    func test_cardLogos_onInit_shouldShowUpTo4CardTypes() {
        // Given
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.visa, .americanExpress, .masterCard, .maestro, .jcb, .chinaUnionPay])
        let sut = CardComponent(
            paymentMethod: method,
            context: context
        )
        setupRootViewController(sut.viewController)

        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(textItemView)
        let cardLogoView = cardNumberItemView!.detectedBrandsView
        XCTAssertNotNil(cardLogoView)
        let cardNumberItem = cardNumberItemView!.item
        
        XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 6)
        XCTAssertFalse(cardLogoView.primaryLogoView.isHidden)
        XCTAssertTrue(cardLogoView.secondaryLogoView.isHidden)
    }

    func test_cardLogos_whenPANEntered_shouldUpdateVisibleLogos() throws {
        // Given

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)

        let cardNumberItemView: FormCardNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        let cardLogoView = cardNumberItemView.detectedBrandsView
        let cardNumberItem = cardNumberItemView.item
        
        self.populate(textItemView: cardNumberItemView, with: "3400")
        
        wait(until: cardNumberItem, at: \.cardTypeLogos.count, is: 3)
        wait(until: cardLogoView, at: \.primaryLogoView.isHidden, is: false)
        wait(until: cardLogoView, at: \.secondaryLogoView.isHidden, is: true)
    }

    func test_submit_withValidData_shouldCallDelegateWithPaymentData() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        let sut = CardComponent(
            paymentMethod: method,
            context: Dummy.context(with: nil),
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: BinInfoProviderMock()
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        setupRootViewController(sut.viewController)

        let expectedVerificationAddress = PostalAddressMocks.newYorkPostalAddress

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        let finalizationExpectation = expectation(description: "Component should finalize.")
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

            sut.finalizeIfNeeded(with: true, completion: {
                finalizationExpectation.fulfill()
            })
            delegateExpectation.fulfill()

            XCTAssertEqual(sut.cardViewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.cardViewController.items.button.showsActivityIndicator, false)
        }

        let view: UIView = sut.viewController.view

        fillCard(on: view, with: Dummy.visaCard)

        let storeDetailsItemView: FormToggleItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        storeDetailsItemView.accessibilityActivate()

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: "AdyenCard.CardComponent.billingAddress"))
        billingAddressView.item.value = expectedVerificationAddress

        tapSubmitButton(on: view)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_cardNumberField_whenComplete_shouldPassFocusToExpiryDate() throws {
        // Given

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        setupRootViewController(sut.viewController)

        let cardNumberItemView: FormCardNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        let expiryDateItemView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))

        // no focus change without panglength till max (19)
        
        var newResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView.becomeFirstResponder()
        
        XCTAssertTrue(cardNumberItemView.isFirstResponder)
        
        populate(textItemView: cardNumberItemView, with: Dummy.amexCard.number!)
        
        wait(until: expiryDateItemView, at: \.isFirstResponder, is: false)
        wait(until: cardNumberItemView, at: \.isFirstResponder, is: true)
        
        // focus should change with pan length set
        newResponse = BinLookupResponse(brands: [CardBrand(type: .americanExpress, panLength: 15)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView.becomeFirstResponder()
        
        wait(until: cardNumberItemView, at: \.isFirstResponder, is: true)
        
        populate(textItemView: cardNumberItemView, with: Dummy.amexCard.number!)
        
        wait(until: cardNumberItemView, at: \.isFirstResponder, is: false)
        wait(until: expiryDateItemView, at: \.isFirstResponder, is: true)

        // focus should also change when reaching default max length 19
        newResponse = BinLookupResponse(brands: [CardBrand(type: .maestro)])
        sut.cardViewController.update(binInfo: newResponse)
        cardNumberItemView.becomeFirstResponder()
        
        wait(until: cardNumberItemView, at: \.isFirstResponder, is: true)
        
        populate(textItemView: cardNumberItemView, with: "6771830000000000006")
        
        wait(until: cardNumberItemView, at: \.isFirstResponder, is: false)
        wait(until: expiryDateItemView, at: \.isFirstResponder, is: true)
    }

    func test_expiryDateField_whenComplete_shouldPassFocusToSecurityCode() throws {
        // Given
        
        let configuration = CardComponentConfiguration()
        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        let viewController = component.viewController
        
        setupRootViewController(component.viewController)
        
        let view: UIView = viewController.view
        let expiryDateItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem> = try XCTUnwrap(view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
        
        expiryDateItemView.becomeFirstResponder()
        self.append(textItemView: expiryDateItemView, with: "3")
        
        wait(until: expiryDateItemView, at: \.textField.isFirstResponder, is: true)
        
        self.append(textItemView: expiryDateItemView, with: "3")
        self.append(textItemView: expiryDateItemView, with: "0")
        
        wait(until: expiryDateItemView, at: \.textField.isFirstResponder, is: false)
        XCTAssertTrue(securityCodeItemView.textField.isFirstResponder)
    }

    func test_postalCodeField_withPostalCodeMode_shouldBeVisibleAndValidate() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: BinInfoProviderMock()
        )
        setupRootViewController(sut.viewController)

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

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        self.fillCard(on: sut.viewController.view, with: Dummy.visaCard)

        let postalCodeItemView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem"))
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertFalse(postalCodeItemView.isShowingValidationError)
        
        self.populate(textItemView: postalCodeItemView, with: "12345")

        self.tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10)
    }

    func test_KCPFields_whenKoreanCard_shouldShowTaxAndPasswordFields() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.koreanAuthenticationMode = .auto
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .koreanLocalCard)],
                issuingCountryCode: "KR"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let paymentDetails = data.paymentMethod as? CardDetails
            XCTAssertNotNil(paymentDetails)

            XCTAssertNotEqual(paymentDetails?.password, "12")
            XCTAssertTrue(paymentDetails!.password!.starts(with: "eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwidmVyc2lvbiI6IjEifQ"))
            XCTAssertEqual(paymentDetails?.taxNumber, "121212")

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        let taxNumberItemView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthCodeItem"))
        let passwordItemView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthPasswordItem"))
        
        wait(until: taxNumberItemView, at: \.isHidden, is: true)
        wait(until: passwordItemView, at: \.isHidden, is: true)

        self.fillCard(on: sut.viewController.view, with: Dummy.kcpCard)

        wait(until: taxNumberItemView, at: \.titleLabel.text, is: "Birthdate or Corporate registration number")
        wait(until: taxNumberItemView, at: \.isHidden, is: false)
        
        wait(until: passwordItemView, at: \.titleLabel.text, is: "First 2 digits of card password")
        wait(until: passwordItemView, at: \.isHidden, is: false)

        self.populate(textItemView: taxNumberItemView, with: "121212")
        self.populate(textItemView: passwordItemView, with: "12")

        self.tapSubmitButton(on: sut.viewController.view)
        
        waitForExpectations(timeout: 10)
    }

    func test_brazilSSNField_withAutoMode_shouldShowBasedOnBinResponse() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.socialSecurityNumberMode = .auto
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .elo, showSocialSecurityNumber: true)],
                issuingCountryCode: "BR"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let paymentDetails = data.paymentMethod as? CardDetails
            XCTAssertNotNil(paymentDetails)
            XCTAssertEqual(paymentDetails?.socialSecurityNumber, "12312312312")

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        let brazilSSNItemView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem"))
        XCTAssertTrue(brazilSSNItemView.isHidden)

        fillCard(on: sut.viewController.view, with: Dummy.visaCard)

        wait(until: brazilSSNItemView, at: \.titleLabel.text, is: "CPF/CNPJ")
        wait(until: brazilSSNItemView, at: \.isHidden, is: false)
        
        populate(textItemView: brazilSSNItemView, with: "123.123.123-12")

        tapSubmitButton(on: sut.viewController.view)
        
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: false)])
        sut.cardViewController.update(binInfo: newResponse)

        wait(until: brazilSSNItemView, at: \.isHidden, is: true)

        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func test_brazilSSNField_withHideMode_shouldNotBeVisible() {
        var configuration = CardComponentConfiguration()
        configuration.socialSecurityNumberMode = .hide

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        
        let brazilSSNItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem")
        XCTAssertNil(brazilSSNItemView)
        
        // config is always hide, so item is not added to view
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: true)])
        sut.cardViewController.update(binInfo: newResponse)
        
        XCTAssertNil(brazilSSNItemView)
    }
    
    func test_brazilSSNField_withShowMode_shouldAlwaysBeVisible() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.visa, .americanExpress, .masterCard, .elo])

        var configuration = CardComponentConfiguration()
        configuration.socialSecurityNumberMode = .show

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        
        let brazilSSNItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem")
        XCTAssertFalse(brazilSSNItemView!.isHidden)
        
        // config is always show, so bin response is ignored
        let newResponse = BinLookupResponse(brands: [CardBrand(type: .elo, showSocialSecurityNumber: false)])
        sut.cardViewController.update(binInfo: newResponse)
        
        XCTAssertFalse(brazilSSNItemView!.isHidden)
    }

    func test_cardNumberValidation_withLuhnCheckEnabled_shouldValidateChecksum() {
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        let brands = [
            CardBrand(type: .visa, isLuhnCheckEnabled: true),
            CardBrand(type: .masterCard, isLuhnCheckEnabled: false)
        ]
        
        let cardNumberItem = sut.cardViewController.items.numberContainerItem.numberItem
        cardNumberItem.update(brands: brands)
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertFalse(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())

        cardNumberItem.selectBrand(cardBrand: brands.last!)
        XCTAssertTrue(cardNumberItem.isValid())
        cardNumberItem.value = "4111 1111 1111"
        XCTAssertTrue(cardNumberItem.isValid())
    }
    
    func test_cardLogos_whenValidCardEntered_shouldHideSupportedLogos() throws {

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        XCTAssertTrue(sut.cardViewController.items.numberContainerItem.showsSupportedCardLogos)
        
        setupRootViewController(sut.viewController)
        
        let supportedCardLogosItemId = "AdyenCard.CardComponent.numberContainerItem.supportedCardLogosItem"
        
        let supportedCardLogosItem: FormCardLogosItemView = try XCTUnwrap(sut.viewController.view.findView(with: supportedCardLogosItemId))
        XCTAssertFalse(supportedCardLogosItem.isHidden)
        
        // Valid input
        
        fillCard(on: sut.viewController.view, with: Dummy.visaCard)
        
        let binResponse = BinLookupResponse(brands: [CardBrand(type: .visa, isSupported: true)])
        sut.cardViewController.update(binInfo: binResponse)

        wait(until: supportedCardLogosItem, at: \.isHidden, is: true)
    }

    func test_securityCodeField_withDifferentCVCPolicies_shouldUpdateDisplayMode() {
        let brands = [
            CardBrand(type: .visa, cvcPolicy: .required),
            CardBrand(type: .americanExpress, cvcPolicy: .optional),
            CardBrand(type: .masterCard, cvcPolicy: .hidden)
        ]

        let method = CardPaymentMethod(
            type: .card,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
        let config = CardComponentConfiguration()
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: config
        )

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

    func test_expiryDateField_withDifferentPolicies_shouldUpdateOptionality() {
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        let brands = [
            CardBrand(type: .visa, expiryDatePolicy: .required),
            CardBrand(type: .americanExpress, expiryDatePolicy: .optional),
            CardBrand(type: .masterCard, expiryDatePolicy: .hidden)
        ]
        
        let expDateItem = sut.cardViewController.items.expiryDateItem
        expDateItem.value = ""
        expDateItem.isOptional = brands[0].isExpiryDateOptional
        // mixed means non option, valid value must be entered
        XCTAssertFalse(expDateItem.isValid())
        expDateItem.value = "1"
        XCTAssertFalse(expDateItem.isValid())
        XCTAssertEqual(sut.cardViewController.card.expiryYear, "20")
        XCTAssertEqual(sut.cardViewController.card.expiryMonth, "1")
        expDateItem.value = "0234"
        XCTAssertTrue(expDateItem.isValid())
        XCTAssertEqual(sut.cardViewController.card.expiryYear, "2034")
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
    
    func test_installments_shouldEncodeCorrectly() throws {
        
        let installments = Installments(totalMonths: 12, plan: .regular)
        
        let installmentsData = try JSONEncoder().encode(installments)
        let decodedInstallments = try XCTUnwrap(JSONSerialization.jsonObject(with: installmentsData) as? [String: Any])
        
        XCTAssertEqual(decodedInstallments["value"] as? Int, installments.totalMonths)
        XCTAssertEqual(decodedInstallments["plan"] as? String, installments.plan.rawValue)
    }
    
    func test_installmentsField_withDefaultAndCardBasedOptions_shouldShowCorrectOptions() {
        let cardBasedInstallmentOptions: [CardType: InstallmentOptions] = [
            .visa:
                InstallmentOptions(maxInstallmentMonth: 8, includesRevolving: true)
        ]
        let defaultInstallmentOptions = InstallmentOptions(monthValues: [3, 6, 9, 12], includesRevolving: false)

        var configuration = CardComponentConfiguration()
        configuration.installmentConfiguration = InstallmentConfiguration(
            cardBasedOptions: cardBasedInstallmentOptions,
            defaultOptions: defaultInstallmentOptions
        )
        let cardTypeProviderMock = BinInfoProviderMock()

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)
        
        let installmentItemView: BaseFormPickerItemView<InstallmentElement>? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
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
    
    func test_installmentsField_withDefaultOptions_shouldShowDefaultOptions() {
        let defaultInstallmentOptions = InstallmentOptions(monthValues: [3, 6, 9, 12], includesRevolving: false)
        var configuration = CardComponentConfiguration()
        configuration.installmentConfiguration = InstallmentConfiguration(defaultOptions: defaultInstallmentOptions)
        let cardTypeProviderMock = BinInfoProviderMock()

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)
        
        let installmentItemView: BaseFormPickerItemView<InstallmentElement>? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
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

    func test_installmentsField_withCardBasedOptions_shouldShowCardSpecificOptions() {
        let cardBasedInstallmentOptions: [CardType: InstallmentOptions] = [
            .visa:
                InstallmentOptions(maxInstallmentMonth: 8, includesRevolving: true)
        ]
        var configuration = CardComponentConfiguration()
        configuration.installmentConfiguration = InstallmentConfiguration(cardBasedOptions: cardBasedInstallmentOptions)
        let cardTypeProviderMock = BinInfoProviderMock()

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)
        
        let installmentItemView: BaseFormPickerItemView<InstallmentElement>? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
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
    
    func test_installmentsField_withAmountShown_shouldDisplayInstallmentAmounts() {
        let cardBasedInstallmentOptions: [CardType: InstallmentOptions] = [
            .visa:
                InstallmentOptions(maxInstallmentMonth: 8, includesRevolving: true)
        ]

        var configuration = CardComponentConfiguration()
        configuration.installmentConfiguration = InstallmentConfiguration(cardBasedOptions: cardBasedInstallmentOptions, showInstallmentAmount: true)
        let cardTypeProviderMock = BinInfoProviderMock()

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        setupRootViewController(sut.viewController)
        
        let installmentItemView: BaseFormPickerItemView<InstallmentElement>? = sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.installmentsItem")
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
        XCTAssertEqual(installmentItemView!.inputControl.label, "2x €0.50")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[3])
        XCTAssertEqual(installmentItemView!.inputControl.label, "3x €0.33")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        installmentItemView?.select(value: sut.cardViewController.items.installmentsItem!.selectableValues[4])
        XCTAssertEqual(installmentItemView!.inputControl.label, "4x €0.25")
        XCTAssertNotNil(sut.cardViewController.installments)
        
        // nil card type means no options since there is no default option
        sut.cardViewController.items.installmentsItem?.update(cardType: nil)
        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.selectableValues.count, 1)
        XCTAssertFalse(installmentItemView!.isHidden)
        XCTAssertEqual(installmentItemView!.inputControl.label, "One time payment")
    }
    
    func test_supportedCardLogos_whenFieldActiveOrInactive_shouldUpdateVisibility() throws {

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        setupRootViewController(sut.viewController)
        
        let numberItem = sut.cardViewController.items.numberContainerItem.numberItem
        
        let cardNumberItemView: FormCardNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        let logoItemView: FormCardLogosItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberContainerItem.supportedCardLogosItem"))

        XCTAssertFalse(logoItemView.isHidden)

        // valid card but still active. logos should be hidden
        numberItem.isActive = true
        populate(textItemView: cardNumberItemView, with: Dummy.visaCard.number!)
        wait(until: logoItemView, at: \.isHidden, is: true)

        // with valid card and inactive, logos should still be hidden
        numberItem.isActive = false
        wait(for: .aMoment)
        XCTAssertTrue(logoItemView.isHidden)

        // invalid card and active/inactive numberitem, logos should be visible
        numberItem.isActive = true
        populate(textItemView: cardNumberItemView, with: "1234")
        wait(until: logoItemView, at: \.isHidden, is: false)
        
        numberItem.isActive = false
        wait(for: .aMoment) // Logo item view should still be hidden after waiting a bit
        XCTAssertFalse(logoItemView.isHidden)
    }

    func test_coBadgedCardsUI_forEUCard_shouldBeVisible() throws {
        // Given

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        sut.viewController.loadViewIfNeeded()

        let newResponse = BinLookupResponse(brands: [CardBrand(type: .visa), CardBrand(type: .carteBancaire)], issuingCountryCode: "FR", isCreatedLocally: false)

        sut.cardViewController.showCoBadgedCardsUI(for: newResponse.brands!)

        wait(for: .aMoment)

        // Then
        XCTAssertFalse(sut.cardViewController.items.coBadgedCardItem.isHidden.wrappedValue)
    }

    func test_coBadgedCardsUI_forAUCard_shouldBeHidden() throws {
        // Given

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        sut.viewController.loadViewIfNeeded()

        let newResponse = BinLookupResponse(brands: [CardBrand(type: .masterCard), CardBrand(type: .other(named: "eftpos_australia"))], issuingCountryCode: "AU", isCreatedLocally: false)

        sut.cardViewController.showCoBadgedCardsUI(for: newResponse.brands!)

        wait(for: .aMoment)

        // Then
        XCTAssertTrue(sut.cardViewController.items.coBadgedCardItem.isHidden.wrappedValue)
    }

    func test_coBadgedCardsUI_shouldShowCorrectBrandNames() throws {
        // Given

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        sut.viewController.loadViewIfNeeded()

        let newResponse = BinLookupResponse(
            brands: [
                CardBrand(
                    type: .bcmc,
                    localeBrand: "Bancontact card"
                ),
                CardBrand(
                    type: .maestro,
                    localeBrand: nil
                )
            ],
            issuingCountryCode: "BE",
            isCreatedLocally: false
        )

        sut.cardViewController.update(binInfo: newResponse)

        wait(for: .aMoment)

        // Then
        XCTAssertFalse(sut.cardViewController.items.coBadgedCardItem.isHidden.wrappedValue)
        XCTAssertEqual(sut.cardViewController.items.coBadgedCardItem.selectableFormItems[0].title, newResponse.brands?[0].localeBrand)
        XCTAssertEqual(sut.cardViewController.items.coBadgedCardItem.selectableFormItems[1].title, newResponse.brands?[1].type.rawValue)
    }

    func test_coBadgedCardsUI_whenDisplayed_shouldSendAnalyticsInfo() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        let brands = [CardBrand(type: .visa), CardBrand(type: .carteBancaire)]
        sut.viewController.loadViewIfNeeded()

        sut.cardViewController.items.coBadgedCardItem.updatedCardBrands = brands
        let dualBrandDisplayedCalled = analyticsProviderMock.infos.filter { $0.type == .displayed }.first
        XCTAssertNotNil(dualBrandDisplayedCalled)
        XCTAssertEqual(dualBrandDisplayedCalled?.target, .dualBrandButton)
        XCTAssertNotNil(dualBrandDisplayedCalled?.configData)
        XCTAssertNotNil(dualBrandDisplayedCalled?.brand)
    }

    func test_coBadgedCardsUI_whenSelected_shouldSendAnalyticsInfo() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            analyticsProvider: analyticsProviderMock
        )
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        setupRootViewController(sut.viewController)

        let newResponse = BinLookupResponse(brands: [CardBrand(type: .visa), CardBrand(type: .carteBancaire)], issuingCountryCode: "FR", isCreatedLocally: false)

        sut.cardViewController.update(binInfo: newResponse)
        sut.cardViewController.items.coBadgedCardItem.selectableFormItems.first?.selectionHandler?()

        wait(for: .aMoment)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        let dualBrandSelectedCalled = analyticsProviderMock.infos.filter { $0.type == .selected }.first
        XCTAssertNotNil(dualBrandSelectedCalled)
        XCTAssertEqual(dualBrandSelectedCalled?.brand, newResponse.brands?.first?.type.rawValue)
        XCTAssertEqual(dualBrandSelectedCalled?.target, .dualBrandButton)
        XCTAssertNil(dualBrandSelectedCalled?.configData)
    }

    func test_storePaymentMethodField_shouldUpdateVisibilityBasedOnBinResponse() throws {
        
        // Given
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )

        let cardViewController = sut.cardViewController
        
        // Field should be visible and disabled by default
        
        XCTAssertFalse(cardViewController.items.storeDetailsItem.value)
        XCTAssertTrue(cardViewController.items.storeDetailsItem.isVisible)
        
        // Enable storing when field visible
        
        sut.update(storePaymentMethodFieldValue: true)
        XCTAssertTrue(cardViewController.items.storeDetailsItem.value)
        
        // Hiding field should disable storing
        
        sut.update(storePaymentMethodFieldVisibility: false)
        XCTAssertFalse(cardViewController.items.storeDetailsItem.isVisible)
        XCTAssertFalse(cardViewController.items.storeDetailsItem.value)
        
        // Enabling storing while field is hidden should be ignored
        
        sut.update(storePaymentMethodFieldValue: true)
        XCTAssertFalse(cardViewController.items.storeDetailsItem.isVisible)
        XCTAssertFalse(cardViewController.items.storeDetailsItem.value)
    }

    func test_clear_shouldResetPostalCodeItem() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.postalCodeItem.value = "1501 NH"

        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertTrue(sut.cardViewController.items.postalCodeItem.value.isEmpty)
    }

    func test_clear_shouldResetNumberItem() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.numberContainerItem.numberItem.value = "4111 1111 1111 1111"
        
        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertTrue(sut.cardViewController.items.numberContainerItem.numberItem.value.isEmpty)
    }

    func test_clear_shouldResetExpiryDateItem() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.expiryDateItem.value = "03/24"

        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertTrue(sut.cardViewController.items.expiryDateItem.value.isEmpty)
    }

    func test_clear_shouldResetSecurityCodeItem() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.securityCodeItem.value = "935"

        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertTrue(sut.cardViewController.items.securityCodeItem.value.isEmpty)
    }

    func test_clear_shouldResetHolderNameItem() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.holderNameItem.value = "Katrina del Mar"

        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertTrue(sut.cardViewController.items.holderNameItem.value.isEmpty)
    }

    func test_clear_shouldResetStoreDetailsItem() throws {
        // Given

        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        sut.cardViewController.items.storeDetailsItem.value = true

        // show view controller
        setupRootViewController(sut.viewController)
        
        // When
        // hide view controller
        setupRootViewController(UIViewController())

        // Then
        XCTAssertFalse(sut.cardViewController.items.storeDetailsItem.value)
    }
    
    func test_prefilling_withBillingAddressInLookupMode_shouldPrefillItems() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .lookup(
            onAddressLookup: { searchTerm in
                [.init(identifier: searchTerm, postalAddress: .init(city: searchTerm))]
            }
        )
        configuration.shopperInformation = shopperInformation

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // When
        
        setupRootViewController(component.cardViewController)

        // Then
        let view: UIView = component.cardViewController.view

        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let expectedHoldername = try XCTUnwrap(shopperInformation.card?.holderName)
        let holdername = holdernameView.item.value
        XCTAssertEqual(expectedHoldername, holdername)

        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let expectedSocialSecurityNumber = try XCTUnwrap(shopperInformation.socialSecurityNumber)
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertEqual(expectedSocialSecurityNumber, socialSecurityNumber)

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
    }

    func test_prefilling_withBillingAddressInFullMode_shouldPrefillItems() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .full
        configuration.shopperInformation = shopperInformation

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // When
        setupRootViewController(sut.cardViewController)

        // Then
        let view: UIView = sut.cardViewController.view

        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let expectedHoldername = try XCTUnwrap(shopperInformation.card?.holderName)
        let holdername = holdernameView.item.value
        XCTAssertEqual(expectedHoldername, holdername)

        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let expectedSocialSecurityNumber = try XCTUnwrap(shopperInformation.socialSecurityNumber)
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertEqual(expectedSocialSecurityNumber, socialSecurityNumber)

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
    }

    func test_prefilling_withBillingAddressInPostalCodeMode_shouldPrefillItems() throws {
        // Given

        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .postalCode
        configuration.shopperInformation = shopperInformation

        let prefilledSut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // When
        setupRootViewController(prefilledSut.cardViewController)

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

    func test_prefilling_withNoShopperInformationAndFullAddressMode_shouldNotPrefillItems() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .full

        let sut = CardComponent(
            paymentMethod: method,
            context: Dummy.context(with: nil),
            configuration: configuration
        )

        // When
        setupRootViewController(sut.cardViewController)

        // Then
        let view: UIView = sut.cardViewController.view

        let holdernameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.holdername))
        let holdername = holdernameView.item.value
        XCTAssertTrue(holdername.isEmpty)

        let socialSecurityNumberView: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.socialSecurityNumber))
        let socialSecurityNumber = socialSecurityNumberView.item.value
        XCTAssertTrue(socialSecurityNumber.isEmpty)

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let billingAddress = billingAddressView.item.value
        XCTAssertNil(billingAddress)
    }

    func test_prefilling_withNoShopperInformationAndPostalCodeMode_shouldNotPrefillItems() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .postalCode

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // When
        setupRootViewController(sut.cardViewController)

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
    
    func test_billingAddress_withSupportedCountries_shouldFilterCountryList() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["UK"]

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        
        setupRootViewController(component.viewController)
        
        // Then
        let view: UIView = component.cardViewController.view
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        
        billingAddressView.item.selectionHandler()
        
        let presentedViewController = try waitForViewController(
            ofType: UINavigationController.self,
            toBecomeChildOf: UIViewController.topPresenter()
        )
        
        XCTAssertTrue(presentedViewController.viewControllers.first is AddressInputFormViewController)
        
        let inputForm = try XCTUnwrap(presentedViewController.viewControllers.first as? AddressInputFormViewController)
        XCTAssertEqual(inputForm.addressItem.configuration.supportedCountryCodes, ["UK"])
        XCTAssertEqual(inputForm.addressItem.countryPickerItem.value?.identifier, "UK")
    }
    
    func test_billingAddress_withSupportedCountriesAndMatchingPrefill_shouldUsePrefillData() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["US", "JP"]
        configuration.shopperInformation = shopperInformation

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        
        setupRootViewController(component.viewController)
        
        // Then
        let view: UIView = component.cardViewController.view
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)
        
        billingAddressView.item.selectionHandler()
        
        let presentedViewController = try waitForViewController(
            ofType: UINavigationController.self,
            toBecomeChildOf: UIViewController.topPresenter()
        )
        
        XCTAssertTrue(presentedViewController.viewControllers.first is AddressInputFormViewController)
        
        let inputForm = try XCTUnwrap(presentedViewController.viewControllers.first as? AddressInputFormViewController)
        XCTAssertEqual(inputForm.addressItem.configuration.supportedCountryCodes, ["US", "JP"])
        XCTAssertEqual(inputForm.addressItem.value, expectedBillingAddress)
    }
    
    func test_billingAddress_withSupportedCountriesAndNonMatchingPrefill_shouldUseFirstSupportedCountry() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["UK"]
        configuration.shopperInformation = shopperInformation

        let component = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        
        setupRootViewController(component.viewController)
        
        // Then
        let view: UIView = component.cardViewController.view
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        billingAddressView.item.selectionHandler()
        
        let presentedViewController = try waitForViewController(
            ofType: UINavigationController.self,
            toBecomeChildOf: UIViewController.topPresenter()
        )
        
        let inputForm = try XCTUnwrap(presentedViewController.viewControllers.first as? AddressInputFormViewController)
        
        XCTAssertEqual(inputForm.addressItem.configuration.supportedCountryCodes, ["UK"])
        XCTAssertEqual(inputForm.addressItem.countryPickerItem.value?.identifier, "UK")
    }
    
    func test_billingAddress_withOptionalPolicyAndInvalidAddress_shouldAllowSubmit() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["US"]
        configuration.billingAddress.requirementPolicy = .optionalForCardTypes([.visa])

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)
        
        let view: UIView = sut.cardViewController.view
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        billingAddressView.item.value = PostalAddress(
            city: "City",
            postalCode: "123",
            stateOrProvince: "AZ"
        )
        
        wait(until: billingAddressView, at: \.isValid, is: true)
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertNotNil(sut.cardViewController.validAddress)
            XCTAssertEqual(data.billingAddress?.country, billingAddressView.item.value?.country)
            XCTAssertEqual(data.billingAddress?.city, billingAddressView.item.value?.city)
            XCTAssertEqual(data.billingAddress?.stateOrProvince, billingAddressView.item.value?.stateOrProvince)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_billingAddress_withOptionalPolicyAndValidAddress_shouldIncludeInPaymentData() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["US"]
        configuration.billingAddress.requirementPolicy = .optionalForCardTypes([.visa])
        configuration.shopperInformation = shopperInformation

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)
        
        let view: UIView = sut.cardViewController.view
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertEqual(data.billingAddress, self.shopperInformation.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_postalCode_withOptionalPolicyAndValidValue_shouldIncludeInPaymentData() throws {

        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        configuration.billingAddress.countryCodes = ["US"]
        configuration.billingAddress.requirementPolicy = .optionalForCardTypes([.visa])
        configuration.shopperInformation = shopperInformation
        
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)
        
        let view: UIView = sut.cardViewController.view
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let postalCodeField: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        populate(textItemView: postalCodeField, with: "123")
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertEqual(data.billingAddress, PostalAddress(postalCode: "123"))

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_postalCode_withOptionalPolicyAndInvalidValue_shouldAllowSubmit() throws {
        
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .postalCode
        configuration.billingAddress.countryCodes = ["US"]
        configuration.billingAddress.requirementPolicy = .optionalForCardTypes([.visa])

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }
        
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)
        
        let view: UIView = sut.cardViewController.view
        
        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let postalCodeField: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        
        wait(until: postalCodeField, at: \.isValid, is: true)
        
        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertNil(data.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }
        
        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_holderNameField_withEmptyValue_shouldBeInvalid() {
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        let items = sut.cardViewController.items
        XCTAssertFalse(items.holderNameItem.isValid())
    }

    func test_payButton_withLocaleParameter_shouldFormatAmountCorrectly() {
        let amount = Amount(value: 1234567, currencyCode: "USD")
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: amount, countryCode: "US"),
            amount: amount
        )

        // When
        var configuration = CardComponentConfiguration()
        configuration.localizationParameters = LocalizationParameters(locale: "ko-KR")
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // Then
        let items = sut.cardViewController.items
        XCTAssertEqual(items.button.title, "Pay US$12,345.67")
    }

    func test_payButton_withEnforcedLocale_shouldUseEnforcedLocaleFormatting() {
        let amount = Amount(value: 1234567, currencyCode: "USD")
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: amount, countryCode: "US"),
            amount: amount
        )

        // When
        var configuration = CardComponentConfiguration()
        configuration.localizationParameters = LocalizationParameters(enforcedLocale: "ru-RU")
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        // Then
        let items = sut.cardViewController.items
        XCTAssertEqual(items.button.title, "Заплатить 12 345,67 $")
    }

    func test_holderNameField_withMinimumLength_shouldBeValid() {
        var configuration = CardComponentConfiguration()
        configuration.showsHolderNameField = true
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )

        let items = sut.cardViewController.items
        items.holderNameItem.value = "A"
        XCTAssertTrue(items.holderNameItem.isValid())
    }

    func test_billingAddress_withEmptyApartment_shouldSubmitNilApartment() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["US"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
 
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        billingAddressView.item.value = PostalAddress(city: "Seattle", postalCode: "123", stateOrProvince: "AZ", street: "Test Street")

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_billingAddress_withApartmentValue_shouldIncludeApartmentInPaymentData() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["US"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))
        
        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        billingAddressView.item.value = PostalAddress(
            city: "Seattle",
            houseNumberOrName: "12",
            postalCode: "123",
            stateOrProvince: "AZ",
            street: "Test Street"
        )

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_billingAddress_forCountryWithoutStateProvince_shouldNotIncludeStateOrProvince() throws {
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .full
        configuration.billingAddress.countryCodes = ["GB"]

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .bijenkorfCard)],
                issuingCountryCode: "GB"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))

        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.billingAddress))

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4596 1234 2345 087")
        populate(textItemView: expiryDateField, with: "12/30")

        billingAddressView.item.value = PostalAddress(
            city: "London",
            houseNumberOrName: "12",
            postalCode: "123",
            street: "Test Street"
        )

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)
            XCTAssertNotNil(sut.cardViewController.validAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_expiryDateField_whenValueEntered_shouldParseMonthAndYear() {
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        let expiryDateItem = sut.cardViewController.items.expiryDateItem
        
        XCTAssertNil(expiryDateItem.expiryMonth)
        XCTAssertNil(expiryDateItem.expiryYear)
        
        fillCard(on: sut.viewController.view, with: Dummy.visaCard)
        
        wait(until: expiryDateItem, at: \.expiryYear, is: "2030")
        wait(until: expiryDateItem, at: \.expiryMonth, is: "03")
    }

    func test_validate_withValidInput_shouldReturnTrue() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .none
        let sut = CardComponent(
            paymentMethod: method,
            context: Dummy.context(with: nil),
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: BinInfoProviderMock()
        )

        setupRootViewController(sut.viewController)

        fillCard(on: sut.viewController.view, with: Dummy.visaCard)

        let cardViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<CardViewController>)?.childViewController)
        let expectedResult = cardViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func test_validate_withInvalidInput_shouldReturnFalse() throws {
        // Given
        var configuration = CardComponentConfiguration()
        configuration.billingAddress.mode = .none
        let sut = CardComponent(
            paymentMethod: method,
            context: Dummy.context(with: nil),
            configuration: configuration,
            publicKeyProvider: PublicKeyProviderMock(),
            binProvider: BinInfoProviderMock()
        )

        setupRootViewController(sut.viewController)

        let cardViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<CardViewController>)?.childViewController)
        let expectedResult = cardViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    // MARK: - Private

    private func focus(textItemView: some FormTextItemView<some FormTextItem>) {
        textItemView.textField.becomeFirstResponder()
        wait(until: textItemView.textField, at: \.isFirstResponder, is: true)
    }

    private enum CardViewIdentifier {
        static let holdername = "AdyenCard.CardComponent.holderNameItem"
        static let billingAddress = "AdyenCard.CardComponent.billingAddress"
        static let zipCode = "AdyenCard.CardComponent.postalCodeItem"
        static let fullAddressZipCode = "AdyenCard.CardComponent.billingAddress.postalCode"
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
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370",
            card: .init(holderName: "Katrina del Mar")
        )
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
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let expiryDateItemView: FormTextInputItemView? = view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
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
