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

let storedDeditCardDictionary = [
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
    "type": "voucher"
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
    "type": "voucher"
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
    "type": "voucher"
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
    "type": "voucher"
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
