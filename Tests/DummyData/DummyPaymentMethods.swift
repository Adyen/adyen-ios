//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let creditCardDictionary = [
    "type": "scheme",
    "name": "Credit Card",
    "fundingSource": "credit",
    "brands": ["mc", "visa", "amex"]
] as [String: Any]

let debitCardDictionary = [
    "type": "scheme",
    "name": "Credit Card",
    "fundingSource": "debit",
    "brands": ["mc", "visa", "amex"]
] as [String: Any]

let storedCreditCardDictionary = [
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
] as [String: Any]

let storedDebitCardDictionary = [
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
] as [String: Any]

let payPalDictionary = [
    "name": "PayPal",
    "supportsRecurring": true,
    "type": "paypal"
] as [String: Any]

let storedPayPalDictionary = [
    "type": "paypal",
    "id": "9314881977134903",
    "name": "PayPal",
    "shopperEmail": "example@shopper.com",
    "supportedShopperInteractions": [
        "Ecommerce",
        "ContAuth"
    ]
] as [String: Any]

let applePayDictionary = [
    "name": "Apple Pay",
    "supportsRecurring": true,
    "type": "applepay"
] as [String: Any]

let bcmcCardDictionary = [
    "name": "Bancontact card",
    "supportsRecurring": true,
    "type": "bcmc"
] as [String: Any]

let storedBcmcDictionary = [
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
] as [String: Any]

let issuerListDictionary = [
    "type": "ideal",
    "name": "iDEAL",
    "details": [
        [
            "items": [
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
            ],
            "key": "issuer",
            "type": "select"
        ]
    ]
] as [String: Any]

let sevenElevenDictionary = [
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
] as [String: Any]

let issuerListDictionaryWithoutDetailsObject = [
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
] as [String: Any]

let sepaDirectDebitDictionary = [
    "type": "sepadirectdebit",
    "name": "SEPA Direct Debit"
] as [String: Any]

let giroPayDictionaryWithOptionalDetails = [
    "details": [
        [
            "key": "bic",
            "type": "text",
            "optional": true
        ]
    ],
    "name": "GiroPay",
    "supportsRecurring": true,
    "type": "giropay"
] as [String: Any]

let giroPayDictionaryWithNonOptionalDetails = [
    "details": [
        [
            "key": "bic",
            "type": "text"
        ]
    ],
    "name": "GiroPay with non optional details",
    "supportsRecurring": true,
    "type": "giropay"
] as [String: Any]

let googlePay = [
    "configuration": [
        "merchantId": "1000",
        "gatewayMerchantId": "TestMerchantCheckout"
    ],
    "name": "Google Pay",
    "type": "paywithgoogle"
] as [String: Any]

let dokuWallet = [
    "name": "DOKU wallet",
    "type": "doku_wallet"
] as [String: Any]

let econtextStores = [
    "name": "Convenience Stores",
    "type": "econtext_stores"
] as [String: Any]

let econtextATM = [
    "name": "Pay-easy ATM",
    "type": "econtext_atm"
] as [String: Any]

let econtextOnline = [
    "name": "Online Banking",
    "type": "econtext_online"
] as [String: Any]

let oxxo = [
    "name": "OXXO",
    "type": "oxxo"
] as [String: Any]

let multibanco = [
    "name": "Multibanco",
    "type": "multibanco"
] as [String: Any]

let dokuIndomaretAction: [String: Any] = [
    "reference": "9786512300056485",
    "initialAmount": [
        "currency": "IDR",
        "value": 17408
    ],
    "paymentMethodType": "doku_indomaret",
    "instructionsUrl": "https://www.doku.com/how-to-pay/indomaret.php",
    "shopperEmail": "Qwfqwf@POj.co",
    "totalAmount": [
        "currency": "IDR",
        "value": 17408
    ],
    "expiresAt": "2021-02-02T22:00:00",
    "merchantName": "Adyen Demo Shop",
    "shopperName": "Qwfqwew Gewgewf",
    "type": "voucher",
    "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
]

let dokuAlfamartAction: [String: Any] = [
    "reference": "8888823200056486",
    "initialAmount": [
        "currency": "IDR",
        "value": 17408
    ],
    "paymentMethodType": "doku_alfamart",
    "instructionsUrl": "https://www.doku.com/how-to-pay/alfamart.php",
    "shopperEmail": "Qsosih@oih.com",
    "totalAmount": [
        "currency": "IDR",
        "value": 17408
    ],
    "expiresAt": "2021-02-02T22:58:00",
    "merchantName": "Adyen Demo Shop",
    "shopperName": "Qwodihqw Wqodihq",
    "type": "voucher",
    "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
]

let econtextStoresAction: [String: Any] = [
    "reference": "551342",
    "initialAmount": [
        "currency": "JPY",
        "value": 17408
    ],
    "paymentMethodType": "econtext_stores",
    "instructionsUrl": "https://www.econtext.jp/support/cvs/8brand.html",
    "totalAmount": [
        "currency": "JPY",
        "value": 17408
    ],
    "maskedTelephoneNumber": "11******89",
    "expiresAt": "2021-04-02T18:46:00",
    "merchantName": "TestMerchantCheckout",
    "type": "voucher",
    "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
]

