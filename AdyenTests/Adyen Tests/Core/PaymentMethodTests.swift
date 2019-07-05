//
// Copyright (c) 2019 Adyen B.V.
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
                ]
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
                ]
            ]
        ]
        
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        XCTAssertEqual(paymentMethods.stored.count, 4)
        XCTAssertTrue(paymentMethods.stored[0] is StoredCardPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[1] is StoredCardPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[2] is StoredPayPalPaymentMethod)
        XCTAssertTrue(paymentMethods.stored[3] is StoredRedirectPaymentMethod)
        
        XCTAssertEqual(paymentMethods.stored[3].type, "unknown")
        XCTAssertEqual(paymentMethods.stored[3].name, "Stored Redirect Payment Method")
        
        XCTAssertEqual(paymentMethods.regular.count, 4)
        XCTAssertTrue(paymentMethods.regular[0] is CardPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[1] is IssuerListPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[2] is SEPADirectDebitPaymentMethod)
        XCTAssertTrue(paymentMethods.regular[3] is RedirectPaymentMethod)
        
        XCTAssertEqual(paymentMethods.regular[3].type, "unknown")
        XCTAssertEqual(paymentMethods.regular[3].name, "Redirect Payment Method")
    }
    
    // MARK: - Card
    
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
    
    func testDecodingCardPaymentMethod() throws {
        let paymentMethod = try Coder.decode(cardDictionary) as CardPaymentMethod
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "Credit Card")
        XCTAssertEqual(paymentMethod.brands, ["mc", "visa", "amex"])
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
        XCTAssertEqual(paymentMethod.type, "scheme")
        XCTAssertEqual(paymentMethod.name, "VISA")
        XCTAssertEqual(paymentMethod.brand, "visa")
        XCTAssertEqual(paymentMethod.lastFour, "1111")
        XCTAssertEqual(paymentMethod.expiryMonth, "08")
        XCTAssertEqual(paymentMethod.expiryYear, "2018")
        XCTAssertEqual(paymentMethod.holderName, "test")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
    }
    
    // MARK: - Issuer List
    
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
    
    func testDecodingPayPalPaymentMethod() throws {
        let paymentMethod = try Coder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        XCTAssertEqual(paymentMethod.type, "paypal")
        XCTAssertEqual(paymentMethod.identifier, "9314881977134903")
        XCTAssertEqual(paymentMethod.name, "PayPal")
        XCTAssertEqual(paymentMethod.emailAddress, "example@shopper.com")
        XCTAssertEqual(paymentMethod.supportedShopperInteractions, [.shopperPresent, .shopperNotPresent])
    }
    
}

private extension Coder {
    
    static func decode<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        return try decode(data)
    }
    
}
