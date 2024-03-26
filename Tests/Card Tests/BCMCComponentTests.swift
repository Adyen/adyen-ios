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

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
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
        let brands: [CardType] = [.bcmc, .visa, .maestro]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: CardComponent.Configuration())
        
        setupRootViewController(sut.viewController)
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.supportedCardLogosItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testCardLogos() throws {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.chinaUnionPay])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: CardComponent.Configuration())
        
        XCTAssertFalse(sut.cardViewController.items.numberContainerItem.showsSupportedCardLogos)
        
        setupRootViewController(sut.viewController)
        
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
        let brands: [CardType] = [.argencard]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: configuration)
        
        setupRootViewController(sut.viewController)
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testHideStorePaymentMethodField() {
        let brands: [CardType] = [.bcmc]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsStorePaymentMethodField = false
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: configuration)
        
        setupRootViewController(sut.viewController)
        
        XCTAssertEqual(sut.configuration.allowedCardTypes, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.cardTypeLogos"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func testValidCardTypeDetection() throws {
        let brands: [CardType] = [.bcmc]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        
        setupRootViewController(sut.viewController)
        
        let cardNumberItemView: FormCardNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        self.populate(textItemView: cardNumberItemView, with: Dummy.bancontactCard.number!)
        
        XCTAssertEqual(cardNumberItemView.item.cardTypeLogos.count, 1)
        XCTAssertEqual(cardNumberItemView.item.cardTypeLogos.first?.url, LogoURLProvider.logoURL(withName: brands.first!.rawValue, environment: context.apiContext.environment))
        
        wait { cardNumberItemView.findView(by: "cardTypeLogos") != nil }
    }
    
    func testInvalidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        
        setupRootViewController(sut.viewController)
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)

        let cardNumberItem = cardNumberItemView!.item
        self.populate(textItemView: cardNumberItemView!, with: "00000")
        
        wait(until: cardNumberItem, at: \.detectedBrands.count, is: 0)
    }
    
    func testSubmitValidPaymentData() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        PublicKeyProvider.publicKeysCache[Dummy.apiContext.clientKey] = Dummy.publicKey
        sut.delegate = delegate

        setupRootViewController(sut.viewController)
        
        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called")
        delegate.onDidSubmit = { paymentData, component in
            
            let data = try! AdyenCoder.encode(paymentData.paymentMethod.encodable) as Data
            
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
        
        let binResponse = BinLookupResponse(brands: [CardBrand(type: .bcmc, isSupported: true, cvcPolicy: .optional)])
        sut.cardViewController.update(binInfo: binResponse)
        
        // Enter Card Number
        let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
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
        let brands: [CardType] = [.bcmc]
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        
        setupRootViewController(sut.viewController)
        
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
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        self.populate(textItemView: cardNumberItemView!, with: "67034")
        
        wait(for: [expectationCardType], timeout: 10)
    }

    func testDelegateCalledCorrectBIN() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        setupRootViewController(sut.viewController)

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 1
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
                                                         XCTAssertTrue("67034444".hasPrefix(value))
                                                         XCTAssertTrue(value.count <= 8)
                                                         expectationBin.fulfill()
                                                     },
                                                     onCardBrandChange: { _ in },
                                                     onSubmitLastFour: { _, _ in
                                                         XCTFail("form not submited yet onSubmitLastFour is called")
                                                     })
        sut.cardComponentDelegate = delegateMock
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        populate(textItemView: cardNumberItemView!, with: Dummy.bancontactCard.number!)

        wait(for: [expectationBin], timeout: 10)
    }
    
    func testOnSubmitLastFourNotCalledUntilCardNumberIsValidAndSubmitted() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        setupRootViewController(sut.viewController)

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
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        populate(textItemView: cardNumberItemView!, with: "6703 4444 4444")

        wait(for: [expectationBin], timeout: 10)
    }
    
    func testBinLookupRequiredCVC() throws {
        
        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .required, panLength: 19)]))
            expectationBinLookup.fulfill()
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        setupRootViewController(sut.viewController)

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let delegateMock = CardComponentDelegateMock(
            onBINDidChange: { _ in },
            onCardBrandChange: { _ in },
            onSubmitLastFour: { _, finalBin in
                expectationBin.fulfill()
            }
        )
        
        sut.cardComponentDelegate = delegateMock
        
        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard, simulateKeyStrokes: true)
        wait(for: [expectationBinLookup], timeout: 10)
        tapSubmitButton(on: sut.viewController.view) // Should not trigger `didSubmit` as the security code is required
        
        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        populate(textItemView: securityCodeItemView, with: "123")
        tapSubmitButton(on: sut.viewController.view) // Should trigger `didSubmit` as the security code is provided

        wait(for: [expectationBin], timeout: 10)
    }
    
    func testDelegateCalledWith6DigitsBINThenFinal6DigitsBIN() {
        
        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .optional, panLength: 19)]))
            expectationBinLookup.fulfill()
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        setupRootViewController(sut.viewController)

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 2
        expectationBin.assertForOverFulfill = true
        let delegateMock = CardComponentDelegateMock(
            onBINDidChange: { value in
                XCTAssertTrue("67034444".hasPrefix(value))
                XCTAssertTrue(value.count <= 8)
                if value == "67034444" {
                    expectationBin.fulfill()
                }
            },
            onCardBrandChange: { _ in },
            onSubmitLastFour: { _, finalBin in
                XCTAssertEqual(finalBin, "67034444")
                expectationBin.fulfill()
            }
        )
        
        sut.cardComponentDelegate = delegateMock
        
        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard, simulateKeyStrokes: true)
        wait(for: [expectationBinLookup], timeout: 10)
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 10)
    }
    
    func testDelegateCalledWith8DigitsBINThenFinal8DigitsBIN() {
        
        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .optional, isLuhnCheckEnabled: false)]))
            expectationBinLookup.fulfill()
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: .init(),
                                publicKeyProvider: PublicKeyProviderMock(),
                                binProvider: cardTypeProviderMock)

        setupRootViewController(sut.viewController)

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
        
        fillCard(on: sut.viewController.view, with: Dummy.longBancontactCard, simulateKeyStrokes: true)
        wait(for: [expectationBinLookup], timeout: 10)
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 10)
    }
    
    func testDelegateIncorrectCard() {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.argencard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        setupRootViewController(sut.viewController)
        
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
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        self.populate(textItemView: cardNumberItemView!, with: "32145")
        
        wait(for: [expectationCardType], timeout: 10)
    }
    
    func testSubmitPaymentDataInvalidCardNumber() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)
        sut.delegate = delegate
        setupRootViewController(sut.viewController)
        
        delegate.onDidSubmit = { data, component in
            XCTFail("delegate.didSubmit() must not be called")
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
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
        tapSubmitButton(on: sut.viewController.view)
        
        wait(for: .milliseconds(300))
        
        let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.alertLabel")
        XCTAssertNotNil(alertLabel)
        XCTAssertEqual(alertLabel?.text, cardNumberView?.item.validationFailureMessage)
        
    }
    
    func testBigTitle() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.visa])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                context: context)

        setupRootViewController(sut.viewController)

        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, cardPaymentMethod.name)
    }

    func testViewDidLoadShouldSendInitialCall() throws {
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
        sut.viewDidLoad(viewController: sut.cardViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }
    
    func fillCard(on view: UIView, with card: Card, simulateKeyStrokes: Bool = false) {
        let cardNumberItemView: FormCardNumberItemView? = view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
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
