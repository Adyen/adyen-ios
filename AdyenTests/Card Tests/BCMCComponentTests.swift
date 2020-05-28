//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class BCMCComponentTests: XCTestCase {
    
    var delegate: PaymentComponentDelegateMock!
    
    override func setUp() {
        super.setUp()
        delegate = PaymentComponentDelegateMock()
    }
    
    // This is not a real public key, this is just a random string with the right pattern.
    private static var randomTestValidCardPublicKey = "59554|59YWNVYSILHQWVXSIYY8XVK5HMLEAFT2JPJBDVHUD2798K12GKE652PYLJYYNBR0HVN0AYLC38VIU0TSBC9JTQZ4AHOHPPIGVH985H6EI5HAFZXZAM0QIXBAYEP180X0MM6HRHZONIM62TI9US8NXHXNKYSRE8ASJLY3KED6KDD6SY4I29CUY5FYTN8XEQ8NS8M0ECUAG0GV08XAX19HEX8IQ35SNRY8P9G0YOTTEFYC8QGM7N4PYRUWTSOEJV8W9AKJ8ZLR851OA0P7NZOJXZ2EOYNWSORS9RL4HGXVXGANDYXOWCD7XYPHJD6EPYGRUDV87EOT5FHR574DJW5881Y88Y2QR6R9W1WG5N0CV3WJGELJ971OR0S0PTKHOFW7PXRRDVQU1TT4Q8KJJLZ2VHS1BYP0VFQY1FOADWZ2YPGXDT6KPSN6OJ81G9B9BO7LMGYIONUDWQZQM41O27RROX44I89WRLHZHNYP5NEF2ACTF1AJHA4SNTUN9Z93HYQ2"
    
    func testDefaultConfigAllFieldsArePresent() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testShowHolderNameField() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        sut.showsHolderNameField = true
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.cardTypeLogos"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testHideStorePaymentMethodField() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        sut.showsStorePaymentMethodField = false
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        XCTAssertEqual(sut.supportedCardTypes, [.bcmc])
        XCTAssertEqual(sut.excludedCardTypes, [])
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.cardTypeLogos"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem"))
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testValidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            XCTAssertNotNil(cardNumberItemView)
            let textItemView: FormTextItemView<FormCardNumberItem>? = cardNumberItemView!.findView(with: "AdyenCard.CardComponent.numberItem")
            XCTAssertNotNil(textItemView)
            self.populate(textItemView: textItemView!, with: "6703444444444449")
            
            let cardNumberItem = cardNumberItemView!.item
            XCTAssertEqual(cardNumberItem.cardTypeLogos.count, 1)
            XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.url, LogoURLProvider.logoURL(withName: "bcmc", environment: sut.environment))
            XCTAssertEqual(cardNumberItem.cardTypeLogos.first?.isHidden.value, false)
            XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.cardTypeLogos"))
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testInvalidCardTypeDetection() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cardNumberItemView: FormCardNumberItemView? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            XCTAssertNotNil(cardNumberItemView)
            self.populate(textItemView: cardNumberItemView!, with: "980344")
            
            let cardNumberItem = cardNumberItemView!.item
            XCTAssertTrue(cardNumberItem.cardTypeLogos.allSatisfy { $0.isHidden.value })
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testSubmitValidPaymentData() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
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
            didSubmitExpectation.fulfill()
        }
        delegate.onDidFail = { error, _ in
            XCTFail("delegate.didFail() must not be called")
        }
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            // Enter Card Number
            let cardNumberView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            XCTAssertNotNil(cardNumberView)
            self.populate(textItemView: cardNumberView!, with: "6703444444444449")
            
            // Enter Expiry Date
            let expiryDateItemView: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
            XCTAssertNotNil(expiryDateItemView)
            self.populate(textItemView: expiryDateItemView!, with: "10/20")
            
            // Tap submit button
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton")
            XCTAssertNotNil(submitButton)
            submitButton!.sendActions(for: .touchUpInside)
            
            expectation.fulfill()
        }
        wait(for: [expectation, didSubmitExpectation], timeout: 5)
    }
    
    func testSubmitPaymentDataInvalidCardNumber() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
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
            let cardNumberView: FormTextItemView<FormCardNumberItem>? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem")
            XCTAssertNotNil(cardNumberView)
            self.populate(textItemView: cardNumberView!, with: "123")
            
            // Enter Expiry Date
            let expiryDateView = sut.viewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
            XCTAssertNotNil(expiryDateView as? FormTextItemView<FormTextInputItem>)
            let expiryDateItemView = expiryDateView as! FormTextItemView<FormTextInputItem>
            self.populate(textItemView: expiryDateItemView, with: "10/20")
            
            // Tap submit button
            let submitButton: UIControl? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.footer.submitButton")
            XCTAssertNotNil(submitButton)
            submitButton!.sendActions(for: .touchUpInside)
            
            // wait until the alert popup is shown
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                let alertLabel: UILabel? = sut.viewController.view.findView(with: "AdyenCard.CardComponent.numberItem.alertLabel")
                XCTAssertNotNil(alertLabel)
                XCTAssertEqual(alertLabel?.text, cardNumberView?.item.validationFailureMessage)
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testBigTitle() {
        let cardPaymentMethod = CardPaymentMethod(type: "bcmc", name: "Test name", brands: ["any_test_brand_name"])
        let paymentMethod = BCMCPaymentMethod(cardPaymentMethod: cardPaymentMethod)
        let sut = BCMCComponent(paymentMethod: paymentMethod, publicKey: BCMCComponentTests.randomTestValidCardPublicKey)
        sut.showsLargeTitle = false
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertNil(sut.viewController.view.findView(with: "AdyenCard.CardComponent.Test name"))
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
