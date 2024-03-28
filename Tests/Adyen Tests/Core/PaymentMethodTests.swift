//
// Copyright (c) 2024 Adyen N.V.
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
                storedACHDictionary
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
                econtextOnline,
                oxxo,
                achDirectDebit,
                bacsDirectDebit,
                giftCard1,
                givexGiftCard,
                mealVoucherSodexo,
                bizum,
                boleto,
                affirm,
                atome,
                upi,
                cashAppPay
            ]
        ]
    }
    
    private func getPaymentMethods() throws -> PaymentMethods {
        try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }
    
    // MARK: - Payment Methods
    
    func testPaymentMethodsCoding() throws {
        let paymentMethods: PaymentMethods = try getPaymentMethods()
        
        let encodedPaymentMethods: Data = try AdyenCoder.encode(paymentMethods)
        let decodedPaymentMethods: PaymentMethods = try AdyenCoder.decode(encodedPaymentMethods)
        
        XCTAssertEqual(paymentMethods, decodedPaymentMethods)
    }
    
    func testDecodingPaymentMethods() throws {
        // Stored payment methods
        
        let paymentMethods = try getPaymentMethods()
        
        XCTAssertEqual(paymentMethods.stored.count, 8)
        XCTAssertTrue(paymentMethods.stored[0] is StoredCardPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[1] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[1] as! StoredCardPaymentMethod).fundingSource!, .credit)
        
        // Test StoredCardPaymentMethod localization
        var storedCardPaymentMethod = paymentMethods.stored[1] as! StoredCardPaymentMethod
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(storedCardPaymentMethod.displayInformation(using: expectedLocalizationParameters),
                       expectedStoredCardPaymentMethodDisplayInfo(method: storedCardPaymentMethod, localizationParameters: expectedLocalizationParameters))
        storedCardPaymentMethod.merchantProvidedDisplayInformation = .init(title: "custom title", subtitle: "custom subtitle")
        XCTAssertEqual(
            storedCardPaymentMethod.displayInformation(using: expectedLocalizationParameters),
            expectedStoredCardPaymentMethodDisplayInfo(
                method: storedCardPaymentMethod,
                localizationParameters: expectedLocalizationParameters
            )
        )
        
        XCTAssertTrue(paymentMethods.stored[2] is StoredPayPalPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[2] as! StoredPayPalPaymentMethod).displayInformation(using: expectedLocalizationParameters).subtitle, "example@shopper.com")
        XCTAssertTrue(paymentMethods.stored[3] is StoredInstantPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[4] is StoredBCMCPaymentMethod)
        
        XCTAssertTrue(paymentMethods.stored[5] is StoredCardPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[5] as! StoredCardPaymentMethod).fundingSource!, .debit)

        XCTAssertTrue(paymentMethods.stored[6] is StoredBLIKPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[6] as! StoredBLIKPaymentMethod).identifier, "8315892878479934")
        
        XCTAssertTrue(paymentMethods.stored[7] is StoredACHDirectDebitPaymentMethod)
        XCTAssertEqual((paymentMethods.stored[7] as! StoredACHDirectDebitPaymentMethod).identifier, "CWG8SF2PR2M84H82")
        
        // Test StoredBCMCPaymentMethod localization
        var storedBCMCPaymentMethod = paymentMethods.stored[4] as! StoredBCMCPaymentMethod
        XCTAssertEqual(storedBCMCPaymentMethod.displayInformation(using: nil),
                       expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: nil))
        XCTAssertEqual(storedBCMCPaymentMethod.displayInformation(using: expectedLocalizationParameters),
                       expectedBancontactCardDisplayInfo(method: storedBCMCPaymentMethod, localizationParameters: expectedLocalizationParameters))
        storedBCMCPaymentMethod.merchantProvidedDisplayInformation = .init(title: "custom title", subtitle: "custom subtitle")
        XCTAssertEqual(
            storedBCMCPaymentMethod.displayInformation(using: expectedLocalizationParameters),
            expectedBancontactCardDisplayInfo(
                method: storedBCMCPaymentMethod,
                localizationParameters: expectedLocalizationParameters
            )
        )
        
        XCTAssertEqual(paymentMethods.stored[3].type.rawValue, "unknown")
        XCTAssertEqual(paymentMethods.stored[3].name, "Stored Redirect Payment Method")
        
        let storedBancontact = paymentMethods.stored[4] as! StoredBCMCPaymentMethod
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
        
        XCTAssertEqual(paymentMethods.regular.count, 31)
        
        let creditCardPaymentMethod = try XCTUnwrap(paymentMethods.regular[0] as? CardPaymentMethod)
        XCTAssertEqual(creditCardPaymentMethod.fundingSource, .credit)
        
        XCTAssertTrue(paymentMethods.regular[1] is IssuerListPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[2] is SEPADirectDebitPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[3] is InstantPaymentMethod)
        
        // Unknown redirect
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
        XCTAssertTrue(paymentMethods.regular[6] is InstantPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[6].type.rawValue, "paypal")
        XCTAssertEqual(paymentMethods.regular[6].name, "PayPal")
        
        // GiroPay
        XCTAssertTrue(paymentMethods.regular[7] is InstantPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[7].type.rawValue, "giropay")
        XCTAssertEqual(paymentMethods.regular[7].name, "GiroPay")

        // GiroPay with non optional details
        XCTAssertTrue(paymentMethods.regular[8] is InstantPaymentMethod)
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
        XCTAssertEqual(paymentMethods.regular[26].type.rawValue, "boletobancario_santander")
        
        XCTAssertTrue(paymentMethods.regular[27] is AffirmPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[27].name, "Affirm")
        XCTAssertEqual(paymentMethods.regular[27].type.rawValue, "affirm")
        
        XCTAssertTrue(paymentMethods.regular[28] is AtomePaymentMethod)
        XCTAssertEqual(paymentMethods.regular[28].name, "Atome")
        XCTAssertEqual(paymentMethods.regular[28].type.rawValue, "atome")
        
        XCTAssertTrue(paymentMethods.regular[29] is UPIPaymentMethod)
        XCTAssertEqual(paymentMethods.regular[29].name, "UPI")
        XCTAssertEqual(paymentMethods.regular[29].type.rawValue, "upi")
        
        let cashAppPay = try XCTUnwrap(paymentMethods.regular[30] as? CashAppPayPaymentMethod)
        XCTAssertEqual(cashAppPay.name, "Cash App Pay")
        XCTAssertEqual(cashAppPay.type.rawValue, "cashapp")
        XCTAssertEqual(cashAppPay.clientId, "testClient")
        XCTAssertEqual(cashAppPay.scopeId, "testScope")
    }
    
    // MARK: - Display Information Override
    
    func testOverridingDisplayInformationCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .scheme,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let cardpaymentMethod = paymentMethods.paymentMethod(ofType: .scheme)
        XCTAssertEqual(cardpaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(cardpaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationBCMC() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .bcmc,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let bcmcpaymentMethod = paymentMethods.paymentMethod(ofType: .bcmc)
        XCTAssertEqual(bcmcpaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(bcmcpaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationApplePay() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .applePay,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let applePaypaymentMethod = paymentMethods.paymentMethod(ofType: .applePay)
        XCTAssertEqual(applePaypaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(applePaypaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationPayPal() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .payPal,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let payPalpaymentMethod = paymentMethods.paymentMethod(ofType: .payPal)
        XCTAssertEqual(payPalpaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(payPalpaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationWeChat() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .weChatPaySDK,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let weChatPaymentMethod = paymentMethods.paymentMethod(ofType: .weChatPaySDK)
        XCTAssertEqual(weChatPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(weChatPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationQiwiWallet() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .qiwiWallet,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let qiwiWalletPaymentMethod = paymentMethods.paymentMethod(ofType: .qiwiWallet)
        XCTAssertEqual(qiwiWalletPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(qiwiWalletPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationBLIK() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .blik,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let blikPaymentMethod = paymentMethods.paymentMethod(ofType: .blik)
        XCTAssertEqual(blikPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(blikPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationStoredBLIK() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofStoredPaymentMethod: .blik,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let storedBlikPaymentMethod = paymentMethods.stored.first { $0.type == .blik }
        XCTAssertEqual(storedBlikPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(storedBlikPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationStoredCreditCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofStoredPaymentMethod: .scheme,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"),
                                                  where: { (storeCardPaymentMethod: StoredCardPaymentMethod) -> Bool in
                                                      storeCardPaymentMethod.fundingSource == .credit
            
                                                  })
        let storedPaymentMethod = paymentMethods.stored.filter { $0.type == .scheme }.compactMap { $0 as? StoredCardPaymentMethod }.first { $0.fundingSource == .credit }
        XCTAssertEqual(storedPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(storedPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
        /// make sure that we override the display information of only credit card payment method.
        let storedDebitPaymentMethod = paymentMethods.stored.filter { $0.type == .scheme }.compactMap { $0 as? StoredCardPaymentMethod }.first { $0.fundingSource == .debit }
        XCTAssertNotEqual(storedDebitPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertNotEqual(storedDebitPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationStoredDebitCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofStoredPaymentMethod: .scheme,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"),
                                                  where: { (storeCardPaymentMethod: StoredCardPaymentMethod) -> Bool in
                                                      storeCardPaymentMethod.fundingSource == .debit
            
                                                  })
        let storedPaymentMethod = paymentMethods.stored.filter { $0.type == .scheme }.compactMap { $0 as? StoredCardPaymentMethod }.first { $0.fundingSource == .debit }
        XCTAssertEqual(storedPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(storedPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
        /// make sure that we override the display information of only debit card payment method.
        let storedCreditPaymentMethod = paymentMethods.stored.filter { $0.type == .scheme }.compactMap { $0 as? StoredCardPaymentMethod }.first { $0.fundingSource == .credit }
        XCTAssertNotEqual(storedCreditPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertNotEqual(storedCreditPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationGiro() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .other("giropay"),
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let giroPaymentMethod = paymentMethods.paymentMethod(ofType: .other("giropay"))
        XCTAssertEqual(giroPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(giroPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationGenericGiftCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(
            ofRegularPaymentMethod: .giftcard,
            with: .init(title: "custom title",
                        subtitle: "custom subtitle"),
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "genericgiftcard"
            }
        )
        let giftCardPaymentMethod = paymentMethods.paymentMethod(ofType: .giftcard)
        XCTAssertEqual(giftCardPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(giftCardPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
        /// make sure that we override the display information of only generic giftcard payment method.
        let givexGiftCardPaymentMethod = paymentMethods.paymentMethod(
            ofType: PaymentMethodType.giftcard,
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "givex"
            }
        )
        XCTAssertEqual(givexGiftCardPaymentMethod?.displayInformation(using: nil).title, "Givex")
        XCTAssertNil(givexGiftCardPaymentMethod?.displayInformation(using: nil).subtitle)
    }
    
    func testOverridingDisplayInformationGivexGiftCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(
            ofRegularPaymentMethod: .giftcard,
            with: .init(title: "custom title",
                        subtitle: "custom subtitle"),
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "givex"
            }
        )
        let givexGiftCardPaymentMethod = paymentMethods.paymentMethod(
            ofType: PaymentMethodType.giftcard,
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "givex"
            }
        )
        XCTAssertEqual(givexGiftCardPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(givexGiftCardPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
        let anyGiftCardPaymentMethod = paymentMethods.paymentMethod(
            ofType: PaymentMethodType.giftcard,
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "giftfor2card"
            }
        )
        XCTAssertEqual(anyGiftCardPaymentMethod?.displayInformation(using: nil).title, "GiftFor2")
        XCTAssertNil(anyGiftCardPaymentMethod?.displayInformation(using: nil).subtitle)
    }
    
    func testOverridingDisplayInformationAnyGivenGiftCard() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(
            ofRegularPaymentMethod: .giftcard,
            with: .init(title: "custom title",
                        subtitle: "custom subtitle"),
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "giftfor2card"
            }
        )
        let anyGiftCardPaymentMethod = paymentMethods.paymentMethod(
            ofType: PaymentMethodType.giftcard,
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "giftfor2card"
            }
        )
        XCTAssertEqual(anyGiftCardPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(anyGiftCardPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
        let givexGiftCardPaymentMethod = paymentMethods.paymentMethod(
            ofType: PaymentMethodType.giftcard,
            where: { (paymentMethod: GiftCardPaymentMethod) -> Bool in
                paymentMethod.brand == "givex"
            }
        )
        XCTAssertEqual(givexGiftCardPaymentMethod?.displayInformation(using: nil).title, "Givex")
        XCTAssertNil(givexGiftCardPaymentMethod?.displayInformation(using: nil).subtitle)
    }
    
    func testOverridingDisplayInformationMealVoucher() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .mealVoucherSodexo,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let mealVoucherSodexoPaymentMethod = paymentMethods.paymentMethod(ofType: .mealVoucherSodexo)
        XCTAssertEqual(mealVoucherSodexoPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(mealVoucherSodexoPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
        
    }
    
    func testOverridingDisplayInformationDukoWallet() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .dokuWallet,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let dukoWalletPaymentMethod = paymentMethods.paymentMethod(ofType: .dokuWallet)
        XCTAssertEqual(dukoWalletPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(dukoWalletPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    func testOverridingDisplayInformationIdeal() throws {
        var paymentMethods = try getPaymentMethods()
        paymentMethods.overrideDisplayInformation(ofRegularPaymentMethod: .ideal,
                                                  with: .init(title: "custom title",
                                                              subtitle: "custom subtitle"))
        let idealPaymentMethod = paymentMethods.paymentMethod(ofType: .ideal)
        XCTAssertEqual(idealPaymentMethod?.displayInformation(using: nil).title, "custom title")
        XCTAssertEqual(idealPaymentMethod?.displayInformation(using: nil).subtitle, "custom subtitle")
    }
    
    // MARK: - Misc

    func testDecodingPaymentMethodsWithNullValues() throws {

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

        let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(paymentMethods.regular.count, 1)
        XCTAssertEqual(paymentMethods.stored.count, 0)
        XCTAssertTrue(paymentMethods.regular[0] is CardPaymentMethod)
    }
    
    func testEquality() {
        XCTAssertFalse(BLIKPaymentMethod(type: .blik, name: "blik") ==
            StoredBLIKPaymentMethod(type: .blik,
                                    name: "blik",
                                    identifier: "efefew",
                                    supportedShopperInteractions: [.shopperNotPresent]))
        XCTAssertFalse(StoredPayPalPaymentMethod(type: .payPal,
                                                 name: "payPal",
                                                 identifier: "12334",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 emailAddress: "email") ==
                InstantPaymentMethod(type: .payPal, name: "payPal"))
        XCTAssertTrue(StoredPayPalPaymentMethod(type: .payPal,
                                                name: "payPal",
                                                identifier: "12334",
                                                supportedShopperInteractions: [.shopperPresent],
                                                emailAddress: "email") ==
                StoredPayPalPaymentMethod(type: .payPal,
                                          name: "payPal",
                                          identifier: "12334",
                                          supportedShopperInteractions: [.shopperPresent],
                                          emailAddress: "email"))
        XCTAssertFalse(StoredPayPalPaymentMethod(type: .payPal,
                                                 name: "payPal",
                                                 identifier: "XXX",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 emailAddress: "email") ==
                StoredPayPalPaymentMethod(type: .payPal,
                                          name: "payPal",
                                          identifier: "12334",
                                          supportedShopperInteractions: [.shopperPresent],
                                          emailAddress: "email"))
        XCTAssertFalse(StoredPayPalPaymentMethod(type: .other("payPalx"),
                                                 name: "payPal",
                                                 identifier: "XXX",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 emailAddress: "email") ==
                StoredPayPalPaymentMethod(type: .payPal,
                                          name: "payPal",
                                          identifier: "12334",
                                          supportedShopperInteractions: [.shopperPresent],
                                          emailAddress: "email"))
        XCTAssertFalse(StoredPayPalPaymentMethod(type: .payPal,
                                                 name: "payPal",
                                                 identifier: "XXX",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 emailAddress: "email") ==
                StoredPayPalPaymentMethod(type: .payPal,
                                          name: "payPal",
                                          identifier: "12334",
                                          supportedShopperInteractions: [.shopperNotPresent],
                                          emailAddress: "email"))
        XCTAssertFalse(StoredPayPalPaymentMethod(type: .payPal,
                                                 name: "payPal",
                                                 identifier: "payPal_id",
                                                 supportedShopperInteractions: [.shopperPresent],
                                                 emailAddress: "email") ==
                StoredBLIKPaymentMethod(type: .payPal,
                                        name: "payPal",
                                        identifier: "payPal_id",
                                        supportedShopperInteractions: [.shopperPresent]))
    }
    
    // MARK: - Card
    
    func testDecodingCreditCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource!, .credit)
        XCTAssertEqual(paymentMethod.brands, [.masterCard, .visa, .americanExpress])
        testCoding(paymentMethod)
    }
    
    func testDecodingDebitCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(debitCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.fundingSource!, .debit)
        XCTAssertEqual(paymentMethod.brands, [.masterCard, .visa, .americanExpress])
        testCoding(paymentMethod)
    }
    
    func testDecodingBCMCCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bcmcCardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        XCTAssertEqual(paymentMethod.brands, [])
        testCoding(paymentMethod)
    }
    
    func testDecodingCardPaymentMethodWithoutBrands() throws {
        var dictionary = creditCardDictionary
        dictionary.removeValue(forKey: "brands")
        
        let paymentMethod = try AdyenCoder.decode(dictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertTrue(paymentMethod.brands.isEmpty)
        testCoding(paymentMethod)
    }
    
    func testDecodingStoredCreditCardPaymentMethod() throws {
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
    
    func testDecodingStoredDebitCardPaymentMethod() throws {
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
    
    public func expectedStoredCardPaymentMethodDisplayInfo(method: StoredCardPaymentMethod, localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        if let customDisplayInformation = method.merchantProvidedDisplayInformation {
            return DisplayInformation(
                title: customDisplayInformation.title,
                subtitle: customDisplayInformation.subtitle ?? localizedString(.cardStoredExpires, localizationParameters, expireDate),
                logoName: method.brand.rawValue
            )
        }
        
        let accessibilityLabel = "\(method.brand.name), Last 4 digits: \(method.lastFour.map { String($0) }.joined(separator: ", ")), \(localizedString(.cardStoredExpires, localizationParameters, expireDate))"
        
        return DisplayInformation(title: String.Adyen.securedString + method.lastFour,
                                  subtitle: localizedString(.cardStoredExpires, localizationParameters, expireDate),
                                  logoName: method.brand.rawValue,
                                  accessibilityLabel: accessibilityLabel)
    }
    
    // MARK: - Issuer List
    
    func testDecodingIssuerListPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ideal")
        XCTAssertEqual(paymentMethod.name, "iDEAL")
        
        XCTAssertEqual(paymentMethod.issuers.count, 3)
        XCTAssertEqual(paymentMethod.issuers[0].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[0].name, "Test Issuer 1")
        XCTAssertEqual(paymentMethod.issuers[1].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[1].name, "Test Issuer 2")
        XCTAssertEqual(paymentMethod.issuers[2].identifier, "xxxx")
        XCTAssertEqual(paymentMethod.issuers[2].name, "Test Issuer 3")
        
        testCoding(paymentMethod)
    }

    func testDecodingIssuerListPaymentMethodWithoutDetailsObject() throws {
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
    
    func testDecodingSEPADirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(sepaDirectDebitDictionary) as SEPADirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "sepadirectdebit")
        XCTAssertEqual(paymentMethod.name, "SEPA Direct Debit")
        testCoding(paymentMethod)
    }
    
    // MARK: - Stored PayPal
    
    func testDecodingPayPalPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "paypal")
        XCTAssertEqual(paymentMethod.identifier, "9314881977134903")
        XCTAssertEqual(paymentMethod.name, "PayPal")
        XCTAssertEqual(paymentMethod.emailAddress, "example@shopper.com")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
        testCoding(paymentMethod)
    }
    
    // MARK: - Apple Pay
    
    func testDecodingApplePayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(applePayDictionary) as ApplePayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "applepay")
        XCTAssertEqual(paymentMethod.name, "Apple Pay")
        testCoding(paymentMethod)
    }
    
    // MARK: - Bancontact
    
    func testDecodingBancontactPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bcmcCardDictionary) as BCMCPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "bcmc")
        XCTAssertEqual(paymentMethod.name, "Bancontact card")
        testCoding(paymentMethod)
    }
    
    // MARK: - GiroPay
    
    func testDecodingGiropayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(giroPayDictionaryWithOptionalDetails) as InstantPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "giropay")
        XCTAssertEqual(paymentMethod.name, "GiroPay")
        testCoding(paymentMethod)
    }

    // MARK: - Seven Eleven

    func testDecodingSevenElevenPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(sevenElevenDictionary) as SevenElevenPaymentMethod
        XCTAssertEqual(paymentMethod.name, "7-Eleven")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_seven_eleven")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context Online

    func testDecodingEContextOnlinePaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextOnline) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Online Banking")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_online")
        testCoding(paymentMethod)
    }
    
    // MARK: - OXXO

    func testDecodingOXXOPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(oxxo) as OXXOPaymentMethod
        XCTAssertEqual(paymentMethod.name, "OXXO")
        XCTAssertEqual(paymentMethod.type.rawValue, "oxxo")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context ATM

    func testDecodingEContextATMPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextATM) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Pay-easy ATM")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_atm")
        testCoding(paymentMethod)
    }

    // MARK: - E-Context Stores

    func testDecodingEContextStoresPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(econtextStores) as EContextPaymentMethod
        XCTAssertEqual(paymentMethod.name, "Convenience Stores")
        XCTAssertEqual(paymentMethod.type.rawValue, "econtext_stores")
        testCoding(paymentMethod)
    }
    
    // MARK: - Stored Bancontact
    
    func testDecodingStoredBancontactPaymentMethod() throws {
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
        XCTAssertEqual(paymentMethod.displayInformation(using: expectedLocalizationParameters),
                       expectedBancontactCardDisplayInfo(method: paymentMethod, localizationParameters: expectedLocalizationParameters))
        testCoding(paymentMethod)
    }

    // MARK: - MBWay

    func testDecodingMBWayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(mbway) as MBWayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "mbway")
        XCTAssertEqual(paymentMethod.name, "MB WAY")
        testCoding(paymentMethod)
    }

    // MARK: - Doku wallet

    func testDecodingDokuWalletPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(dokuWallet) as DokuPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "doku_wallet")
        XCTAssertEqual(paymentMethod.name, "DOKU wallet")
        testCoding(paymentMethod)
    }
    
    public func expectedBancontactCardDisplayInfo(method: StoredBCMCPaymentMethod,
                                                  localizationParameters: LocalizationParameters?) -> DisplayInformation {
        let expireDate = method.expiryMonth + "/" + method.expiryYear.suffix(2)
        if let customDisplayInformation = method.merchantProvidedDisplayInformation {
            return DisplayInformation(
                title: customDisplayInformation.title,
                subtitle: customDisplayInformation.subtitle ?? localizedString(.cardStoredExpires, localizationParameters, expireDate),
                logoName: method.brand
            )
        }
        
        let accessibilityLabel = "BCMC, Last 4 digits: \(method.lastFour.map { String($0) }.joined(separator: ", ")), \(localizedString(.cardStoredExpires, localizationParameters, expireDate))"
        
        return DisplayInformation(title: String.Adyen.securedString + method.lastFour,
                                  subtitle: localizedString(.cardStoredExpires, localizationParameters, expireDate),
                                  logoName: method.brand,
                                  accessibilityLabel: accessibilityLabel)
    }

    // MARK: - GiftCard

    func testDecodingGiftCardPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(giftCard) as GiftCardPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "giftcard")
        XCTAssertEqual(paymentMethod.name, "Generic GiftCard")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Generic GiftCard")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "genericgiftcard")
        testCoding(paymentMethod)
    }
    
    func testDecodingMealVoucherPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(mealVoucherSodexo) as MealVoucherPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "mealVoucher_FR_sodexo")
        XCTAssertEqual(paymentMethod.name, "Sodexo")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Sodexo")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "mealVoucher_FR_sodexo")
        testCoding(paymentMethod)
    }
    
    // MARK: - Boleto
    
    func testDecodingBoletoPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(boleto) as BoletoPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "boletobancario_santander")
        XCTAssertEqual(paymentMethod.name, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).title, "Boleto Bancario")
        XCTAssertEqual(paymentMethod.displayInformation(using: nil).logoName, "boletobancario_santander")
        testCoding(paymentMethod)
    }

    // MARK: - BACS Direct Debit

    func testDecodingBACSDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(bacsDirectDebit) as BACSDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "directdebit_GB")
        XCTAssertEqual(paymentMethod.name, "BACS Direct Debit")
        testCoding(paymentMethod)
    }

    // MARK: - ACH Direct Debit

    func testDecodingACHDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(achDirectDebit) as ACHDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ach")
        XCTAssertEqual(paymentMethod.name, "ACH Direct Debit")
        testCoding(paymentMethod)
    }
    
    func testDecodingStoredACHDirectDebitPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(storedACHDictionary) as StoredACHDirectDebitPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "ach")
        XCTAssertEqual(paymentMethod.name, "ACH Direct Debit")
        XCTAssertEqual(paymentMethod.bankAccountNumber, "123456789")
        testCoding(paymentMethod)
    }
    
    // MARK: - Cash App
    
    func testDecodingCashAppPayPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(cashAppPay) as CashAppPayPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "cashapp")
        XCTAssertEqual(paymentMethod.name, "Cash App Pay")
        testCoding(paymentMethod)
    }
    
    // MARK: - Cash App
    
    func testDecodingQiwiPaymentMethod() throws {
        let paymentMethod = try AdyenCoder.decode(qiwiWallet) as QiwiWalletPaymentMethod
        XCTAssertEqual(paymentMethod.type.rawValue, "qiwiwallet")
        XCTAssertEqual(paymentMethod.name, "Qiwi Wallet")
        testCoding(paymentMethod)
    }
    
    // MARK: - PaymentMethodDetails
    
    func testMissingImplementationPaymentMethodDetails() throws {
        
        class DummyPaymentMethodDetails: PaymentMethodDetails {}
        
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
        let _ = dummy.checkoutAttemptId
        
        wait(for: [expectation], timeout: 10)
    }
    
    // MARK: - Accessibility
    
    func testPaymentMethodTypeName() throws {
      
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
