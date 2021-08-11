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
            econtextOnline,
            oxxo
        ]
    ]

    func testClientKeyInjectionAndProtocolConfromance() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style(),
                                   order: nil)

        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, 16)

        XCTAssertEqual(sut.storedComponents.filter { $0.apiContext.clientKey == Dummy.context.clientKey }.count, 4)
        XCTAssertEqual(sut.regularComponents.filter { $0.apiContext.clientKey == Dummy.context.clientKey }.count, 16)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 12)
        XCTAssertEqual(sut.regularComponents.filter { $0 is Localizable }.count, 11)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 13)
    }
    
    func testLocalizationWithCustomTableName() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style(),
                                   order: nil)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, 16)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 4)
        XCTAssertEqual(sut.regularComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 11)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style(),
                                   order: nil)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, 16)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 4)
        XCTAssertEqual(sut.regularComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 11)
    }

    func testOrderInjection() throws {
        var paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        let merchantIdentifier = "applePayMerchantIdentifier"
        let summaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)]
        config.applePay = .init(summaryItems: summaryItems, merchantIdentifier: merchantIdentifier)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")

        let order = PartialPaymentOrder(pspReference: "test pspRef", orderData: "test order data")

        paymentMethods.paid = [
            OrderPaymentMethod(lastFour: "1234",
                               type: "type-1",
                               transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                               amount: Amount(value: 1234, currencyCode: "EUR")),
            OrderPaymentMethod(lastFour: "1234",
                               type: "type-2",
                               transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                               amount: Amount(value: 1234, currencyCode: "EUR"))
        ]

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   style: DropInComponent.Style(),
                                   order: order)

        XCTAssertEqual(sut.paidComponents.count, 2)
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, 16)

        XCTAssertEqual(sut.paidComponents.filter { $0.order == order }.count, 2)
        XCTAssertEqual(sut.storedComponents.filter { $0.order == order }.count, 4)
        XCTAssertEqual(sut.regularComponents.filter { $0.order == order }.count, 16)
    }
    
}
