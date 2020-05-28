//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let cardDictionary = [
    "type": "scheme",
    "name": "Credit Card",
    "brands": ["mc", "visa", "amex"]
] as [String: Any]

let storedCardDictionary = [
    "type": "scheme",
    "id": "9314881977134903",
    "name": "VISA",
    "brand": "visa",
    "lastFour": "1111",
    "expiryMonth": "08",
    "expiryYear": "2018",
    "holderName": "test",
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
