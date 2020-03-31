//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class PaymentMethodTests: XCTestCase {
    
    func testDecodingPaymentMethods() throws {
        let dictionary = [
            "storedPaymentMethods": [
                storedCardDictionary,
                storedCardDictionary,
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
                storedBcmcDictionary
            ],
            "paymentMethods": [
                cardDictionary,
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
                weChatSDKDictionary
            ]
        ]
        
        // Stored payment methods
        
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        XCTAssertEqual(paymentMethods.stored.count, 5)
        XCTAssertTrue(paymentMethods.stored[0] is StoredCardPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[1] is StoredCardPaymentMethod)
        
        // Test StoredCardPaymentMethod localization
        let storedCardPaymentMethod = paymentMethods.stored[1] as! StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(storedCardPaymentMethod.displayInformation,
                       expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: nil))
        XCTAssertEqual(storedCardPaymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters),
                       expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: expectedLocalizationParameters))
        
        XCTAssertTrue(paymentMethods.stored[2] is StoredPayPalPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[3] is StoredRedirectPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[4] is StoredBCMCPaymentMethod)
        
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
        
        XCTAssertEqual(paymentMethods.regular.count, 10)
        XCTAssertTrue(paymentMethods.regular[0] is CardPaymentMethod)
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
        
        // Qiwi Wallet
        XCTAssertTrue(paymentMethods.regular[8] is QiwiWalletPaymentMethod)
        let qiwiMethod = paymentMethods.regular[8] as! QiwiWalletPaymentMethod
        XCTAssertEqual(qiwiMethod.type, "qiwiwallet")
        XCTAssertEqual(qiwiMethod.name, "Qiwi Wallet")
        XCTAssertEqual(qiwiMethod.phoneExtensions.count, 3)
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].value, "+7")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].value, "+9955")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].value, "+507")
        
        XCTAssertEqual(qiwiMethod.phoneExtensions[0].countryCode, "RU")
        XCTAssertEqual(qiwiMethod.phoneExtensions[1].countryCode, "GE")
        XCTAssertEqual(qiwiMethod.phoneExtensions[2].countryCode, "PA")
        
        XCTAssertTrue(paymentMethods.regular[9] is WeChatPayPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[9].type, "wechatpaySDK")
        XCTAssertEqual(paymentMethods.regular[9].name, "WeChat Pay")
    }
    
    // MARK: - Card
    
    func testDecodingCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(cardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.brands, ["mc", "visa", "amex"])
    }
    
    func testDecodingBCMCCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(bcmcCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        XCTAssertEqual(paymentMethod.brands, [])
    }
    
    func testDecodingCardPaymentMethodWithoutBrands() throws {
        var dictionary = cardDictionary
        dictionary.removeValue(forKey: "brands")
        
        let paymentMethod = try Coder.decode(dictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertTrue(paymentMethod.brands.isEmpty)
    }
    
    func testDecodingStoredCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, "visa")
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        XCTAssertEqual(paymentMethod.displayInformation, expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: nil))
        XCTAssertEqual(paymentMethod.localizedDisplayInformation(using: expectedLocalizationParameters), expectedStoredCardPaymentMethodDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
    }
    
    public func expectedStoredCardPaymentMethodDisplayInfo(method: StoredCardPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        
        return DisplayInformation(title: "••••\u{00a0}" + method.lastFour,
                                  subtitle: ADYLocalizedString("adyen.card.stored.expires", localizationParameters, expireDate),
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
    
    public func expectedBancontactCardDisplayInfo(method: StoredBCMCPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        
        return DisplayInformation(title: "••••\u{00a0}" + method.lastFour,
                                  subtitle: ADYLocalizedString("adyen.card.stored.expires", localizationParameters, expireDate),
                                  logoName: method.brand)
    }
}

internal extension Coder {
    
    static func decode<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        return try decode(data)
    }
    
}
