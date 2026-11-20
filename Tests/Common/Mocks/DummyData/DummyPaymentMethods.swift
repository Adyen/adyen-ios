//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

var creditCardDictionary: [String: Any] {
    [
        "type": "scheme",
        "name": "Credit Card",
        "fundingSource": "credit",
        "brands": ["mc", "visa", "amex"]
    ]
}

var debitCardDictionary: [String: Any] {
    [
        "type": "scheme",
        "name": "Credit Card",
        "fundingSource": "debit",
        "brands": ["mc", "visa", "amex"]
    ]
}

var storedCreditCardDictionary: [String: Any] {
    [
        "type": "scheme",
        "id": "9314881977134903",
        "name": "VISA",
        "brand": "visa",
        "lastFour": "1111",
        "expiryMonth": "08",
        "expiryYear": "2018",
        "holderName": "test",
        "fundingSource": "credit",
        "supportedShopperInteractions": [
            "Ecommerce",
            "ContAuth"
        ]
    ]
}

var storedDebitCardDictionary: [String: Any] {
    [
        "type": "scheme",
        "id": "9314881977134903",
        "name": "VISA",
        "brand": "visa",
        "lastFour": "1111",
        "expiryMonth": "08",
        "expiryYear": "2018",
        "holderName": "test",
        "fundingSource": "debit",
        "supportedShopperInteractions": [
            "Ecommerce",
            "ContAuth"
        ]
    ]
}

var payPalDictionary: [String: Any] {
    [
        "name": "PayPal",
        "supportsRecurring": true,
        "type": "paypal"
    ]
}

var storedPayPalDictionary: [String: Any] {
    [
        "type": "paypal",
        "id": "9314881977134903",
        "name": "PayPal",
        "shopperEmail": "example@shopper.com",
        "supportedShopperInteractions": [
            "Ecommerce",
            "ContAuth"
        ]
    ]
}

var applePayDictionary: [String: Any] {
    [
        "brands": ["maestro", "amex", "discover"],
        "name": "Apple Pay",
        "supportsRecurring": true,
        "type": "applepay"
    ]
}

var idealDictionary: [String: Any] {
    [
        "type": "ideal",
        "name": "iDeal",
        "issuers": [
            ["id": "1121", "name": "Test Issuer"],
            ["id": "1154", "name": "Test Issuer 2"]
        ]
    ]
}

var irisDictionary: [String: Any] {
    [
        "type": "iris",
        "name": "IRIS",
        "issuers": [
            ["id": "PIRBGRAA", "name": "Piraeus Bank"],
            ["id": "ERBKGRAA", "name": "Eurobank"],
            ["id": "ETHNGRAA", "name": "National Bank of Greece"]
        ]
    ]
}

var bcmcCardDictionary: [String: Any] {
    [
        "name": "Bancontact card",
        "supportsRecurring": true,
        "type": "bcmc"
    ]
}

var storedBcmcDictionary: [String: Any] {
    [
        "expiryMonth": "10",
        "expiryYear": "2020",
        "id": "8415736344108917",
        "supportedShopperInteractions": [
            "Ecommerce"
        ],
        "lastFour": "4449",
        "brand": "bcmc",
        "type": "scheme",
        "holderName": "Checkout Shopper PlaceHolder",
        "name": "Maestro"
    ]
}

var issuerListDictionary: [String: Any] {
    [
        "type": "onlineBanking_PL",
        "name": "Online Banking",
        "details": [
            [
                "items": [
                    [
                        "id": "xxxx",
                        "name": "Test Issuer 1"
                    ],
                    [
                        "id": "xxxx",
                        "name": "Test Issuer 2"
                    ],
                    [
                        "id": "xxxx",
                        "name": "Test Issuer 3"
                    ]
                ],
                "key": "issuer",
                "type": "select"
            ] as [String: Any]
        ]
    ]
}

var sevenElevenDictionary: [String: Any] {
    [
        "details": [
            [
                "key": "shopperEmail",
                "type": "emailAddress"
            ],
            [
                "key": "firstName",
                "type": "text"
            ],
            [
                "key": "lastName",
                "type": "text"
            ],
            [
                "key": "telephoneNumber",
                "type": "tel"
            ]
        ],
        "name": "7-Eleven",
        "type": "econtext_seven_eleven"
    ]
}

var issuerListDictionaryWithoutDetailsObject: [String: Any] {
    [
        "type": "ideal_100",
        "name": "iDEAL_100",
        "issuers": [
            [
                "id": "1121",
                "name": "Test Issuer 1"
            ],
            [
                "id": "1154",
                "name": "Test Issuer 2"
            ],
            [
                "id": "1153",
                "name": "Test Issuer 3"
            ]
        ]
    ]
}

var sepaDirectDebitDictionary: [String: Any] {
    [
        "type": "sepadirectdebit",
        "name": "SEPA Direct Debit"
    ]
}