let econtextATMAction: [String: Any] = [
    "reference": "954297",
    "collectionInstitutionNumber": "58091",
    "initialAmount": [
        "currency": "JPY",
        "value": 17408
    ],
    "paymentMethodType": "econtext_atm",
    "instructionsUrl": "https://www.econtext.jp/support/atm/index.html",
    "totalAmount": [
        "currency": "JPY",
        "value": 17408
    ],
    "maskedTelephoneNumber": "11******89",
    "expiresAt": "2021-04-02T18:48:00",
    "merchantName": "TestMerchantCheckout",
    "type": "voucher",
    "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
]

let boletoAction: [String: Any] = [
    "reference": "03399.33335 33852.193698 57889.001020 3 86360000017408",
    "initialAmount": [
        "currency": "BRL",
        "value": 17408
    ],
    "downloadUrl": "https://test.adyen.com/hpp/generationBoleto.shtml?data=BQABAQCGgaWQP0LNLQ0",
    "paymentMethodType": "boletobancario_santander",
    "totalAmount": [
        "currency": "BRL",
        "value": 17408
    ],
    "expiresAt": "2021-05-30T00:00:00",
    "type": "voucher",
    "passCreationToken": "test token".data(using: .utf8)?.base64EncodedString() ?? ""
]

let oxxoAction: [String: Any] = [
    "instructionsUrl": "https://checkoutshopper-test.adyen.com/checkoutshopper/voucherInstructions.shtml?txVariant=oxxo&shopperLocale=en_US",
    "passCreationToken": "token",
    "shopperEmail": "checkoutShopperiOS@example.org",
    "paymentMethodType": "oxxo",
    "totalAmount": [
        "currency": "MXN",
        "value": 17408
    ],
    "alternativeReference": "59168675976701",
    "initialAmount": [
        "currency": "MXN",
        "value": 17408
    ],
    "type": "voucher",
    "merchantName": "TestMerchantCheckout",
    "expiresAt": "2021-08-15T00:00:00",
    "merchantReference": "Test Order Reference - iOS UIHost",
    "reference": "59591686759767012021081500174084",
    "downloadUrl": "https://test.adyen.com/hpp/generationOxxoVoucher.shtml?data=1G8cQNAQFLrM7phkjS%2BnZRJ2W5K1z6NH9bqplnKsAviVGW%2Fe5W%2FNksob2MPC7BV1Vp5i%2BpSQ22UEeYouvWUFIVWz9%2FSrSQm%2BOnTGszWr6Sn6h3hNCacs%2BIXgGmg6DxxW20hMhSEj1SSL513eiXbKZTjpn%2BZAaRJfTCkP9kklYd5hxOMG6okhByIeMzvfCW718nQXXP%2F6%2F09p7zE3zM5uBQaaXQS9tY3Y80a1lIQytMlv4dIM7ZMLMv6rf18YgbzCOdTO%2B7wmrqR0fyuSLFC5mw2xQYBupKdSajEiIiHdy6Oq1YWrXFRoHnAVA3RLJkwNT3zk203p%2FbADKBJBrTF1ILOAlK5nJ%2FA6R1ioMVt%2F9vQ%3D"
]

