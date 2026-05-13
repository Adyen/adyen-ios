//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
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

    func test_cardViewController_shouldRequireKeyboardInput() throws {
        // Given
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.accel])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        // When
        sut.viewController.loadViewIfNeeded()
        
        // Then
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<CardViewController>)
        let cardViewController = try XCTUnwrap(securedViewController.childViewController)
        XCTAssertTrue(cardViewController.requiresKeyboardInput)
    }
    
    func test_component_withDefaultConfig_shouldShowAllRequiredFields() {
        let brands: [CardType] = [.bcmc, .visa, .maestro]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        sut.viewController.loadViewIfNeeded()
        
        XCTAssertEqual(sut.configuration.supportedCardBrands, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.supportedCardLogosItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func test_cardLogos_whenValidCardEntered_shouldHideSupportedLogos() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.chinaUnionPay])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: CardComponentConfiguration()
        )
        
        XCTAssertFalse(sut.cardViewController.items.numberContainerItem.showSupportedCardBrandLogos)
        
        sut.viewController.loadViewIfNeeded()
        
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
    
    func test_holderNameField_whenConfigured_shouldBeVisible() {
        let brands: [CardType] = [.argencard]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponentConfiguration()
        configuration.showCardholderName = true
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        sut.viewController.loadViewIfNeeded()
        
        XCTAssertEqual(sut.configuration.supportedCardBrands, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func test_storePaymentMethodField_whenConfiguredToHide_shouldNotBeVisible() {
        let brands: [CardType] = [.bcmc]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponentConfiguration()
        configuration.showStorePaymentMethod = false
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        sut.viewController.loadViewIfNeeded()
        
        XCTAssertEqual(sut.configuration.supportedCardBrands, nil)
        XCTAssertEqual(sut.supportedCardTypes, brands)
        
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
    }
    
    func test_cardNumber_withValidBCMCCard_shouldDetectCardType() throws {
        let brands: [CardType] = [.bcmc]
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        
        setupRootViewController(sut.viewController)
        
        let cardNumberItemView: FormCardNumberItemView = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem"))
        try self.populate(textItemView: cardNumberItemView, with: XCTUnwrap(Dummy.bancontactCard.number))
        
        XCTAssertEqual(cardNumberItemView.item.cardTypeLogos.count, 1)
        XCTAssertEqual(cardNumberItemView.item.cardTypeLogos.first?.url, try LogoURLProvider.logoURL(withName: XCTUnwrap(brands.first?.rawValue), environment: context.apiContext.environment))

        wait(for: .aMoment)
    }
    
    func test_cardNumber_withInvalidCard_shouldNotDetectCardType() throws {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        
        sut.viewController.loadViewIfNeeded()
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberItemView)

        let cardNumberItem = try XCTUnwrap(cardNumberItemView?.item)
        try self.populate(textItemView: XCTUnwrap(cardNumberItemView), with: "00000")
        
        wait(until: cardNumberItem, at: \.detectedBrands.count, is: 0)
    }
    
    func test_submit_withValidPaymentData_shouldCallDelegate() throws {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        sut.delegate = delegate

        sut.viewController.loadViewIfNeeded()
        
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

            sut.stopLoading()
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
        try self.populate(textItemView: XCTUnwrap(cardNumberView), with: XCTUnwrap(Dummy.bancontactCard.number))
        
        // Enter Expiry Date
        let expiryDateItemView: FormTextInputItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        XCTAssertNotNil(expiryDateItemView)
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 2)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .year], from: date)
        let expiryDate = "\(String(format: "%02d/%02d", components.month!, components.year! % 100))"
        try self.populate(textItemView: XCTUnwrap(expiryDateItemView), with: expiryDate)
        
        // Tap submit button
        tapSubmitButton(on: sut.viewController.view)
        
        wait(for: [didSubmitExpectation], timeout: 10)
    }
    
    func test_onBinLookup_withCorrectCard_shouldReturnMatchingBrands() throws {
        let brands: [CardType] = [.bcmc]
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: brands)
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        
        sut.viewController.loadViewIfNeeded()
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let mockedBrands = [CardBrand(type: .bcmc, cvcPolicy: .optional)]
        sut.configuration = sut.configuration
            .onBinLookup { value in
                XCTAssertEqual(value, mockedBrands)
                expectationCardType.fulfill()
            }
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        try self.populate(textItemView: XCTUnwrap(cardNumberItemView), with: "67034")
        
        wait(for: [expectationCardType], timeout: 10)
    }

    func test_onBinChange_withCorrectBIN_shouldReturnBINValue() throws {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        sut.viewController.loadViewIfNeeded()

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        expectationBin.expectedFulfillmentCount = 1
        expectationBin.assertForOverFulfill = true
        sut.configuration = sut.configuration
            .onBinChange { value in
                XCTAssertTrue("67034444".hasPrefix(value))
                XCTAssertTrue(value.count <= 8)
                expectationBin.fulfill()
            }
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        try populate(textItemView: XCTUnwrap(cardNumberItemView), with: XCTUnwrap(Dummy.bancontactCard.number))

        wait(for: [expectationBin], timeout: 10)
    }
    
    func test_onBinChange_with6DigitsBIN_shouldReturn6Digits() {
        
        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .optional, panLength: 19)]))
            expectationBinLookup.fulfill()
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(),
            binProvider: cardTypeProviderMock
        )

        sut.viewController.loadViewIfNeeded()

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        sut.configuration = sut.configuration
            .onBinChange { value in
                XCTAssertTrue("67034444".hasPrefix(value))
                XCTAssertTrue(value.count <= 8)
                if value == "67034444" {
                    expectationBin.fulfill()
                }
            }
        
        fillCard(on: sut.viewController.view, with: Dummy.bancontactCard, simulateKeyStrokes: true)
        wait(for: [expectationBinLookup], timeout: 10)
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 10)
    }
    
    func test_onBinChange_with8DigitsBIN_shouldReturn8Digits() {
        
        let expectationBinLookup = XCTestExpectation(description: "Bin Lookup Expectation")
        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(brands: [CardBrand(type: .bcmc, cvcPolicy: .optional, isLuhnCheckEnabled: false)]))
            expectationBinLookup.fulfill()
        }
        
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.masterCard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(),
            binProvider: cardTypeProviderMock
        )

        sut.viewController.loadViewIfNeeded()

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        sut.configuration = sut.configuration
            .onBinChange { value in
                XCTAssertTrue("67030000".hasPrefix(value))
                XCTAssertTrue(value.count <= 8)
                if value == "67030000" {
                    expectationBin.fulfill()
                }
            }
        
        fillCard(on: sut.viewController.view, with: Dummy.longBancontactCard, simulateKeyStrokes: true)
        wait(for: [expectationBinLookup], timeout: 10)
        tapSubmitButton(on: sut.viewController.view)

        wait(for: [expectationBin], timeout: 10)
    }
    
    func test_onBinLookup_withIncorrectCard_shouldReturnEmptyBrands() throws {
        let method = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.argencard])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        sut.viewController.loadViewIfNeeded()
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        sut.configuration = sut.configuration
            .onBinLookup { value in
                XCTAssertEqual(value, [])
                expectationCardType.fulfill()
            }
        
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        try self.populate(textItemView: XCTUnwrap(cardNumberItemView), with: "32145")
        
        wait(for: [expectationCardType], timeout: 10)
    }
    
    func test_submit_withInvalidCardNumber_shouldShowValidationError() throws {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .debit, brands: [.maestro])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        sut.delegate = delegate
        sut.viewController.loadViewIfNeeded()
        
        delegate.onDidSubmit = { data, component in
            XCTFail("delegate.didSubmit() must not be called")
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
        // Enter invalid Card Number
        let cardNumberView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        XCTAssertNotNil(cardNumberView)
        try self.populate(textItemView: XCTUnwrap(cardNumberView), with: "123")
        
        // Enter Expiry Date
        let expiryDateView = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
        XCTAssertNotNil(expiryDateView as? FormTextInputItemView)
        let expiryDateItemView = try XCTUnwrap(expiryDateView as? FormTextInputItemView)
        self.populate(textItemView: expiryDateItemView, with: "10/20")
        
        // Tap submit button
        tapSubmitButton(on: sut.viewController.view)
        
        wait(for: .milliseconds(300))
        
        let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem.footerLabel")
        XCTAssertNotNil(alertLabel)
        XCTAssertEqual(alertLabel?.text, cardNumberView?.item.validationFailureMessage)
        
    }
    
    func test_viewController_shouldNotShowBigTitle() {
        let cardPaymentMethod = CardPaymentMethod(type: .bcmc, name: "Test name", fundingSource: .credit, brands: [.visa])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        sut.viewController.loadViewIfNeeded()

        XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, cardPaymentMethod.name)
    }

    func test_viewDidLoad_shouldSendAnalyticsInitialCall() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let cardPaymentMethod = CardPaymentMethod(
            type: .card,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        // When
        sut.viewDidLoad(viewController: sut.cardViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }
    
    func fillCard(on view: UIView, with card: Card, simulateKeyStrokes: Bool = false) {
        let cardNumberItemView: FormCardNumberItemView? = view.findView(with: "AdyenCard.BCMCComponent.numberContainerItem.numberItem")
        let expiryDateItemView: FormTextInputItemView? = view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
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