var giroPayDictionaryWithOptionalDetails: [String: Any] {
    [
        "details": [
            [
                "key": "bic",
                "type": "text",
                "optional": true
            ] as [String: Any]
        ],
        "name": "GiroPay",
        "supportsRecurring": true,
        "type": "giropay"
    ]
}

var giroPayDictionaryWithNonOptionalDetails: [String: Any] {
    [
        "details": [
            [
                "key": "bic",
                "type": "text"
            ]
        ],
        "name": "GiroPay with non optional details",
        "supportsRecurring": true,
        "type": "giropay"
    ]
}

var googlePay: [String: Any] {
    [
        "configuration": [
            "merchantId": "1000",
            "gatewayMerchantId": "TestMerchantCheckout"
        ],
        "name": "Google Pay",
        "type": "paywithgoogle"
    ]
}

var dokuWallet: [String: Any] {
    [
        "name": "DOKU wallet",
        "type": "doku_wallet"
    ]
}

var econtextStores: [String: Any] {
    [
        "name": "Convenience Stores",
        "type": "econtext_stores"
    ]
}

var econtextATM: [String: Any] {
    [
        "name": "Pay-easy ATM",
        "type": "econtext_atm"
    ]
}

var econtextOnline: [String: Any] {
    [
        "name": "Online Banking",
        "type": "econtext_online"
    ]
}

var oxxo: [String: Any] {
    [
        "name": "OXXO",
        "type": "oxxo"
    ]
}

var multibanco: [String: Any] {
    [
        "name": "Multibanco",
        "type": "multibanco"
    ]
}

