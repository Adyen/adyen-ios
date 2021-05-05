//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import PassKit
import XCTest

class ComponentManagerTests: XCTestCase {
    
    let dictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            creditCardDictionary,
            issuerListDictionary,
            issuerListDictionaryWithoutDetailsObject,
            sepaDirectDebitDictionary,
            bcmcCardDictionary,
            applePayDictionary,
            giroPayDictionaryWithOptionalDetails,
            giroPayDictionaryWithNonOptionalDetails,
            weChatQRDictionary,
            weChatSDKDictionary,
            weChatWebDictionary,
            weChatMiniProgramDictionary,
            bcmcMobileQR,
            mbway,
            blik,
            qiwiWallet,
            googlePay,
            dokuWallet,
            econtextStores,
            econtextATM,
            econtextOnline
        ]
    ]

    func testClientKeyInjectionAndProtocolConfromance() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.PaymentMethodsConfiguration(clientKey: Dummy.dummyClientKey)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)
        config.payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style())

        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 15)

        XCTAssertEqual(sut.components.stored.filter { $0.environment.clientKey == Dummy.dummyClientKey }.count, 4)
        XCTAssertEqual(sut.components.regular.filter { $0.environment.clientKey == Dummy.dummyClientKey }.count, 15)

        XCTAssertEqual(sut.components.regular.filter { $0 is LoadingComponent }.count, 12)
        XCTAssertEqual(sut.components.regular.filter { $0 is Localizable }.count, 11)
        XCTAssertEqual(sut.components.regular.filter { $0 is PresentableComponent }.count, 13)
    }
    
    func testLocalizationWithCustomTableName() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.PaymentMethodsConfiguration(clientKey: Dummy.dummyClientKey)
        config.payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 15)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 11)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.PaymentMethodsConfiguration(clientKey: Dummy.dummyClientKey)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)
        config.payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 15)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 11)
    }
    
}
