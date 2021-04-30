//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class PaymentMethodTests: XCTestCase {
    
    func testDecodingPaymentMethods() throws {
        let dictionary = [
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
                storedDeditCardDictionary,
                storedBlik
            ],
            "paymentMethods": [
                creditCardDictionary,
                issuerListDictionary,
                sepaDirectDebitDictionary,
                [
                    "type": "unknown",
                    "name": "Redirect Payment Method"
                ],
                [
                    "name": "Invalid Payment Method"
                ],
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
                econtextOnline
            ]
        ]
        
        // Stored payment methods
        
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        XCTAssertEqual(paymentMethods.stored.count, 7)
        XCTAssertTrue(paymentMethods.stored[0] is StoredCardPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[1] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[1] as! StoredCardPaymentMethod).fundingSource!, .credit)
        
        // Test StoredCardPaymentMethod localization
        let storedCardPaymentMethod = paymentMethods.stored[1] as! StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(storedCardPaymentMethod.displayInformation,
                       expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: nil))
        XCTAssertEqual(storedCardPaymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters),
                       expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: expectedLocalizationParameters))
        
        XCTAssertTrue(paymentMethods.stored[2] is StoredPayPalPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[2] as! StoredPayPalPaymentMethod).displayInformation.subtitle, "example@shopper.com")
        XCTAssertTrue(paymentMethods.stored[3] is StoredRedirectPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[4] is StoredBCMCPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[5] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[5] as! StoredCardPaymentMethod).fundingSource!, .debit)

        XCTAssertTrue(paymentMethods.stored[6] is StoredBLIKPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[6] as! StoredBLIKPaymentMethod).identifier, "8315892878479934")
        
        // Test StoredBCMCPaymentMethod localization
        let storedBCMCPaymentMethod = paymentMethods.stored[4] as! StoredBCMCPaymentMethod
        XCTAssertEqual(storedBCMCPaymentMethod.displayInformation,
                       expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: nil))
        XCTAssertEqual(storedBCMCPaymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters),
                       expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: expectedLocalizationParameters))
        
        XCTAssertEqual(paymentMethods.stored[3].type, "unknown")
        XCTAssertEqual(paymentMethods.stored[3].name, "Stored Redirect Payment Method")
        
        let storedBancontact = paymentMethods.stored[4] as! StoredBCMCPaymentMethod
        XCTAssertEqual(storedBancontact.type, "bcmc")
        XCTAssertEqual(storedBancontact.brand, "bcmc")
        XCTAssertEqual(storedBancontact.name, "Maestro")
        XCTAssertEqual(storedBancontact.expiryYear, "2020")
        XCTAssertEqual(storedBancontact.expiryMonth, "10")
        XCTAssertEqual(storedBancontact.identifier, "8415736344108917")
        XCTAssertEqual(storedBancontact.holderName, "Checkout Shopper PlaceHolder")
        XCTAssertEqual(storedBancontact.supportedShopperInteractions, [.shopperPresent])
        XCTAssertEqual(storedBancontact.lastFour, "4449")
        
        // Regular payment methods
        
        XCTAssertEqual(paymentMethods.regular.count, 20)
        XCTAssertTrue(paymentMethods.regular[0] is CardPaymentMethod)
        XCTAssertEqual((paymentMethods.regular[0] as! CardPaymentMethod).fundingSource!, .credit)
        
        XCTAssertTrue(paymentMethods.regular[1] is IssuerListPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[2] is SEPADirectDebitPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[3] is RedirectPaymentMethod)
        
        // Uknown redirect
        XCTAssertEqual(paymentMethods.regular[3].type, "unknown")
        XCTAssertEqual(paymentMethods.regular[3].name, "Redirect Payment Method")
        
        // Bancontact
        XCTAssertTrue(paymentMethods.regular[4] is BCMCPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[4].type, "bcmc")
        XCTAssertEqual(paymentMethods.regular[4].name, "Bancontact card")
        
        // Apple Pay
        XCTAssertTrue(paymentMethods.regular[5] is ApplePayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[5].type, "applepay")
        XCTAssertEqual(paymentMethods.regular[5].name, "Apple Pay")
        
        // PayPal
        XCTAssertTrue(paymentMethods.regular[6] is RedirectPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[6].type, "paypal")
        XCTAssertEqual(paymentMethods.regular[6].name, "PayPal")
        
        // GiroPay
        XCTAssertTrue(paymentMethods.regular[7] is RedirectPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[7].type, "giropay")
        XCTAssertEqual(paymentMethods.regular[7].name, "GiroPay")

        // GiroPay with non optional details
        XCTAssertTrue(paymentMethods.regular[8] is RedirectPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[8].type, "giropay")
        XCTAssertEqual(paymentMethods.regular[8].name, "GiroPay with non optional details")
        
        // Qiwi Wallet
        XCTAssertTrue(paymentMethods.regular[9] is QiwiWalletPaymentMethod)
        let qiwiMethod = paymentMethods.regular[9] as! QiwiWalletPaymentMethod
        XCTAssertEqual(qiwiMethod.type, "qiwiwallet")
        XCTAssertEqual(qiwiMethod.name, "Qiwi Wallet")
        XCTAssertEqual(qiwiMethod.phoneExtensions.count, 3)
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].value, "+7")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].value, "+9955")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].value, "+507")
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].countryCode, "RU")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].countryCode, "GE")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].countryCode, "PA")
        
        XCTAssertTrue(paymentMethods.regular[10] is WeChatPayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[10].type, "wechatpaySDK")
        XCTAssertEqual(paymentMethods.regular[10].name, "WeChat Pay")
        
        XCTAssertTrue(paymentMethods.regular[11] is CardPaymentMethod)
        XCTAssertEqual((paymentMethods.regular[11] as! CardPaymentMethod).fundingSource!, .debit)

        XCTAssertTrue(paymentMethods.regular[12] is MBWayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[12].name, "MB WAY")
        XCTAssertEqual(paymentMethods.regular[12].type, "mbway")

        XCTAssertTrue(paymentMethods.regular[13] is BLIKPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[13].name, "Blik")
        XCTAssertEqual(paymentMethods.regular[13].type, "blik")

        XCTAssertTrue(paymentMethods.regular[14] is GiftCardPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[14].name, "Generic GiftCard")
        XCTAssertEqual(paymentMethods.regular[14].type, "giftcard")

        XCTAssertTrue(paymentMethods.regular[15] is DokuPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[15].name, "DOKU wallet")
        XCTAssertEqual(paymentMethods.regular[15].type, "doku_wallet")

        XCTAssertTrue(paymentMethods.regular[16] is SevenElevenPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[16].name, "7-Eleven")
        XCTAssertEqual(paymentMethods.regular[16].type, "econtext_seven_eleven")

        XCTAssertTrue(paymentMethods.regular[17] is EContextATMPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[17].name, "Pay-easy ATM")
        XCTAssertEqual(paymentMethods.regular[17].type, "econtext_atm")

        XCTAssertTrue(paymentMethods.regular[18] is EContextStoresPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[18].name, "Convenience Stores")
        XCTAssertEqual(paymentMethods.regular[18].type, "econtext_stores")

        XCTAssertTrue(paymentMethods.regular[19] is EContextOnlinePaymentMethod)
        XCTAssertEqual(paymentMethods.regular[19].name, "Online Banking")
        XCTAssertEqual(paymentMethods.regular[19].type, "econtext_online")

    }
    
    // MARK: - Card
    
    func testDecodingCreditCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(creditCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource!, .credit)
        XCTAssertEqual(paymentMethod.brands, ["mc", "visa", "amex"])
    }
    
    func testDecodingDeditCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(debitCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource!, .debit)
        XCTAssertEqual(paymentMethod.brands, ["mc", "visa", "amex"])
    }
    
    func testDecodingBCMCCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(bcmcCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        XCTAssertEqual(paymentMethod.brands, [])
    }
    
    func testDecodingCardPaymentMethodWithoutBrands() throws {
        var dictionary = creditCardDictionary
        dictionary.removeValue(forKey: "brands")
        
        let paymentMethod = try Coder.decode(dictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertTrue(paymentMethod.brands.isEmpty)
    }
    
    func testDecodingStoredCreditCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, "visa")
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.fundingSource, .credit)
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        XCTAssertEqual(paymentMethod.displayInformation, expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: nil))
        XCTAssertEqual(paymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
    }
    
    func testDecodingStoredDeditCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedDeditCardDictionary) as StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, "visa")
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.fundingSource, .debit)
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        XCTAssertEqual(paymentMethod.displayInformation, expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: nil))
        XCTAssertEqual(paymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
    }
    
    public func expectedStoredCardPaymentMethodDisplayInfo(method: StoredCardPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        
        return DisplayInformation(title: "••••\u{00a0}" + method.lastFour,
                                  subtitle: localizedString(.cardStoredExpires, localizationParameters, expireDate),
                                  logoName: method.brand)
    }
    
    // MARK: - Issuer List
    
    func testDecodingIssuerListPaymentMethod() throws {
        let paymentMethod = try Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        XCTAssertEqual(paymentMethod.type, "ideal")
        XCTAssertEqual(paymentMethod.name, "iDEAL")
        
        XCTAssertEqual(paymentMethod.issuers.count, 3)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "1121")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Test Issuer 1")
        XCTAssertEqual(paymentMethod.issuers[1].identifier, "1154")
        XCTAssertEqual(paymentMethod.issuers[1].name, "Test Issuer 2")
        XCTAssertEqual(paymentMethod.issuers[2].identifier, "1153")
        XCTAssertEqual(paymentMethod.issuers[2].name, "Test Issuer 3")
    }

    func testDecodingIssuerListPaymentMethodWithoutDetailsObject() throws {
        let paymentMethod = try Coder.decode(issuerListDictionaryWithoutDetailsObject) as IssuerListPaymentMethod
        XCTAssertEqual(paymentMethod.type, "ideal_100")
        XCTAssertEqual(paymentMethod.name, "iDEAL_100")

        XCTAssertEqual(paymentMethod.issuers.count, 3)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "1121")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Test Issuer 1")
        XCTAssertEqual(paymentMethod.issuers[1].identifier, "1154")
        XCTAssertEqual(paymentMethod.issuers[1].name, "Test Issuer 2")
        XCTAssertEqual(paymentMethod.issuers[2].identifier, "1153")
        XCTAssertEqual(paymentMethod.issuers[2].name, "Test Issuer 3")
    }
    
    // MARK: - SEPA Direct Debit
    
    let sepaDirectDebitDictionary = [
        "type": "sepadirectdebit",
        "name": "SEPA Direct Debit"
    ] as [String: Any]
    
    func testDecodingSEPADirectDebitPaymentMethod() throws {
        let paymentMethod = try Coder.decode(sepaDirectDebitDictionary) as SEPADirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type, "sepadirectdebit")
        XCTAssertEqual(paymentMethod.name, "SEPA Direct Debit")
    }
    
    // MARK: - Stored PayPal
    
    func testDecodingPayPalPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        XCTAssertEqual(paymentMethod.type, "paypal")
        XCTAssertEqual(paymentMethod.identifier, "9314881977134903")
        XCTAssertEqual(paymentMethod.name, "PayPal")
        XCTAssertEqual(paymentMethod.emailAddress, "example@shopper.com")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
    }
    
    // MARK: - Apple Pay
    
    func testDecodingApplePayPaymentMethod() throws {
        let paymentMethod = try Coder.decode(applePayDictionary) as ApplePayPaymentMethod
        XCTAssertEqual(paymentMethod.type, "applepay")
        XCTAssertEqual(paymentMethod.name, "Apple Pay")
    }
    
    // MARK: - Bancontact
    
    func testDecodingBancontactPaymentMethod() throws {
        let paymentMethod = try Coder.decode(bcmcCardDictionary) as BCMCPaymentMethod
        XCTAssertEqual(paymentMethod.type, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
    }
    
    // MARK: - GiroPay
    
    func testDecodingGiropayPaymentMethod() throws {
        let paymentMethod = try Coder.decode(giroPayDictionaryWithOptionalDetails) as RedirectPaymentMethod
        XCTAssertEqual(paymentMethod.type, "giropay")
        XCTAssertEqual(paymentMethod.name, "GiroPay")
    }

    // MARK: - Seven Eleven

    func testDecodingSevenElevenPaymentMethod() throws {
        let paymentMethod = try Coder.decode(sevenElevenDictionary) as SevenElevenPaymentMethod
        XCTAssertEqual(paymentMethod.name, "7-Eleven")
        XCTAssertEqual(paymentMethod.type, "econtext_seven_eleven")
    }

    // MARK: - E-Context Online

    func testDecodingEContextOnlinePaymentMethod() throws {
        let paymentMethod = try Coder.decode(econtextOnline) as EContextOnlinePaymentMethod
        XCTAssertEqual(paymentMethod.name, "Online Banking")
        XCTAssertEqual(paymentMethod.type, "econtext_online")
    }

    // MARK: - E-Context ATM

    func testDecodingEContextATMPaymentMethod() throws {
        let paymentMethod = try Coder.decode(econtextATM) as EContextATMPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Pay-easy ATM")
        XCTAssertEqual(paymentMethod.type, "econtext_atm")
    }

    // MARK: - E-Context Stores

    func testDecodingEContextStoresPaymentMethod() throws {
        let paymentMethod = try Coder.decode(econtextStores) as EContextStoresPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Convenience Stores")
        XCTAssertEqual(paymentMethod.type, "econtext_stores")
    }
    
    // MARK: - Stored Bancontact
    
    func testDecodingStoredBancontactPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedBcmcDictionary) as StoredBCMCPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type, "bcmc")
        XCTAssertEqual(paymentMethod.brand, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Maestro")
        XCTAssertEqual(paymentMethod.expiryYear, "2020")
        XCTAssertEqual(paymentMethod.expiryMonth, "10")
        XCTAssertEqual(paymentMethod.identifier, "8415736344108917")
        XCTAssertEqual(paymentMethod.holderName, "Checkout Shopper PlaceHolder")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent])
        XCTAssertEqual(paymentMethod.lastFour, "4449")
        let expectedDisplayInfo = expectedBancontactCardDisplayInfo(method: paymentMethod, localizationParameters: nil)
        XCTAssertEqual(paymentMethod.displayInformation, expectedDisplayInfo)
        XCTAssertEqual(paymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters),
                       expectedBancontactCardDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
    }

    // MARK: - MBWay

    func testDecodingMBWayPaymentMethod() throws {
        let paymentMethod = try Coder.decode(mbway) as MBWayPaymentMethod
        XCTAssertEqual(paymentMethod.type, "mbway")
        XCTAssertEqual(paymentMethod.name, "MB WAY")
    }

    // MARK: - Doku wallet

    func testDecodingDokuWalletPaymentMethod() throws {
        let paymentMethod = try Coder.decode(dokuWallet) as DokuPaymentMethod
        XCTAssertEqual(paymentMethod.type, "doku_wallet")
        XCTAssertEqual(paymentMethod.name, "DOKU wallet")
    }
    
    public func expectedBancontactCardDisplayInfo(method: StoredBCMCPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        
        return DisplayInformation(title: "••••\u{00a0}" + method.lastFour,
                                  subtitle: localizedString(.cardStoredExpires, localizationParameters, expireDate),
                                  logoName: method.brand)
    }

    // MARK: - GiftCard

    func testDecodingGiftCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(giftCard) as GiftCardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "giftcard")
        XCTAssertEqual(paymentMethod.name, "Generic GiftCard")
        XCTAssertEqual(paymentMethod.displayInformation.logoName, "genericgiftcard")
        XCTAssertEqual(paymentMethod.localizedDisplayInformation(using: nil).logoName, "genericgiftcard")
    }
}

internal extension Coder {
    
    static func decode<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        return try decode(data)
    }
    
}
