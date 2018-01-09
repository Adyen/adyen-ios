//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentMethodTests: XCTestCase {
    
    func testInitWithApplePayInfo() {
        let info = JsonReader.read(file: "PaymentMethodApplePay")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "Apple Pay")
        XCTAssertEqual(method?.type, "applepay")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.applepay)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        XCTAssertEqual(method?.configuration?["merchantIdentifier"] as? String, "merchant.com.test")
        
        XCTAssertEqual(method?.inputDetails?.count, 1)
        XCTAssertEqual(method?.inputDetails?[0].optional, false)
        XCTAssertEqual(method?.inputDetails?[0].key, "additionalData.applepay.token")
        XCTAssertEqual(method?.inputDetails?[0].type, InputType.applePayToken)
    }
    
    func testInitWithCardInfo() {
        let info = JsonReader.read(file: "PaymentMethodCard")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "MasterCard")
        XCTAssertEqual(method?.type, "mc")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.other)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        
        XCTAssertEqual(method?.inputDetails?.count, 2)
        XCTAssertEqual(method?.inputDetails?[0].optional, false)
        XCTAssertEqual(method?.inputDetails?[0].key, "additionalData.card.encrypted.json")
        XCTAssertEqual(method?.inputDetails?[0].type, InputType.cardToken(cvcOptional: false))
        XCTAssertEqual(method?.inputDetails?[1].optional, true)
        XCTAssertEqual(method?.inputDetails?[1].key, "storeDetails")
        XCTAssertEqual(method?.inputDetails?[1].type, InputType.boolean)
        
        XCTAssertEqual(method?.group?.name, "Credit Card")
        XCTAssertEqual(method?.group?.type, "card")
        XCTAssertEqual(method?.group?.data, "groupMethodData")
        
        XCTAssertNil(method?.configuration)
    }
    
    func testInitWithCardBillingAddressInfo() {
        let info = JsonReader.read(file: "PaymentMethodCardBillingAddress")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)!
        
        XCTAssertEqual(method.name, "MasterCard")
        XCTAssertEqual(method.type, "mc")
        XCTAssertEqual(method.txVariant, .other)
        XCTAssertEqual(method.isOneClick, false)
        XCTAssertEqual(method.paymentMethodData, "methodData")
        
        XCTAssertNotNil(method.inputDetails?["additionalData.card.encrypted.json"])
        XCTAssertNotNil(method.inputDetails?["storeDetails"])
        
        let billingAddressInputDetail = method.inputDetails!["billingAddress"]!
        let billingAddressInputDetails = billingAddressInputDetail.inputDetails!
        XCTAssertEqual(billingAddressInputDetails.count, 5)
        XCTAssertEqual(billingAddressInputDetails["street"]?.value, "Leidscheplein")
        XCTAssertEqual(billingAddressInputDetails["houseNumberOrName"]?.value, "1")
        XCTAssertEqual(billingAddressInputDetails["city"]?.value, "Amsterdam")
        XCTAssertEqual(billingAddressInputDetails["stateOrProvince"]?.value, nil)
        XCTAssertEqual(billingAddressInputDetails["country"]?.value, "NL")
        
    }
    
    func testInitWithCardCvcInfo() {
        let info = JsonReader.read(file: "PaymentMethodCardCvc")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)!
        
        XCTAssertEqual(method.name, "Maestro")
        XCTAssertEqual(method.type, "maestro")
        XCTAssertEqual(method.txVariant, PaymentMethodType.other)
        XCTAssertEqual(method.isOneClick, false)
        XCTAssertEqual(method.paymentMethodData, "methodData")
        
        let cardOneClickInfo = method.oneClickInfo as! CardOneClickInfo // swiftlint:disable:this force_cast
        XCTAssertEqual(cardOneClickInfo.number, "0000")
        XCTAssertEqual(cardOneClickInfo.holderName, "Shopper")
        XCTAssertEqual(cardOneClickInfo.expiryMonth, 8)
        XCTAssertEqual(cardOneClickInfo.expiryYear, 2018)
        
        XCTAssertEqual(method.inputDetails?.count, 1)
        XCTAssertEqual(method.inputDetails?[0].optional, false)
        XCTAssertEqual(method.inputDetails?[0].key, "cardDetails.cvc")
        XCTAssertEqual(method.inputDetails?[0].type, InputType.cvc)
        
        XCTAssertEqual(method.group?.name, "Credit Card")
        XCTAssertEqual(method.group?.type, "card")
        XCTAssertEqual(method.group?.data, "groupMethodData")
        
        XCTAssertNil(method.configuration)
    }
    
    func testInitWithIdealInfo() {
        let info = JsonReader.read(file: "PaymentMethodIdeal")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "iDEAL")
        XCTAssertEqual(method?.type, "ideal")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.ideal)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        
        XCTAssertEqual(method?.inputDetails?.count, 1)
        XCTAssertEqual(method?.inputDetails?[0].optional, false)
        XCTAssertEqual(method?.inputDetails?[0].key, "idealIssuer")
        XCTAssertEqual(method?.inputDetails?[0].type, InputType.select)
        XCTAssertEqual(method?.inputDetails?[0].items?.count, 2)
        XCTAssertEqual(method?.inputDetails?[0].items?[0].identifier, "1")
        XCTAssertEqual(method?.inputDetails?[0].items?[0].name, "Issuer1")
        XCTAssertEqual(method?.inputDetails?[0].items?[1].identifier, "2")
        XCTAssertEqual(method?.inputDetails?[0].items?[1].name, "Issuer2")
        
        XCTAssertNil(method?.group)
        XCTAssertNil(method?.configuration)
    }
    
    func testInitWithKlarnaInfo() {
        let info = JsonReader.read(file: "PaymentMethodKlarna")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "Klarna Factuur")
        XCTAssertEqual(method?.type, "klarna")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.other)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        XCTAssertNil(method?.inputDetails)
        
        XCTAssertNil(method?.group)
        XCTAssertNil(method?.configuration)
    }
    
    func testInitWithPaypalInfo() {
        let info = JsonReader.read(file: "PaymentMethodPaypal")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "PayPal")
        XCTAssertEqual(method?.type, "paypal")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.other)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        XCTAssertNil(method?.inputDetails)
        
        XCTAssertNil(method?.group)
        XCTAssertNil(method?.configuration)
    }
    
    func testInitWithRecurringPaypalInfo() {
        let info = JsonReader.read(file: "PaymentMethodPaypalRecurring")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "PayPal")
        XCTAssertEqual(method?.type, "paypal")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.other)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        XCTAssertNil(method?.inputDetails)
        
        XCTAssertNil(method?.group)
        XCTAssertNil(method?.configuration)
    }
    
    func testInitWithSepaInfo() {
        let info = JsonReader.read(file: "PaymentMethodSepa")!
        let method = PaymentMethod(info: info, logoBaseURL: "", isOneClick: false)
        
        XCTAssertEqual(method?.name, "SEPA Direct Debit")
        XCTAssertEqual(method?.type, "sepadirectdebit")
        XCTAssertEqual(method?.txVariant, PaymentMethodType.sepadirectdebit)
        XCTAssertEqual(method?.isOneClick, false)
        XCTAssertEqual(method?.paymentMethodData, "methodData")
        
        XCTAssertEqual(method?.inputDetails?.count, 2)
        XCTAssertEqual(method?.inputDetails?[0].optional, false)
        XCTAssertEqual(method?.inputDetails?[0].key, "sepa.ownerName")
        XCTAssertEqual(method?.inputDetails?[0].type, InputType.text)
        XCTAssertEqual(method?.inputDetails?[1].optional, false)
        XCTAssertEqual(method?.inputDetails?[1].key, "sepa.ibanNumber")
        XCTAssertEqual(method?.inputDetails?[1].type, InputType.text)
        
        XCTAssertNil(method?.group)
        XCTAssertNil(method?.configuration)
    }
}
