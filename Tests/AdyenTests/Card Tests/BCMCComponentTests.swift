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

class BCMCComponentTests: XCTestCase {
    
    var delegate: PaymentComponentDelegateMock!
    
    override func setUp() {
        super.setUp()
        delegate = PaymentComponentDelegateMock()
    }

    func testRequiresKeyboardInput() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: CardComponent.Configuration(),
                                apiContext: Dummy.context)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testDefaultConfigAllFieldsArePresent() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: CardComponent.Configuration(),
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.supportedCardLogosItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testCardLogos() throws {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: CardComponent.Configuration(),
                                apiContext: Dummy.context)

        XCTAssertFalse(sut.cardViewController.items.numberContainerItem.showsSupportedCardLogos)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(30))

        let supportedCardLogosItemId = "AdyenCard.BCMCComponent.numberContainerItem.supportedCardLogosItem"

        var supportedCardLogosItem: FormCardLogosItemView? = sut.viewController.view.findView(with: supportedCardLogosItemId)
        XCTAssertNil(supportedCardLogosItem)

        // Valid input
        
        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard)

        let binResponse = BinLookupResponse(brands: [CardBrand(type: .bcmc, isSupported: true)])
        sut.cardViewController.update(binInfo: binResponse)

        wait(for: .milliseconds(30))

        supportedCardLogosItem = sut.viewController.view.findView(with: supportedCardLogosItemId)
        XCTAssertNil(supportedCardLogosItem)
    }
    
    func testShowHolderNameField() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: configuration,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testHideStorePaymentMethodField() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsStorePaymentMethodField = false
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: configuration,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        XCTAssertEqual(sut.supportedCardTypes, [CardType(rawValue: "any_test_brand_name")])
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testValidCardTypeDetection() {
        let brands = ["bcmc", "visa", "maestro"]
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands.map { .init(rawValue: $0) })
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            XCTAssertNotNil(cardNumberItemView)
            let textItemView: FormCardNumberItemView? = cardNumberItemView!.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            XCTAssertNotNil(textItemView)
            self.populate(textItemView: textItemView!, with: Dummy.bancontactCard.number!)
            
            let cardNumberItem = cardNumberItemView!.item
            XCTAssertEqual(cardNumberItem.cardTypeLogos.count, brands.count)
            XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.url, LogoURLProvider.logoURL(withName: brands.first!, environment: sut.apiContext.environment))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 8)
    }
    
    func testInvalidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)

        let cardNumberItem = cardNumberItemView!.item
        self.populate(textItemView: cardNumberItemView!, with: "00000")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            XCTAssertTrue(cardNumberItem.detectedBrandLogos.count == 0)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testSubmitValidPaymentData() {
        let brands = ["bcmc", "visa", "maestro"]
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)
        PublicKeyProvider.publicKeysCache[Dummy.context.clientKey] = Dummy.publicKey
        sut.delegate = delegate
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        self.wait(for: .milliseconds(300))
        
        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called")
        delegate.onDidSubmit = { paymentData, component in
            
            let encoder = JSONEncoder()
            let data = try! encoder.encode(paymentData.paymentMethod.encodable)
            
            let resultJson = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [String: Any]
            
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(resultJson["encryptedExpiryYear"] as? String)
            XCTAssertNotNil(resultJson["encryptedCardNumber"] as? String)
            XCTAssertNotNil(resultJson["type"] as? String)
            XCTAssertEqual(resultJson["type"] as? String, "bcmc")
            XCTAssertNil(resultJson["encryptedSecurityCode"] as? String)
            XCTAssertNotNil(resultJson["encryptedExpiryMonth"] as? String)

            sut.stopLoadingIfNeeded()
            didSubmitExpectation.fulfill()
        }
        delegate.onDidFail = { error, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
        let binChangeCalled = expectation(description: "onBINDidChange was called")
        
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in binChangeCalled.fulfill() },
                                                     onSubmitLastFour: { _ in })
        sut.cardComponentDelegate = delegateMock
        
        // Enter Card Number
        let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberView)
        self.populate(textItemView: cardNumberView!, with: Dummy.bancontactCard.number!)
        
        wait(for: [binChangeCalled], timeout: 5)
        
        // Enter Expiry Date
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        XCTAssertNotNil(expiryDateItemView)
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 2)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .year], from: date)
        let expiryDate = "\(String(format: "%02d/%02d", components.month!, components.year! % 100))"
        self.populate(textItemView: expiryDateItemView!, with: expiryDate)
        
        // Tap submit button
        let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.payButtonItem.button")
        XCTAssertNotNil(submitButton)
        submitButton!.sendActions(for: .touchUpInside)
        
        wait(for: [didSubmitExpectation], timeout: 5)
    }
    
    func testBinLookupRequiredCVC() throws {

        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .required, panLength: 19)]))
            expectationBinLookup.fulfill()
        }

        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let delegateMock = CardComponentDelegateMock(
            onBINDidChange: { _ in },
            onCardBrandChange: { _ in },
            onSubmitLastFour: { _ in
                expectationBin.fulfill()
            }
        )

        sut.cardComponentDelegate = delegateMock

        wait(for: .milliseconds(30))

        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard)
        wait(for: [expectationBinLookup], timeout: 1)
        tapSubmitButton(on: sut.viewController.view) // Should not trigger `didSubmit` as the security code is required
        
        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        populate(textItemView: securityCodeItemView, with: "123")
        tapSubmitButton(on: sut.viewController.view) // Should trigger `didSubmit` as the security code is provided
        wait(for: [expectationBin], timeout: 1)
    }
    
    func testDelegateCalledCorrectCard() {
        let brands = ["bcmc", "visa", "maestro"]
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let mockedBrands = [CardBrand(type: .bcmc, cvcPolicy: .optional), CardBrand(type: .maestro, cvcPolicy: .optional)]
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in
                                                         XCTAssertEqual(value, mockedBrands)
                                                         expectationCardType.fulfill()
                                                     },
                                                     onSubmitLastFour: { _ in })
        sut.cardComponentDelegate = delegateMock
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "67034")
        }
        
        wait(for: [expectationCardType], timeout: 5)
    }

    func testDelegateCallledCorrectBIN() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertEqual(value, "670344")
                                                         expectationBin.fulfill()
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _ in })
        sut.cardComponentDelegate = delegateMock

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: Dummy.bancontactCard.number!)
        }

        wait(for: [expectationBin], timeout: 5)
    }
    
    func testDelegateIncorrectCard() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in
                                                         XCTAssertEqual(value, [])
                                                         expectationCardType.fulfill()
                                                     },
                                                     onSubmitLastFour: { _ in })
        sut.cardComponentDelegate = delegateMock
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "32145")
        }
        
        wait(for: [expectationCardType], timeout: 5)
    }
    
    func testSubmitPaymentDataInvalidCardNumber() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)
        sut.delegate = delegate
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        delegate.onDidSubmit = { data, component in
            XCTFail("delegate.didSubmit() must not be called")
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            // Enter invalid Card Number
            let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
            XCTAssertNotNil(cardNumberView)
            self.populate(textItemView: cardNumberView!, with: "123")
            
            // Enter Expiry Date
            let expiryDateView = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
            XCTAssertNotNil(expiryDateView as? FormTextItemView<FormCardExpiryDateItem>)
            let expiryDateItemView = expiryDateView as! FormTextItemView<FormCardExpiryDateItem>
            self.populate(textItemView: expiryDateItemView, with: "10/20")
            
            // Tap submit button
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.payButtonItem.button")
            XCTAssertNotNil(submitButton)
            submitButton!.sendActions(for: .touchUpInside)
            
            // wait until the alert popup is shown
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.alertLabel")
                XCTAssertNotNil(alertLabel)
                XCTAssertEqual(alertLabel?.text, cardNumberView?.item.validationFailureMessage)
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testBigTitle() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .seconds(1))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, cardPaymentMethod.name)
    }
    
    func fillCard(on view: UIView, with card: Card) {
        let cardNumberItemView: FormCardNumberItemView? = view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem")

        populate(textItemView: cardNumberItemView!, with: card.number ?? "")
        populate(textItemView: expiryDateItemView!, with: "\(card.expiryMonth ?? "") \(card.expiryYear ?? "")")
        if let securityCode = card.securityCode {
            populate(textItemView: securityCodeItemView!, with: securityCode)
        }
    }
    
    func tapSubmitButton(on view: UIView) {
        let payButtonItemViewButton: UIControl? = view.findView(with: "AdyenCard.BCMCComponent.payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)
    }
}
