//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
@testable import AdyenUIHost
import XCTest

class ComponentManagerTests: XCTestCase {
    
    let dictionary = [
        "storedPaymentMethods": [
            storedCardDictionary,
            storedCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            cardDictionary,
            issuerListDictionary,
            sepaDirectDebitDictionary,
            bcmcCardDictionary,
            applePayDictionary,
            giroPayDictionaryWithOptionalDetails,
            giroPayDictionaryWithNonOptionalDetails,
            weChatQRDictionary,
            weChatSDKDictionary,
            weChatWebDictionary,
            weChatMiniProgramDictionary,
            bcmcMobileQR
        ]
    ]
    
    func testLocalizationWithCustomTableName() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        config.applePay.summaryItems = Configuration.applePaySummaryItems
        config.card.publicKey = RandomStringGenerator.generateDummyCardPublicKey()
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 6)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 4)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        config.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        config.applePay.summaryItems = Configuration.applePaySummaryItems
        config.card.publicKey = RandomStringGenerator.generateDummyCardPublicKey()
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 6)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 4)
    }
    
}
