//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Foundation

enum PaymentMethodsMock {

    static let paymentMethodsDictionary: [String: Any] =
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
                bizum,
                boletoBancario,
                boletoBancarioSantander,
                primeiroPayBoleto,
                boletoBancarioItau,
                affirm,
                atome,
                upi,
                cashAppPay,
                idealDictionary,
                payto
            ]
        ]

}
