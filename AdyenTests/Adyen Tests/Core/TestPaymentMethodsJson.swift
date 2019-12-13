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
    "name" : "PayPal",
    "supportsRecurring" : true,
    "type" : "paypal"
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
    "name" : "Apple Pay",
    "supportsRecurring" : true,
    "type" : "applepay"
] as [String: Any]

let bcmcCardDictionary = [
    "name" : "Bancontact card",
    "supportsRecurring" : true,
    "type" : "bcmc"
] as [String: Any]

let storedBcmcDictionary = [
    "expiryMonth" : "10",
    "expiryYear" : "2020",
    "id" : "8415736344108917",
    "supportedShopperInteractions" : [
      "Ecommerce"
    ],
    "lastFour" : "4449",
    "brand" : "bcmc",
    "type" : "scheme",
    "holderName" : "Checkout Shopper PlaceHolder",
    "name" : "Maestro"
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