let multibancoVoucher: [String: Any] = [
    "entity": "11249",
    "initialAmount": [
        "currency": "EUR",
        "value": 17408
    ],
    "reference": "522 771 332",
    "paymentMethodType": "multibanco",
    "totalAmount": [
        "currency": "EUR",
        "value": 17408
    ],
    "expiresAt": "2021-08-30T12:00:10",
    "merchantName": "TestMerchant",
    "merchantReference": "Test Order Reference - iOS UIHost",
    "type": "voucher",
    "passCreationToken": "Ab02b4c0!BQABAgBj+WtQPwc2TYNDdxV/IKW/SYB6d6IWV7yne67s2T4Nbr3v+KGzEVYaLs2uWQdkMVhubumVa1ula96RUqor6h9UoFMr7crM0qrZvz7wEuyV0dR1XG+F/cOq8UyLjhtkQL9RLh0gdntrw1FjCOHq7IAg+jzrWsH+fV5ofjdACkTlU1aSzqtPJDR9owl06Xeo1znNK9lYrvri4JRVPOkIEC4+h96sd1Rfn3t/NbAkBzhS/1emJIn6NQv7hmDz8FcWbxyjmY2LtHTigRhntmvY01z8hNOZ+1Zd4c/1GaEv3v1Y204AhcJx2ITHUIwmjD7j1GwYM+prkE1E+K6SOW0uV/cJQiIxkdDec1yN1+pFVvi78RRewIDthceqsxMBXQ6N7Z+8f+eVJJQDI1pRNdIcpsEgUSNMzUVGlu1eoPH1cY4o6/JxfvjY/+iqTCCsOLRgl+1A3oaRtAHUEKE7sqVwKU6NBfU9fXDCYRhF3dkgO8lN90YBgMDVO892MbloRzlB89sO2ZByE7JjQ65ElcunTMj290HrO+MKPtT+WocUWs+SrHjQldnbbgydQTtiV4m/gij/9z5uRNIEcoSjVn5VPlZ5eLI4nDq55Z4Ei8ak1VpUdmYm8/B2zhQtt5/0LXOsl8I8Ll+6R2LXrYesTt5wkac5yZK7oB51ilpqSzoQqMMXPhBEabbPAtWMNu14l1jGymF9AEp7ImtleSI6IkFGMEFBQTEwM0NBNTM3RUFFRDg3QzI0REQ1MzkwOUI4MEE3OEE5MjNFMzgyM0Q2OERBQ0M5NEI5RkY4MzA1REMiffSIcuL8hjKp/KgDw8goT6VN1sl6o4jfjayQOWvnkJdhBTqqxAbLFOvSfi6WMwbGYjVDwp53HsXZvJkNnEbxyk/SPR91A/foRwm7MCBlSTNM4IaUNVPrNmpOAw49oLoCifhwRAexyyjU0ybNSlwp4Y47dsFZmEkE8DdRRedW/N57bqst5IdRgpMEMVGpTgYsU2QYr4hpN1fwA40avGC19zaqnZC6iLQHsCaDKWQIjgM79Bzsr0WBL+hHjChMwgccoJA2QxPjJtE2CXCtSZYA5FqIcW3yi/P+SAPHQFafQgLMoX2/dQjxjMtHUHmtw1dB/kSDggB82znMKq+Udu3Y9H8hBxetaCyNGQSx0Ux5KkwfOEqf+M9FQsN35Dv/znwnzPsfxxqrIqb+ivddFx7JsyUF7M62xnCgPuWxP1WPyX+oKOLQhANibpUj/XDqc1tHlYQEE+95ZJWTYSQ="
]

let weChatMiniProgramDictionary = [
    "name": "WeChat Pay",
    "supportsRecurring": true,
    "type": "wechatpayMiniProgram"
] as [String: Any]

let weChatQRDictionary = [
    "name": "WeChat Pay",
    "supportsRecurring": true,
    "type": "wechatpayQR"
] as [String: Any]

let weChatSDKDictionary = [
    "name": "WeChat Pay",
    "supportsRecurring": true,
    "type": "wechatpaySDK"
] as [String: Any]

let weChatWebDictionary = [
    "name": "WeChat Pay",
    "supportsRecurring": true,
    "type": "wechatpayWeb"
] as [String: Any]

let bcmcMobileQR = [
    "name": "BCMC Mobile",
    "supportsRecurring": false,
    "type": "bcmc_mobile_QR"
] as [String: Any]

let mbway = [
    "name": "MB WAY",
    "supportsRecurring": true,
    "type": "mbway"
] as [String: Any]

let blik = [
    "name": "Blik",
    "supportsRecurring": true,
    "type": "blik"
] as [String: Any]

let storedBlik = [
    "id": "8315892878479934",
    "supportedShopperInteractions": [
        "Ecommerce"
    ],
    "name": "Blik",
    "type": "blik"
] as [String: Any]

let storedACHDictionary = [
    "bankLocationId": "011000138",
    "id": "CWG8SF2PR2M84H82",
    "supportedShopperInteractions": [
        "Ecommerce"
    ],
    "bankAccountNumber": "123456789",
    "ownerName": "John Smith",
    "type": "ach",
    "name": "ACH Direct Debit"
] as [String: Any]

let qiwiWallet = [
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
        ],
        [
            "key": "qiwiwallet.telephoneNumber",
            "type": "text"
        ]
    ],
    "name": "Qiwi Wallet",
    "supportsRecurring": true,
    "type": "qiwiwallet"
] as [String: Any]

let giftCard = [
    "brand": "genericgiftcard",
    "name": "Generic GiftCard",
    "type": "giftcard"
] as [String: Any]

let givexGiftCard = [
    "brand": "givex",
    "name": "Givex",
    "type": "giftcard"
] as [String: Any]

let giftCard1 = [
    "brand": "giftfor2card",
    "name": "GiftFor2",
    "type": "giftcard"
] as [String: Any]

let boleto = [
    "name": "Boleto Bancario",
    "type": "boletobancario_santander"
]

let bacsDirectDebit = [
    "name": "BACS Direct Debit",
    "type": "directdebit_GB"
]

let achDirectDebit = [
    "name": "ACH Direct Debit",
    "type": "ach"
]

let affirm = [
    "name": "Affirm",
    "type": "affirm"
]

let atome = [
    "name": "Atome",
    "type": "atome"
]

let onlineBankingDictionary = [
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
] as [String: Any]