var dokuIndomaretAction: [String: Any] {
    [
        "reference": "9786512300056485",
        "initialAmount": [
            "currency": "IDR",
            "value": 17408
        ] as [String: Any],
        "paymentMethodType": "doku_indomaret",
        "instructionsUrl": "https://www.doku.com/how-to-pay/indomaret.php",
        "shopperEmail": "Qwfqwf@POj.co",
        "totalAmount": [
            "currency": "IDR",
            "value": 17408
        ] as [String: Any],
        "expiresAt": "2021-02-02T22:00:00",
        "merchantName": "Adyen Demo Shop",
        "shopperName": "Qwfqwew Gewgewf",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var dokuAlfamartAction: [String: Any] {
    [
        "reference": "8888823200056486",
        "initialAmount": [
            "currency": "IDR",
            "value": 17408
        ] as [String: Any],
        "paymentMethodType": "doku_alfamart",
        "instructionsUrl": "https://www.doku.com/how-to-pay/alfamart.php",
        "shopperEmail": "Qsosih@oih.com",
        "totalAmount": [
            "currency": "IDR",
            "value": 17408
        ] as [String: Any],
        "expiresAt": "2021-02-02T22:58:00",
        "merchantName": "Adyen Demo Shop",
        "shopperName": "Qwodihqw Wqodihq",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var econtextStoresAction: [String: Any] {
    [
        "reference": "551342",
        "initialAmount": [
            "currency": "JPY",
            "value": 17408
        ] as [String: Any],
        "paymentMethodType": "econtext_stores",
        "instructionsUrl": "https://www.econtext.jp/support/cvs/8brand.html",
        "totalAmount": [
            "currency": "JPY",
            "value": 17408
        ] as [String: Any],
        "maskedTelephoneNumber": "11******89",
        "expiresAt": "2021-04-02T18:46:00",
        "merchantName": "TestMerchantCheckout",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var econtextATMAction: [String: Any] {
    [
        "reference": "954297",
        "collectionInstitutionNumber": "58091",
        "initialAmount": [
            "currency": "JPY",
            "value": 17408
        ] as [String: Any],
        "paymentMethodType": "econtext_atm",
        "instructionsUrl": "https://www.econtext.jp/support/atm/index.html",
        "totalAmount": [
            "currency": "JPY",
            "value": 17408
        ] as [String: Any],
        "maskedTelephoneNumber": "11******89",
        "expiresAt": "2021-04-02T18:48:00",
        "merchantName": "TestMerchantCheckout",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var boletoAction: [String: Any] {
    [
        "reference": "03399.33335 33852.193698 57889.001020 3 86360000017408",
        "initialAmount": [
            "currency": "BRL",
            "value": 17408
        ] as [String: Any],
        "downloadUrl": "https://test.adyen.com/hpp/generationBoleto.shtml?data=BQABAQCGgaWQP0LNLQ0",
        "paymentMethodType": "boletobancario_santander",
        "totalAmount": [
            "currency": "BRL",
            "value": 17408
        ] as [String: Any],
        "expiresAt": "2021-05-30T00:00:00",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var oxxoAction: [String: Any] {
    [
        "instructionsUrl": "https://checkoutshopper-test.adyen.com/checkoutshopper/voucherInstructions.shtml?txVariant=oxxo&shopperLocale=en_US",
        "passCreationToken": "token",
        "shopperEmail": "checkoutShopperiOS@example.org",
        "paymentMethodType": "oxxo",
        "totalAmount": [
            "currency": "MXN",
            "value": 17408
        ] as [String: Any],
        "alternativeReference": "59168675976701",
        "initialAmount": [
            "currency": "MXN",
            "value": 17408
        ] as [String: Any],
        "type": "voucher",
        "merchantName": "TestMerchantCheckout",
        "expiresAt": "2021-08-15T00:00:00",
        "merchantReference": "Test Order Reference - iOS UIHost",
        "reference": "59591686759767012021081500174084",
        "downloadUrl": "https://test.adyen.com/hpp/generationOxxoVoucher.shtml?data=1G8cQNAQFLrM7phkjS%2BnZRJ2W5K1z6NH9bqplnKsAviVGW%2Fe5W%2FNksob2MPC7BV1Vp5i%2BpSQ22UEeYouvWUFIVWz9%2FSrSQm%2BOnTGszWr6Sn6h3hNCacs%2BIXgGmg6DxxW20hMhSEj1SSL513eiXbKZTjpn%2BZAaRJfTCkP9kklYd5hxOMG6okhByIeMzvfCW718nQXXP%2F6%2F09p7zE3zM5uBQaaXQS9tY3Y80a1lIQytMlv4dIM7ZMLMv6rf18YgbzCOdTO%2B7wmrqR0fyuSLFC5mw2xQYBupKdSajEiIiHdy6Oq1YWrXFRoHnAVA3RLJkwNT3zk203p%2FbADKBJBrTF1ILOAlK5nJ%2FA6R1ioMVt%2F9vQ%3D"
    ]
}

var multibancoVoucher: [String: Any] {
    [
        "entity": "11249",
        "initialAmount": [
            "currency": "EUR",
            "value": 17408
        ] as [String: Any],
        "reference": "522 771 332",
        "paymentMethodType": "multibanco",
        "totalAmount": [
            "currency": "EUR",
            "value": 17408
        ] as [String: Any],
        "expiresAt": "2021-08-30T12:00:10",
        "merchantName": "TestMerchant",
        "merchantReference": "Test Order Reference - iOS UIHost",
        "type": "voucher",
        "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
    ]
}

var weChatMiniProgramDictionary: [String: Any] {
    [
        "name": "WeChat Pay",
        "supportsRecurring": true,
        "type": "wechatpayMiniProgram"
    ]
}

var weChatQRDictionary: [String: Any] {
    [
        "name": "WeChat Pay",
        "supportsRecurring": true,
        "type": "wechatpayQR"
    ]
}

var weChatSDKDictionary: [String: Any] {
    [
        "name": "WeChat Pay",
        "supportsRecurring": true,
        "type": "wechatpaySDK"
    ]
}

var weChatWebDictionary: [String: Any] {
    [
        "name": "WeChat Pay",
        "supportsRecurring": true,
        "type": "wechatpayWeb"
    ]
}

var bcmcMobileQR: [String: Any] {
    [
        "name": "BCMC Mobile",
        "supportsRecurring": false,
        "type": "bcmc_mobile_QR"
    ]
}

var mbway: [String: Any] {
    [
        "name": "MB WAY",
        "supportsRecurring": true,
        "type": "mbway"
    ]
}

var blik: [String: Any] {
    [
        "name": "Blik",
        "supportsRecurring": true,
        "type": "blik"
    ]
}

var storedBlik: [String: Any] {
    [
        "id": "8315892878479934",
        "supportedShopperInteractions": [
            "Ecommerce"
        ],
        "name": "Blik",
        "type": "blik"
    ]
}

var storedACHDictionary: [String: Any] {
    [
        "bankLocationId": "011000138",
        "id": "CWG8SF2PR2M84H82",
        "supportedShopperInteractions": [
            "Ecommerce"
        ],
        "bankAccountNumber": "123456789",
        "ownerName": "John Smith",
        "type": "ach",
        "name": "ACH Direct Debit"
    ]
}

var storedTwintDictionary: [String: Any] {
    [
        "id": "JQDWGV3LDJK94875",
        "supportedShopperInteractions": [
            "Ecommerce",
            "ContAuth"
        ],
        "name": "TWINT",
        "supportedRecurringProcessingModels": [
            "CardOnFile",
            "Subscription",
            "UnscheduledCardOnFile"
        ],
        "type": "twint"
    ]
}

var storedPayToDictionary: [String: Any] {
    [
        "id": "CM3QNF29XWNZJMV5",
        "label": "•••••••2311",
        "supportedShopperInteractions": [
            "Ecommerce"
        ],
        "name": "payto",
        "supportedRecurringProcessingModels": [
            "CardOnFile"
        ],
        "type": "payto"
    ]
}

var qiwiWallet: [String: Any] {
    [
        "details": [
            [
                "items": [
                    [
                        "id": "+7",
                        "name": "RU"
                    ],
                    [
                        "id": "+9955",
                        "name": "GE"
                    ],
                    [
                        "id": "+507",
                        "name": "PA"
                    ]
                ],
                "key": "qiwiwallet.telephoneNumberPrefix",
                "type": "select"
            ] as [String: Any],
            [
                "key": "qiwiwallet.telephoneNumber",
                "type": "text"
            ]
        ],
        "name": "Qiwi Wallet",
        "supportsRecurring": true,
        "type": "qiwiwallet"
    ]
}

var giftCard: [String: Any] {
    [
        "brand": "genericgiftcard",
        "name": "Generic GiftCard",
        "type": "giftcard"
    ]
}

var givexGiftCard: [String: Any] {
    [
        "brand": "givex",
        "name": "Givex",
        "type": "giftcard"
    ]
}

var giftCard1: [String: Any] {
    [
        "brand": "giftfor2card",
        "name": "GiftFor2",
        "type": "giftcard"
    ]
}

var mealVoucherSodexo: [String: Any] {
    [
        "name": "Sodexo",
        "type": "mealVoucher_FR_sodexo"
    ]
}

var boletoBancarioSantander: [String: String] {
    [
        "name": "Boleto Bancario",
        "type": "boletobancario_santander"
    ]
}

var primeiroPayBoleto: [String: String] {
    [
        "name": "Boleto Bancario",
        "type": "primeiropay_boleto"
    ]
}

var boletoBancario: [String: String] {
    [
        "name": "Boleto Bancario",
        "type": "boletobancario"
    ]
}

var boletoBancarioItau: [String: String] {
    [
        "name": "Boleto Bancario",
        "type": "boletobancario_itau"
    ]
}

var bacsDirectDebit: [String: String] {
    [
        "name": "BACS Direct Debit",
        "type": "directdebit_GB"
    ]
}

var achDirectDebit: [String: String] {
    [
        "name": "ACH Direct Debit",
        "type": "ach"
    ]
}

var affirm: [String: String] {
    [
        "name": "Affirm",
        "type": "affirm"
    ]
}

var atome: [String: String] {
    [
        "name": "Atome",
        "type": "atome"
    ]
}

var onlineBankingDictionary: [String: Any] {
    [
        "type": "onlineBanking_CZ",
        "name": "onlineBanking_CZ",
        "issuers": [
            [
                "id": "jp",
                "name": "Apple Pay"
            ],
            [
                "id": "ap",
                "name": "Google Pay"
            ],
            [
                "id": "cs",
                "name": "Česká spořitelna"
            ],
            [
                "id": "kb",
                "name": "Komerční banka"
            ],
            [
                "id": "c",
                "name": "Płatność online kartą płatniczą"
            ]
        ]
    ]
}

var upi: [String: Any] {
    [
        "name": "UPI",
        "type": "upi"
    ]
}

var upiWithApps: [String: Any] {
    [
        "name": "UPI",
        "type": "upi",
        "apps": [
            [
                "id": "bhim",
                "name": "BHIM"
            ],
            [
                "id": "gpay",
                "name": "Google Pay"
            ],
            [
                "id": "phonepe",
                "name": "PhonePe"
            ]
        ]
    ]
}

var cashAppPay: [String: Any] {
    [
        "name": "Cash App Pay",
        "type": "cashapp",
        "configuration": [
            "scopeId": "testScope",
            "clientId": "testClient"
        ]
    ]
}

var bizum: [String: Any] {
    [
        "type": "bizum",
        "name": "Bizum"
    ]
}

var twint: [String: String] {
    [
        "name": "Twint",
        "type": "twint"
    ]
}

var payto: [String: String] {
    [
        "name": "payto",
        "type": "payto"
    ]
}

var payByBankGeneric: [String: Any] {
    [
        "name": "Pay by Bank",
        "type": "paybybank"
    ]
}

var payByBankIssuerList: [String: Any] {
    [
        "name": "Pay by Bank",
        "type": "paybybank",
        "issuers": [
            [
                "id": "uk-demobank-open-banking-handoff",
                "disabled": false,
                "name": "Tink Demo Bank"
            ],
            [
                "id": "uk-demobank-open-banking-redirect",
                "disabled": false,
                "name": "Tink Demo Bank"
            ],
            [
                "id": "uk-demobank-open-banking-redirect-aispis",
                "disabled": false,
                "name": "Tink Demo Bank"
            ],
            [
                "id": "uk-demobank-open-banking-redirect-extendable",
                "disabled": false,
                "name": "Tink Demo Bank"
            ]
        ]
    ]
}
