//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import AdyenDropIn
@testable import AdyenUIHost

class ComponentManagerTests: XCTestCase {
    
    func testLocalization() throws {
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
                applePayDictionary
            ]
        ]

        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let payment = Payment(amount: Payment.Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let config = DropInComponent.PaymentMethodsConfiguration()
        config.localizationTable = "AdyenUIHost"
        config.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        config.applePay.summaryItems = Configuration.applePaySummaryItems
        config.card.publicKey = RandomStringGenerator.generateDummyCardPublicKey()
        let sut = ComponentManager(paymentMethods: paymentMethods, payment: payment, configuration: config)

        XCTAssertEqual(sut.components.stored.count, 4)
        XCTAssertEqual(sut.components.regular.count, 5)

        XCTAssertEqual(sut.components.stored.compactMap { $0 as? Localizable }.filter { $0.localizationTable == "AdyenUIHost" }.count, 4)
        XCTAssertEqual(sut.components.regular.compactMap { $0 as? Localizable }.filter { $0.localizationTable == "AdyenUIHost" }.count, 4)
    }

}
