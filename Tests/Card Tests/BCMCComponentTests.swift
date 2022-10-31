//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
import XCTest

class BCMCComponentTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!
    var delegate: PaymentComponentDelegateMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
        delegate = PaymentComponentDelegateMock()
    }

    override func tearDownWithError() throws {
        context = nil
        delegate = nil
        try super.tearDownWithError()
    }

    func testRequiresKeyboardInput() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.accel])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: CardComponent.Configuration())

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testDefaultConfigAllFieldsArePresent() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.chinaUnionPay])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: CardComponent.Configuration())
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        wait(for: .milliseconds(300))
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.supportedCardLogosItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testShowHolderNameField() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.argencard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: configuration)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        
        wait(for: .milliseconds(300))
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testHideStorePaymentMethodField() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.bcmc])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsStorePaymentMethodField = false
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: configuration)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        wait(for: .milliseconds(300))
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testValidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.bcmc])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        wait(for: .milliseconds(300))
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)
        let textItemView: FormCardNumberItemView? = cardNumberItemView!.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(textItemView)
        self.populate(textItemView: textItemView!, with: Dummy.bancontactCard.number!)
        
        let cardNumberItem = cardNumberItemView!.item
        XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 1)
        XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.url, LogoURLProvider.logoURL(withName: "bcmc", environment: context.apiContext.environment))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.cardTypeLogos"))
    }
    
    func testInvalidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)

        let cardNumberItem = cardNumberItemView!.item
        self.populate(textItemView: cardNumberItemView!, with: "00000")
        
        wait(for: .milliseconds(300))
        
        XCTAssertTrue(cardNumberItem.detectedBrandLogos.count == 0)
    }
    
    func testSubmitValidPaymentData() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        PublicKeyProvider.publicKeysCache[Dummy.apiContext.clientKey] = Dummy.publicKey
        sut.delegate = delegate
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
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

        wait(for: .milliseconds(300))
        
        // Enter Card Number
        let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberView)
        self.populate(textItemView: cardNumberView!, with: Dummy.bancontactCard.number!)
        
        // Enter Expiry Date
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        XCTAssertNotNil(expiryDateItemView)
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 2)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .year], from: date)
        let expiryDate = "\(String(format: "%02d/%02d", components.month!, components.year! % 100))"
        self.populate(textItemView: expiryDateItemView!, with: expiryDate)
        
        // Tap submit button
        tapSubmitButton(on: sut.viewController.view)
        
        wait(for: [didSubmitExpectation], timeout: 10)
    }
    
    func testDelegateCalledCorrectCard() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.americanExpress])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let mockedBrands = [CardBrand(type: .bcmc, cvcPolicy: .optional)]
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in
                                                         XCTAssertEqual(value, mockedBrands)
                                                         expectationCardType.fulfill()
                                                     },
                                                     onSubmitLastFour: { _, _ in
                                                         XCTFail("form not submited yet onSubmitLastFour is called")
                                                     })
        sut.cardComponentDelegate = delegateMock
        
        wait(for: .milliseconds(300))
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        self.populate(textItemView: cardNumberItemView!, with: "67034")
        
        wait(for: [expectationCardType], timeout: 5)
    }

    func testDelegateCalledCorrectBIN() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 1
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertTrue("670344".hasPrefix(value))
                                                         XCTAssertTrue(value.count <= 6)
                                                         expectationBin.fulfill()
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _, _ in
                                                         XCTFail("form not submited yet onSubmitLastFour is called")
                                                     })
        sut.cardComponentDelegate = delegateMock

        wait(for: .milliseconds(300))
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        populate(textItemView: cardNumberItemView!, with: Dummy.bancontactCard.number!)

        wait(for: [expectationBin], timeout: 5)
    }
    
    func testOnSubmitLastFourNotCalledUntilCardNumberIsValidAndSubmitted() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 1
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertEqual(value, "670344")
                                                         expectationBin.fulfill()
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _, _ in
                                                         XCTFail("form not submited yet onSubmitLastFour is called")
                                                     })
        sut.cardComponentDelegate = delegateMock

        wait(for: .milliseconds(300))
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        populate(textItemView: cardNumberItemView!, with: "6703 4444 4444")

        wait(for: [expectationBin], timeout: 1)
    }
    
    func testDelegateCalledWith6DigitsBINThenFinal6DigitsBIN() {
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, panLength: 19)]))
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 2
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertTrue("670344".hasPrefix(value))
                                                         XCTAssertTrue(value.count <= 6)
                                                         if value == "670344" {
                                                             expectationBin.fulfill()
                                                         }
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _, finalBin in
                                                         XCTAssertEqual(finalBin, "670344")
                                                         expectationBin.fulfill()
                                                     })
        sut.cardComponentDelegate = delegateMock

        wait(for: .milliseconds(300))
        
        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard, simulateKeyStrokes: true)
        
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 1)
    }
    
    func testDelegateCalledWith8DigitsBINThenFinal8DigitsBIN() {
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, isLuhnCheckEnabled: false)]))
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 2
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertTrue("67030000".hasPrefix(value))
                                                         XCTAssertTrue(value.count <= 8)
                                                         if value == "67030000" {
                                                             expectationBin.fulfill()
                                                         }
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _, finalBin in
                                                         XCTAssertEqual(finalBin, "67030000")
                                                         expectationBin.fulfill()
                                                     })
        sut.cardComponentDelegate = delegateMock

        wait(for: .milliseconds(300))
        
        fillCard(on: sut.viewController.view, with: Dummy.longBancontactCard, simulateKeyStrokes: true)
        
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 1)
    }
    
    func testDelegateIncorrectCard() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.argencard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in
                                                         XCTAssertEqual(value, [])
                                                         expectationCardType.fulfill()
                                                     },
                                                     onSubmitLastFour: { _, _ in
                                                         XCTFail("form not submited yet onSubmitLastFour is called")
                                                     })
        sut.cardComponentDelegate = delegateMock
        
        wait(for: .milliseconds(300))
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        self.populate(textItemView: cardNumberItemView!, with: "32145")
        
        wait(for: [expectationCardType], timeout: 5)
    }
    
    func testSubmitPaymentDataInvalidCardNumber() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        sut.delegate = delegate
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        delegate.onDidSubmit = { data, component in
            XCTFail("delegate.didSubmit() must not be called")
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
        wait(for: .milliseconds(300))
        
        // Enter invalid Card Number
        let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberView)
        self.populate(textItemView: cardNumberView!, with: "123")
        
        // Enter Expiry Date
        let expiryDateView = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        XCTAssertNotNil(expiryDateView as? FormTextItemView<FormCardExpiryDateItem>)
        let expiryDateItemView = expiryDateView as! FormTextItemView<FormCardExpiryDateItem>
        self.populate(textItemView: expiryDateItemView, with: "10/20")
        
        // Tap submit button
        tapSubmitButton(on: sut.viewController.view)
        
        wait(for: .milliseconds(300))
        
        let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem.alertLabel")
        XCTAssertNotNil(alertLabel)
        XCTAssertEqual(alertLabel?.text, cardNumberView?.item.validationFailureMessage)
        
    }
    
    func testBigTitle() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.visa])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(300))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, cardPaymentMethod.name)
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let cardPaymentMethod = CardPaymentMethod(type: .card,
                                                  name: "Test name",
                                                  fundingSource: .credit,
                                                  brands: [.visa, .americanExpress, .masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        // When
        sut.cardViewController.viewWillAppear(true)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
    
    func fillCard(on view: UIView, with card: Card, simulateKeyStrokes: Bool = false) {
        let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem>? = view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        let securityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>? = view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem")

        if simulateKeyStrokes {
            populateSimulatingKeystrokes(textItemView: cardNumberItemView!, with: card.number ?? "")
        } else {
            populate(textItemView: cardNumberItemView!, with: card.number ?? "")
        }
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
