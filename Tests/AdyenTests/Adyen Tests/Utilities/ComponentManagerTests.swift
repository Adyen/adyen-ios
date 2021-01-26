//
// Copyright (c) 2019 Adyen N.V.
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
            dokuWallet
        ]
    ]

    func testClientKeyInjection() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.applePay.merchantIdentifier = "applePayMerchantIdentifier"
        config.applePay.summaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
        ]
        config.clientKey = "client_key"
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())

        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 12)

        XCTAssertEqual(sut.components.stored.filter { $0.environment.clientKey == "client_key" }.count, 4)
        XCTAssertEqual(sut.components.regular.filter { $0.environment.clientKey == "client_key" }.count, 12)
    }

    func testNoClientKeyAndNoCardPublicKey() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.applePay.merchantIdentifier = "applePayMerchantIdentifier"
        config.applePay.summaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
        ]
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())

        XCTAssertEqual(sut.components.stored.count, 2)
        XCTAssertEqual(sut.components.regular.count, 8)

        XCTAssertEqual(sut.components.stored.filter { $0.environment.clientKey == nil }.count, 2)
        XCTAssertEqual(sut.components.regular.filter { $0.environment.clientKey == nil }.count, 8)
    }

    func testPaymentMethodsThatRequireClientKey() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.applePay.merchantIdentifier = "applePayMerchantIdentifier"
        config.applePay.summaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
        ]
        config.clientKey = nil
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())

        XCTAssertEqual(sut.components.stored.count, 2)
        XCTAssertEqual(sut.components.regular.count, 8)

        XCTAssertFalse(sut.components.regular.contains { $0 is MBWayComponent })
    }
    
    func testLocalizationWithCustomTableName() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.applePay.merchantIdentifier = "applePayMerchantIdentifier"
        config.applePay.summaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
        ]
        config.clientKey = "client_key"
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 12)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 8)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        config.applePay.merchantIdentifier = "applePayMerchantIdentifier"
        config.applePay.summaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
        ]
        config.clientKey = "client_key"
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   payment: payment,
                                   configuration: config,
                                   style: DropInComponent.Style())
        
        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 12)
        
        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 8)
    }
    
}
