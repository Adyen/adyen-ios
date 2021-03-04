//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
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
                                clientKey: "test_client_key")

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertTrue((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testDefaultConfigAllFieldsArePresent() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: CardComponent.Configuration(),
                                clientKey: "test_client_key")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testShowHolderNameField() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                configuration: configuration,
                                clientKey: "test_client_key")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem.cardTypeLogos"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
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
                                clientKey: "test_client_key")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.configuration.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.configuration.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.securityCodeItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testValidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            XCTAssertNotNil(cardNumberItemView)
            let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.BCMCComponent.numberItem")
            XCTAssertNotNil(textItemView)
            self.populate(textItemView: textItemView!, with: "6703444444444449")
            
            let cardNumberItem = cardNumberItemView!.item
            XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 1)
            XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.url, LogoURLProvider.logoURL(withName: "bcmc", environment: sut.environment))
            XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.isHidden, false)
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem.cardTypeLogos"))
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 8)
    }
    
    func testInvalidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
        XCTAssertNotNil(cardNumberItemView)

        let cardNumberItem = cardNumberItemView!.item
        self.populate(textItemView: cardNumberItemView!, with: "00000")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {

            XCTAssertTrue(cardNumberItem.cardTypeLogos.allSatisfy { $0.isHidden })
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testSubmitValidPaymentData() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .credit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")
        CardPublicKeyProvider.cachedCardPublicKey = Dummy.dummyPublicKey
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
            XCTAssertNotNil(resultJson["encryptedSecurityCode"] as? String)
            XCTAssertNotNil(resultJson["encryptedExpiryMonth"] as? String)

            sut.stopLoading {
                didSubmitExpectation.fulfill()
            }
        }
        delegate.onDidFail = { error, _ in
            XCTFail("delegate.didFail() must not be called")
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            // Enter Card Number
            let cardNumberView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            XCTAssertNotNil(cardNumberView)
            self.populate(textItemView: cardNumberView!, with: "6703444444444449")
            
            // Enter Expiry Date
            let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
            XCTAssertNotNil(expiryDateItemView)
            let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 2)
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .year], from: date)
            let expireyDate = "\(String(format: "%02d/%02d", components.month!, components.year! % 100))"
            self.populate(textItemView: expiryDateItemView!, with: expireyDate)
            
            // Tap submit button
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.payButtonItem.button")
            XCTAssertNotNil(submitButton)
            submitButton!.sendActions(for: .touchUpInside)
        }
        wait(for: [didSubmitExpectation], timeout: 10)
    }
    
    func testDelegateCallledCorrectCard() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let mockedBrands = [CardBrand(type: .bcmc, cvcPolicy: .optional)]
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in },
                                                     onCardBrandChange: { value in
                                                        XCTAssertEqual(value, mockedBrands)
                                                         expectationCardType.fulfill()
                                                     })
        sut.cardComponentDelegate = delegateMock
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "67034")
        }
        
        wait(for: [expectationCardType], timeout: 5)
    }

    func testDelegateCallledCorrectBIN() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectationBin = XCTestExpectation(description: "Bin Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { value in
            XCTAssertEqual(value, "670344")
            expectationBin.fulfill()
        }, onCardBrandChange: { _ in })
        sut.cardComponentDelegate = delegateMock

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "67034444234232")
        }

        wait(for: [expectationBin], timeout: 5)
    }
    
    func testDelegateIncorrectCard() {
        let method = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: method)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectationCardType = XCTestExpectation(description: "CardType Expectation")
        let delegateMock = CardComponentDelegateMock(onBINDidChange: { _ in }, onCardBrandChange: { value in
            XCTAssertEqual(value, [])
            expectationCardType.fulfill()
        })
        sut.cardComponentDelegate = delegateMock
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            self.populate(textItemView: cardNumberItemView!, with: "32145")
        }
        
        wait(for: [expectationCardType], timeout: 5)
    }
    
    func testSubmitPaymentDataInvalidCardNumber() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", fundingSource: .debit, brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod,
                                clientKey: "test_client_key")
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
            let cardNumberView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem")
            XCTAssertNotNil(cardNumberView)
            self.populate(textItemView: cardNumberView!, with: "123")
            
            // Enter Expiry Date
            let expiryDateView = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.expiryDateItem")
            XCTAssertNotNil(expiryDateView as? FormTextItemView<FormTextInputItem>)
            let expiryDateItemView = expiryDateView as! FormTextItemView<FormTextInputItem>
            self.populate(textItemView: expiryDateItemView, with: "10/20")
            
            // Tap submit button
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.payButtonItem.button")
            XCTAssertNotNil(submitButton)
            submitButton!.sendActions(for: .touchUpInside)
            
            // wait until the alert popup is shown
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.numberItem.alertLabel")
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
                                clientKey: "test_client_key")

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.BCMCComponent.Test name"))
            XCTAssertEqual(sut.viewController.title, cardPaymentMethod.name)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    private func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }
    
}
