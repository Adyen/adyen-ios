//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import AdyenComponents
import XCTest

class PaymentMethodTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        AdyenAssertion.listener = nil
    }
    
    private var paymentMethodsDictionary: [String: Any] {
        [
            "storedPaymentMethods": [
                storedCreditCardDictionary,
                storedCreditCardDictionary,
                storedPayPalDictionary,
                [
                    "type": "unknown",
                    "id": "9314881977134903",
                    "name": "Stored Redirect Payment Method",
                    "supportedShopperInteractions": ["Ecommerce"]
                ],
                [
                    "type": "unknown",
                    "name": "Invalid Stored Payment Method"
                ],
                storedBcmcDictionary,
                storedDebitCardDictionary,
                storedBlik,
                storedACHDictionary,
                storedPayToDictionary
            ],
            "paymentMethods": [
                creditCardDictionary,
                issuerListDictionary,
                sepaDirectDebitDictionary,
                [
                    "type": "unknown",
                    "name": "Redirect Payment Method"
                ],
                ["name": "Invalid Payment Method"],
                bcmcCardDictionary,
                applePayDictionary,
                payPalDictionary,
                giroPayDictionaryWithOptionalDetails,
                giroPayDictionaryWithNonOptionalDetails,
                weChatQRDictionary,
                weChatWebDictionary,
                weChatMiniProgramDictionary,
                bcmcMobileQR,
                qiwiWallet,
                weChatSDKDictionary,
                debitCardDictionary,
                mbway,
                blik,
                giftCard,
                googlePay,
                dokuWallet,
                sevenElevenDictionary,
                econtextATM,
                econtextStores,
                econtextOnline,
                oxxo,
                achDirectDebit,
                bacsDirectDebit,
                giftCard1,
                givexGiftCard,
                mealVoucherSodexo,
                boletoBancario,
                boletoBancarioSantander,
                primeiroPayBoleto,
                boletoBancarioItau,
                affirm,
                atome,
                upi,
                cashAppPay,
                idealDictionary,
                payto,
                irisDictionary,
                bizum,
                payByBankGeneric,
                payByBankIssuerList
            ]
        ]
    }
    
    private func getPaymentMethods() throws -> PaymentMethods {
        try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }
    
    // MARK: - Payment Methods
    
    func test_paymentMethodsCoding() throws {
        let paymentMethods: PaymentMethods = try getPaymentMethods()
        
        let encodedPaymentMethods: Data = try AdyenCoder.encode(paymentMethods)
        let decodedPaymentMethods: PaymentMethods = try AdyenCoder.decode(encodedPaymentMethods)
        
        XCTAssertEqual(paymentMethods, decodedPaymentMethods)
    }
    
    func test_decodingPaymentMethods() throws {
        // Stored payment methods
        
        let paymentMethods = try getPaymentMethods()
        
        XCTAssertEqual(paymentMethods.stored.count, 9)
        XCTAssertTrue(paymentMethods.stored[0] is StoredCardPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[1] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[1] as? StoredCardPaymentMethod)?.fundingSource, .credit)
        
        // Test StoredCardPaymentMethod localization
        var storedCardPaymentMethod = try XCTUnwrap(paymentMethods.stored[1] as? StoredCardPaymentMethod)
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(
            storedCardPaymentMethod.displayInformation(using: expectedLocalizationParameters),
            expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: expectedLocalizationParameters)
        )
        
        XCTAssertTrue(paymentMethods.stored[2] is StoredPayPalPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[2] as? StoredPayPalPaymentMethod)?.displayInformation(using: expectedLocalizationParameters).subtitle, "example@shopper.com")
        XCTAssertTrue(paymentMethods.stored[3] is StoredGenericPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[4] is StoredBCMCPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[5] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[5] as? StoredCardPaymentMethod)?.fundingSource, .debit)

        XCTAssertTrue(paymentMethods.stored[6] is StoredBLIKPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[6] as? StoredBLIKPaymentMethod)?.identifier, "8315892878479934")
        
        XCTAssertTrue(paymentMethods.stored[7] is StoredACHDirectDebitPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[7] as? StoredACHDirectDebitPaymentMethod)?.identifier, "CWG8SF2PR2M84H82")
        
        XCTAssertTrue(paymentMethods.stored[8] is StoredPayToPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[8] as? StoredPayToPaymentMethod)?.identifier, "CM3QNF29XWNZJMV5")
        
        // Test StoredBCMCPaymentMethod localization
        var storedBCMCPaymentMethod = try XCTUnwrap(paymentMethods.stored[4] as? StoredBCMCPaymentMethod)
        XCTAssertEqual(
            storedBCMCPaymentMethod.displayInformation(using: nil),
            expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: nil)
        )
        XCTAssertEqual(
            storedBCMCPaymentMethod.displayInformation(using: expectedLocalizationParameters),
            expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: expectedLocalizationParameters)
        )
        
        XCTAssertEqual(paymentMethods.stored[3].type.rawValue, "unknown")
        XCTAssertEqual(paymentMethods.stored[3].name, "Stored Redirect Payment Method")
        
        let storedBancontact = try XCTUnwrap(paymentMethods.stored[4] as? StoredBCMCPaymentMethod)
        XCTAssertEqual(storedBancontact.type.rawValue, "bcmc")
        XCTAssertEqual(storedBancontact.brand, "bcmc")
        XCTAssertEqual(storedBancontact.name, "Maestro")
        XCTAssertEqual(storedBancontact.expiryYear, "2020")
        XCTAssertEqual(storedBancontact.expiryMonth, "10")
        XCTAssertEqual(storedBancontact.identifier, "8415736344108917")
        XCTAssertEqual(storedBancontact.holderName, "Checkout Shopper PlaceHolder")
        XCTAssertEqual(storedBancontact.supportedShopperInteractions, [.shopperPresent])
        XCTAssertEqual(storedBancontact.lastFour, "4449")
        
        // Regular payment methods
        
        XCTAssertEqual(paymentMethods.regular.count, 40)

        let creditCardPaymentMethod = try XCTUnwrap(paymentMethods.regular[0] as? CardPaymentMethod)
        XCTAssertEqual(creditCardPaymentMethod.fundingSource, .credit)
        
        XCTAssertTrue(paymentMethods.regular[1] is IssuerListPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[1].type.rawValue, "onlineBanking_PL")
        XCTAssertEqual(paymentMethods.regular[1].name, "Online Banking")
        
        XCTAssertTrue(paymentMethods.regular[2] is SEPADirectDebitPaymentMethod)
        
        // Unknown redirect
        XCTAssertTrue(paymentMethods.regular[3] is GenericPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[3].type.rawValue, "unknown")
        XCTAssertEqual(paymentMethods.regular[3].name, "Redirect Payment Method")
        
        // Bancontact
        XCTAssertTrue(paymentMethods.regular[4] is BCMCPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[4].type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethods.regular[4].name, "Bancontact card")
        
        // Apple Pay
        XCTAssertTrue(paymentMethods.regular[5] is ApplePayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[5].type.rawValue, "applepay")
        XCTAssertEqual(paymentMethods.regular[5].name, "Apple Pay")
        
        // PayPal
        XCTAssertTrue(paymentMethods.regular[6] is GenericPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[6].type.rawValue, "paypal")
        XCTAssertEqual(paymentMethods.regular[6].name, "PayPal")
        
        // GiroPay
        XCTAssertTrue(paymentMethods.regular[7] is GenericPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[7].type.rawValue, "giropay")
        XCTAssertEqual(paymentMethods.regular[7].name, "GiroPay")

        // GiroPay with non optional details
        XCTAssertTrue(paymentMethods.regular[8] is GenericPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[8].type.rawValue, "giropay")
        XCTAssertEqual(paymentMethods.regular[8].name, "GiroPay with non optional details")
        
        // Qiwi Wallet
        let qiwiMethod = try XCTUnwrap(paymentMethods.regular[9] as? QiwiWalletPaymentMethod)
        XCTAssertEqual(qiwiMethod.type.rawValue, "qiwiwallet")
        XCTAssertEqual(qiwiMethod.name, "Qiwi Wallet")
        XCTAssertEqual(qiwiMethod.phoneExtensions.count, 3)
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].value, "+7")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].value, "+9955")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].value, "+507")
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].countryCode, "RU")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].countryCode, "GE")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].countryCode, "PA")
        
        XCTAssertTrue(paymentMethods.regular[10] is WeChatPayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[10].type.rawValue, "wechatpaySDK")
        XCTAssertEqual(paymentMethods.regular[10].name, "WeChat Pay")
        
        let debitCardPaymentMethod = try XCTUnwrap(paymentMethods.regular[11] as? CardPaymentMethod)
        XCTAssertEqual(debitCardPaymentMethod.fundingSource, .debit)

        XCTAssertTrue(paymentMethods.regular[12] is MBWayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[12].name, "MB WAY")
        XCTAssertEqual(paymentMethods.regular[12].type.rawValue, "mbway")

        XCTAssertTrue(paymentMethods.regular[13] is BLIKPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[13].name, "Blik")
        XCTAssertEqual(paymentMethods.regular[13].type.rawValue, "blik")

        XCTAssertTrue(paymentMethods.regular[14] is GiftCardPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[14].name, "Generic GiftCard")
        XCTAssertEqual(paymentMethods.regular[14].type.rawValue, "giftcard")

        XCTAssertTrue(paymentMethods.regular[15] is DokuPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[15].name, "DOKU wallet")
        XCTAssertEqual(paymentMethods.regular[15].type.rawValue, "doku_wallet")

        XCTAssertTrue(paymentMethods.regular[16] is SevenElevenPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[16].name, "7-Eleven")
        XCTAssertEqual(paymentMethods.regular[16].type.rawValue, "econtext_seven_eleven")

        XCTAssertTrue(paymentMethods.regular[17] is EContextPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[17].name, "Pay-easy ATM")
        XCTAssertEqual(paymentMethods.regular[17].type.rawValue, "econtext_atm")

        XCTAssertTrue(paymentMethods.regular[18] is EContextPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[18].name, "Convenience Stores")
        XCTAssertEqual(paymentMethods.regular[18].type.rawValue, "econtext_stores")

        XCTAssertTrue(paymentMethods.regular[19] is EContextPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[19].name, "Online Banking")
        XCTAssertEqual(paymentMethods.regular[19].type.rawValue, "econtext_online")
        
        XCTAssertTrue(paymentMethods.regular[20] is OXXOPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[20].name, "OXXO")
        XCTAssertEqual(paymentMethods.regular[20].type.rawValue, "oxxo")
        
        XCTAssertTrue(paymentMethods.regular[21] is ACHDirectDebitPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[21].name, "ACH Direct Debit")
        XCTAssertEqual(paymentMethods.regular[21].type.rawValue, "ach")
        
        XCTAssertTrue(paymentMethods.regular[22] is BACSDirectDebitPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[22].name, "BACS Direct Debit")
        XCTAssertEqual(paymentMethods.regular[22].type.rawValue, "directdebit_GB")
        
        XCTAssertTrue(paymentMethods.regular[23] is GiftCardPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[23].name, "GiftFor2")
        XCTAssertEqual(paymentMethods.regular[23].type.rawValue, "giftcard")
        
        XCTAssertTrue(paymentMethods.regular[24] is GiftCardPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[24].name, "Givex")
        XCTAssertEqual(paymentMethods.regular[24].type.rawValue, "giftcard")
        
        XCTAssertTrue(paymentMethods.regular[25] is MealVoucherPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[25].name, "Sodexo")
        XCTAssertEqual(paymentMethods.regular[25].type.rawValue, "mealVoucher_FR_sodexo")
        
        XCTAssertTrue(paymentMethods.regular[26] is BoletoPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[26].name, "Boleto Bancario")
        XCTAssertEqual(paymentMethods.regular[26].type.rawValue, "boletobancario")

        XCTAssertTrue(paymentMethods.regular[27] is BoletoPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[27].name, "Boleto Bancario")
        XCTAssertEqual(paymentMethods.regular[27].type.rawValue, "boletobancario_santander")

        XCTAssertTrue(paymentMethods.regular[28] is BoletoPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[28].name, "Boleto Bancario")
        XCTAssertEqual(paymentMethods.regular[28].type.rawValue, "primeiropay_boleto")

        XCTAssertTrue(paymentMethods.regular[29] is BoletoPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[29].name, "Boleto Bancario")
        XCTAssertEqual(paymentMethods.regular[29].type.rawValue, "boletobancario_itau")

        XCTAssertTrue(paymentMethods.regular[30] is AffirmPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[30].name, "Affirm")
        XCTAssertEqual(paymentMethods.regular[30].type.rawValue, "affirm")

        XCTAssertTrue(paymentMethods.regular[31] is AtomePaymentMethod)
        XCTAssertEqual(paymentMethods.regular[31].name, "Atome")
        XCTAssertEqual(paymentMethods.regular[31].type.rawValue, "atome")

        XCTAssertTrue(paymentMethods.regular[32] is UPIPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[32].name, "UPI")
        XCTAssertEqual(paymentMethods.regular[32].type.rawValue, "upi")

        let cashAppPay = try XCTUnwrap(paymentMethods.regular[33] as? CashAppPayPaymentMethod)
        XCTAssertEqual(cashAppPay.name, "Cash App Pay")
        XCTAssertEqual(cashAppPay.type.rawValue, "cashapp")
        XCTAssertEqual(cashAppPay.clientId, "testClient")
        XCTAssertEqual(cashAppPay.scopeId, "testScope")
        
        let iDealPaymentMethod = try XCTUnwrap(paymentMethods.regular[34] as? GenericPaymentMethod)
        XCTAssertEqual(iDealPaymentMethod.type, .ideal)
        XCTAssertEqual(iDealPaymentMethod.name, "iDeal")

        let payToPaymentMethod = try XCTUnwrap(paymentMethods.regular[35] as? PayToPaymentMethod)
        XCTAssertEqual(payToPaymentMethod.type.rawValue, "payto")
        XCTAssertEqual(payToPaymentMethod.name, "payto")

        let irisPaymentMethod = try XCTUnwrap(paymentMethods.regular[36] as? GenericPaymentMethod)
        XCTAssertEqual(irisPaymentMethod.type.rawValue, "iris")
        XCTAssertEqual(irisPaymentMethod.name, "IRIS")

        let bizumPaymentMethod = try XCTUnwrap(paymentMethods.regular[37] as? GenericPaymentMethod)
        XCTAssertEqual(bizumPaymentMethod.type.rawValue, "bizum")
        XCTAssertEqual(bizumPaymentMethod.name, "Bizum")
    }
    
    // MARK: - Misc

    func test_decodingPaymentMethods_withNullValues() throws {

        let json = """
        {
            "storedPaymentMethods": null,
            "paymentMethods": [
                {
                    "brand": null,
                    "brands": [
                        "visa",
                        "mc",
                        "diners",
                        "discover",
                        "maestro"
                    ],
                    "issuers": null,
                    "configuration": null,
                    "fundingSource": null,
                    "group": null,
                    "inputDetails": null,
                    "name": "Card payment",
                    "type": "scheme"
                }
            ]
        }
        """

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: XCTUnwrap(json.data(using: .utf8)))
        XCTAssertEqual(paymentMethods.regular.count, 1)
        XCTAssertEqual(paymentMethods.stored.count, 0)
        XCTAssertTrue(paymentMethods.regular[0] is CardPaymentMethod)
    }
    
    func test_equality() {
        XCTAssertFalse(
            BLIKPaymentMethod(type: .blik, name: "blik") ==
                StoredBLIKPaymentMethod(
                    type: .blik,
                    name: "blik",
                    identifier: "efefew",
                    supportedShopperInteractions: [.shopperNotPresent]
                )
        )
        XCTAssertFalse(
            StoredPayPalPaymentMethod(
                type: .payPal,
                name: "payPal",
                identifier: "12334",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                GenericPaymentMethod(type: .payPal, name: "payPal")
        )
        XCTAssertTrue(
            StoredPayPalPaymentMethod(
                type: .payPal,
                name: "payPal",
                identifier: "12334",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                StoredPayPalPaymentMethod(
                    type: .payPal,
                    name: "payPal",
                    identifier: "12334",
                    supportedShopperInteractions: [.shopperPresent],
                    emailAddress: "email"
                )
        )
        XCTAssertFalse(
            StoredPayPalPaymentMethod(
                type: .payPal,
                name: "payPal",
                identifier: "XXX",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                StoredPayPalPaymentMethod(
                    type: .payPal,
                    name: "payPal",
                    identifier: "12334",
                    supportedShopperInteractions: [.shopperPresent],
                    emailAddress: "email"
                )
        )
        XCTAssertFalse(
            StoredPayPalPaymentMethod(
                type: .other("payPalx"),
                name: "payPal",
                identifier: "XXX",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                StoredPayPalPaymentMethod(
                    type: .payPal,
                    name: "payPal",
                    identifier: "12334",
                    supportedShopperInteractions: [.shopperPresent],
                    emailAddress: "email"
                )
        )
        XCTAssertFalse(
            StoredPayPalPaymentMethod(
                type: .payPal,
                name: "payPal",
                identifier: "XXX",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                StoredPayPalPaymentMethod(
                    type: .payPal,
                    name: "payPal",
                    identifier: "12334",
                    supportedShopperInteractions: [.shopperNotPresent],
                    emailAddress: "email"
                )
        )
        XCTAssertFalse(
            StoredPayPalPaymentMethod(
                type: .payPal,
                name: "payPal",
                identifier: "payPal_id",
                supportedShopperInteractions: [.shopperPresent],
                emailAddress: "email"
            ) ==
                StoredBLIKPaymentMethod(
                    type: .payPal,
                    name: "payPal",
                    identifier: "payPal_id",
                    supportedShopperInteractions: [.shopperPresent]
                )
        )
    }
    
    // MARK: - Card
    
    func test_decodingCreditCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource, .credit)
        XCTAssertEqual(paymentMethod.brands, [.masterCard, .visa, .americanExpress])
        testCoding(paymentMethod)
    }
    
    func test_decodingDebitCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(debitCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource, .debit)
        XCTAssertEqual(paymentMethod.brands, [.masterCard, .visa, .americanExpress])
        testCoding(paymentMethod)
    }
    
    func test_decodingBCMCCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bcmcCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        XCTAssertEqual(paymentMethod.brands, [])
        testCoding(paymentMethod)
    }
    
    func test_decodingCardPaymentMethod_withoutBrands() throws {
        var dictionary = creditCardDictionary
        dictionary.removeValue(forKey: "brands")
        
        let paymentMethod = try AdyenCoder.decode(dictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertTrue(paymentMethod.brands.isEmpty)
        testCoding(paymentMethod)
    }
    
    func test_decodingStoredCreditCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, .visa)
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.fundingSource, .credit)
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        XCTAssertEqual(paymentMethod.displayInformation(using: nil), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: nil))
        XCTAssertEqual(paymentMethod.displayInformation(using: expectedLocalizationParameters), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
        testCoding(paymentMethod)
    }
    
    func test_decodingStoredDebitCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedDebitCardDictionary) as StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, .visa)
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.fundingSource, .debit)
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        XCTAssertEqual(paymentMethod.displayInformation(using: nil), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: nil))
        XCTAssertEqual(paymentMethod.displayInformation(using: expectedLocalizationParameters), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
        testCoding(paymentMethod)
    }
    
    func expectedStoredCardPaymentMethodDisplayInfo(method: StoredCardPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let accessibilityLabel = "\(method.name), Last 4 digits: \(method.lastFour.map { String($0) }.joined(separator: ", "))"

        return DisplayInformation(
            title: String.Adyen.securedString + method.lastFour,
            subtitle: method.name,
            logoName: method.brand.rawValue,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    // MARK: - Issuer List
    
    func test_decodingIssuerListPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "onlineBanking_PL")
        XCTAssertEqual(paymentMethod.name, "Online Banking")
        
        XCTAssertEqual(paymentMethod.issuers.count, 3)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Test Issuer 1")
        XCTAssertEqual(paymentMethod.issuers[1].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[1].name, "Test Issuer 2")
        XCTAssertEqual(paymentMethod.issuers[2].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[2].name, "Test Issuer 3")
        
        testCoding(paymentMethod)
    }

    func test_decodingIssuerListPaymentMethod_withoutDetailsObject() throws {
        let paymentMethod = try AdyenCoder.decode(issuerListDictionaryWithoutDetailsObject) as IssuerListPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ideal_100")
        XCTAssertEqual(paymentMethod.name, "iDEAL_100")

        XCTAssertEqual(paymentMethod.issuers.count, 3)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "1121")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Test Issuer 1")
        XCTAssertEqual(paymentMethod.issuers[1].identifier, "1154")
        XCTAssertEqual(paymentMethod.issuers[1].name, "Test Issuer 2")
        XCTAssertEqual(paymentMethod.issuers[2].identifier, "1153")
        XCTAssertEqual(paymentMethod.issuers[2].name, "Test Issuer 3")
        
        testCoding(paymentMethod)
    }
    
    // MARK: - SEPA Direct Debit
    
    let sepaDirectDebitDictionary = [
        "type": "sepadirectdebit",
        "name": "SEPA Direct Debit"
    ] as [String: Any]
    
    func test_decodingSEPADirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(sepaDirectDebitDictionary) as SEPADirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "sepadirectdebit")
        XCTAssertEqual(paymentMethod.name, "SEPA Direct Debit")
        testCoding(paymentMethod)
    }
    
    // MARK: - Stored PayPal
    
    func test_decodingPayPalPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "paypal")
        XCTAssertEqual(paymentMethod.identifier, "9314881977134903")
        XCTAssertEqual(paymentMethod.name, "PayPal")
        XCTAssertEqual(paymentMethod.emailAddress, "example@shopper.com")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        testCoding(paymentMethod)
    }
    
    // MARK: - Apple Pay
    
    func test_decodingApplePayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(applePayDictionary) as ApplePayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "applepay")
        XCTAssertEqual(paymentMethod.name, "Apple Pay")
        testCoding(paymentMethod)
    }
    
    // MARK: - Bancontact
    
    func test_decodingBancontactPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bcmcCardDictionary) as BCMCPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        testCoding(paymentMethod)
    }
    
    // MARK: - GiroPay
    
    func test_decodingGiropayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(giroPayDictionaryWithOptionalDetails) as GenericPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "giropay")
        XCTAssertEqual(paymentMethod.name, "GiroPay")
        testCoding(paymentMethod)
    }

    // MARK: - Seven Eleven

    func test_decodingSevenElevenPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(sevenElevenDictionary) as SevenElevenPaymentMethod
        XCTAssertEqual(paymentMethod.name, "7-Eleven")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_seven_eleven")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context Online

    func test_decodingEContextOnlinePaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextOnline) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Online Banking")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_online")
        testCoding(paymentMethod)
    }
    
    // MARK: - OXXO

    func test_decodingOXXOPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(oxxo) as OXXOPaymentMethod
        XCTAssertEqual(paymentMethod.name, "OXXO")
        XCTAssertEqual(paymentMethod.type.rawValue, "oxxo")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context ATM

    func test_decodingEContextATMPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextATM) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Pay-easy ATM")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_atm")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context Stores

    func test_decodingEContextStoresPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextStores) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Convenience Stores")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_stores")
        testCoding(paymentMethod)
    }
    
    // MARK: - Stored Bancontact
    
    func test_decodingStoredBancontactPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedBcmcDictionary) as StoredBCMCPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethod.brand, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Maestro")
        XCTAssertEqual(paymentMethod.expiryYear, "2020")
        XCTAssertEqual(paymentMethod.expiryMonth, "10")
        XCTAssertEqual(paymentMethod.identifier, "8415736344108917")
        XCTAssertEqual(paymentMethod.holderName, "Checkout Shopper PlaceHolder")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent])
        XCTAssertEqual(paymentMethod.lastFour, "4449")
        let expectedDisplayInfo = expectedBancontactCardDisplayInfo(method: paymentMethod, localizationParameters: nil)
        XCTAssertEqual(paymentMethod.displayInformation(using: nil), expectedDisplayInfo)
        XCTAssertEqual(
            paymentMethod.displayInformation(using: expectedLocalizationParameters),
            expectedBancontactCardDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters)
        )
        testCoding(paymentMethod)
    }

    // MARK: - MBWay

    func test_decodingMBWayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(mbway) as MBWayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "mbway")
        XCTAssertEqual(paymentMethod.name, "MB WAY")
        testCoding(paymentMethod)
    }

    // MARK: - Doku wallet

    func test_decodingDokuWalletPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(dokuWallet) as DokuPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "doku_wallet")
        XCTAssertEqual(paymentMethod.name, "DOKU wallet")
        testCoding(paymentMethod)
    }
    
    func expectedBancontactCardDisplayInfo(
        method: StoredBCMCPaymentMethod,
        localizationParameters: LocalizationParameters?
    ) -> DisplayInformation {
        let accessibilityLabel = "\(method.name), Last 4 digits: \(method.lastFour.map { String($0) }.joined(separator: ", "))"

        return DisplayInformation(
            title: String.Adyen.securedString + method.lastFour,
            subtitle: method.name,
            logoName: method.brand,
            accessibilityLabel: accessibilityLabel
        )
    }

    // MARK: - GiftCard

    func test_decodingGiftCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(giftCard) as GiftCardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "giftcard")
        XCTAssertEqual(paymentMethod.name, "Generic GiftCard")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Generic GiftCard")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "genericgiftcard")
        testCoding(paymentMethod)
    }
    
    func test_decodingMealVoucherPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(mealVoucherSodexo) as MealVoucherPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "mealVoucher_FR_sodexo")
        XCTAssertEqual(paymentMethod.name, "Sodexo")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Sodexo")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "mealVoucher_FR_sodexo")
        testCoding(paymentMethod)
    }
    
    // MARK: - Boleto

    func test_decodingBoletoBancarioPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(boletoBancario) as BoletoPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "boletobancario")
        XCTAssertEqual(paymentMethod.name, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "boletobancario")
        testCoding(paymentMethod)
    }

    func test_decodingBoletoBancarioSantanderPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(boletoBancarioSantander) as BoletoPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "boletobancario_santander")
        XCTAssertEqual(paymentMethod.name, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "boletobancario_santander")
        testCoding(paymentMethod)
    }

    func test_decodingBoletoBancarioItauPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(boletoBancarioItau) as BoletoPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "boletobancario_itau")
        XCTAssertEqual(paymentMethod.name, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "boletobancario_itau")
        testCoding(paymentMethod)
    }

    func test_decodingPrimeiroPayBoletoPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(primeiroPayBoleto) as BoletoPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "primeiropay_boleto")
        XCTAssertEqual(paymentMethod.name, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "primeiropay_boleto")
        testCoding(paymentMethod)
    }

    // MARK: - BACS Direct Debit

    func test_decodingBACSDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bacsDirectDebit) as BACSDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "directdebit_GB")
        XCTAssertEqual(paymentMethod.name, "BACS Direct Debit")
        testCoding(paymentMethod)
    }

    // MARK: - ACH Direct Debit

    func test_decodingACHDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(achDirectDebit) as ACHDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ach")
        XCTAssertEqual(paymentMethod.name, "ACH Direct Debit")
        testCoding(paymentMethod)
    }
    
    func test_decodingStoredACHDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedACHDictionary) as StoredACHDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ach")
        XCTAssertEqual(paymentMethod.name, "ACH Direct Debit")
        XCTAssertEqual(paymentMethod.bankAccountNumber, "123456789")
        testCoding(paymentMethod)
    }
    
    // MARK: - Cash App
    
    func test_decodingCashAppPayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(cashAppPay) as CashAppPayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "cashapp")
        XCTAssertEqual(paymentMethod.name, "Cash App Pay")
        testCoding(paymentMethod)
    }
    
    // MARK: - Qiwi App
    
    func test_decodingQiwiPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(qiwiWallet) as QiwiWalletPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "qiwiwallet")
        XCTAssertEqual(paymentMethod.name, "Qiwi Wallet")
        testCoding(paymentMethod)
    }
    
    // MARK: PayTo
    
    func test_decodingPayToPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(payto) as PayToPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "payto")
        XCTAssertEqual(paymentMethod.name, "payto")
        testCoding(paymentMethod)
    }
    
    func test_decodingStoredPayToPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedPayToDictionary) as StoredPayToPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "payto")
        XCTAssertEqual(paymentMethod.name, "payto")
        XCTAssertEqual(paymentMethod.label, "•••••••2311")
        testCoding(paymentMethod)
    }
    
    // MARK: - PaymentMethodDetails
    
    func test_checkoutAttemptId_missingImplementation_on_concreteType() {
        
        class DummyPaymentMethodDetails: PaymentMethodDetails {
            var sdkData: String?
        }
        
        var dummy = DummyPaymentMethodDetails()
        
        let expectation = expectation(description: "Access expectation")
        expectation.expectedFulfillmentCount = 2
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "`@_spi(AdyenInternal) var checkoutAttemptId: String?` needs to be provided on `DummyPaymentMethodDetails`")
            expectation.fulfill()
        }
        
        // set
        dummy.checkoutAttemptId = ""
        // get
        _ = dummy.checkoutAttemptId
        
        wait(for: [expectation], timeout: 10)
    }
    
    // MARK: - Pay by Bank
    
    func test_decodingPayByBankPaymentMethod_withoutIssuers_decodesAsGeneric() throws {
        // Germany variant - no issuer selection
        let paymentMethods = try AdyenCoder.decode([
            "paymentMethods": [payByBankGeneric]
        ]) as PaymentMethods
        
        let paymentMethod = try XCTUnwrap(paymentMethods.regular.first as? GenericPaymentMethod)
        XCTAssertEqual(paymentMethod.type, .payByBank)
        XCTAssertEqual(paymentMethod.name, "Pay by Bank")
    }
    
    func test_decodingPayByBankPaymentMethod_withIssuers_decodesAsIssuerList() throws {
        // UK variant - with issuer selection
        let paymentMethods = try AdyenCoder.decode([
            "paymentMethods": [payByBankIssuerList]
        ]) as PaymentMethods
        
        let paymentMethod = try XCTUnwrap(paymentMethods.regular.first as? IssuerListPaymentMethod)
        XCTAssertEqual(paymentMethod.type, .payByBank)
        XCTAssertEqual(paymentMethod.name, "Pay by Bank")
        XCTAssertEqual(paymentMethod.issuers.count, 4)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "uk-demobank-open-banking-handoff")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Tink Demo Bank")
    }
    
    // MARK: - Stored Payment Method Presentation

    func test_storedPaymentMethodDisplayInformation_matchesSharedPresentation() throws {
        let cashAppPay = try AdyenCoder.decode([
            "type": "cashapp",
            "id": "cash-app-id",
            "name": "Cash App Pay",
            "cashtag": "$shopper",
            "supportedShopperInteractions": ["Ecommerce"]
        ]) as StoredCashAppPayPaymentMethod
        let payByBank = try AdyenCoder.decode([
            "type": "paybybank",
            "id": "pay-by-bank-id",
            "name": "Pay by Bank US",
            "label": "Primary checking",
            "supportedShopperInteractions": ["Ecommerce"]
        ]) as StoredPayByBankUSPaymentMethod
        let payByBankWithoutLabel = try AdyenCoder.decode([
            "type": "paybybank",
            "id": "pay-by-bank-no-label-id",
            "name": "Pay by Bank US",
            "supportedShopperInteractions": ["Ecommerce"]
        ]) as StoredPayByBankUSPaymentMethod
        let payTo = try AdyenCoder.decode(storedPayToDictionary) as StoredPayToPaymentMethod
        let ach = try AdyenCoder.decode(storedACHDictionary) as StoredACHDirectDebitPaymentMethod
        let payPal = try AdyenCoder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        let generic = try AdyenCoder.decode([
            "type": "custom",
            "id": "generic-id",
            "name": "Generic payment method",
            "supportedShopperInteractions": ["Ecommerce"]
        ]) as StoredGenericPaymentMethod

        assertDisplayInformation(cashAppPay, title: "$shopper", subtitle: "Cash App Pay", logoName: "cashapp")
        assertDisplayInformation(payByBank, title: "Primary checking", subtitle: "Pay by Bank US", logoName: "paybybank")
        assertDisplayInformation(payByBankWithoutLabel, title: "", subtitle: "Pay by Bank US", logoName: "paybybank")
        assertDisplayInformation(payTo, title: "•••••••2311", subtitle: "payto", logoName: "payto")
        assertDisplayInformation(ach, title: String.Adyen.securedString + "6789", subtitle: "ACH Direct Debit", logoName: "ach")
        assertDisplayInformation(payPal, title: "PayPal", subtitle: nil, logoName: "paypal")
        assertDisplayInformation(generic, title: "Generic payment method", subtitle: nil, logoName: "custom")
    }

    // MARK: - Accessibility
    
    func test_paymentMethodTypeName() {
      
        [
            PaymentMethodType.openBankingUK: "open banking UK",
            PaymentMethodType.ideal: "ideal",
            PaymentMethodType.onlineBankingPoland: "online banking Poland",
            PaymentMethodType.onlineBankingCZ: "online banking Czechia",
            PaymentMethodType.onlineBankingSK: "online banking Slovakia"
        ].forEach {
            XCTAssertEqual($0.key.name, $0.value)
        }
    }
}

private extension PaymentMethodTests {
    
    func assertDisplayInformation(
        _ paymentMethod: any StoredPaymentMethod,
        title: String,
        subtitle: String?,
        logoName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let displayInformation = paymentMethod.displayInformation(using: nil)
        XCTAssertEqual(displayInformation.title, title, file: file, line: line)
        XCTAssertEqual(displayInformation.subtitle, subtitle, file: file, line: line)
        XCTAssertEqual(displayInformation.logoName, logoName, file: file, line: line)
    }

    func testCoding<T: PaymentMethod>(_ paymentMethod: T) {
        do {
            let encoded: Data = try AdyenCoder.encode(paymentMethod)
            let decoded: T = try AdyenCoder.decode(encoded)
            
            // Re-Encode to compare if the data is still the same after the roundtrip
            let reEncoded: Data = try AdyenCoder.encode(decoded)
            
            XCTAssertEqual(
                String(data: encoded, encoding: .utf8),
                String(data: reEncoded, encoding: .utf8)
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
