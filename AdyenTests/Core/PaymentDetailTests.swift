//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class PaymentDetailTests: XCTestCase {
    func testSerializingPaymentDetails() {
        let paymentDetails = [
            PaymentDetail(key: "sepa.ownerName", value: "A. Klaassen"),
            PaymentDetail(key: "sepa.ibanNumber", value: "NL13TEST0123456789"),
            PaymentDetail(key: "keyWithoutValue"),
            PaymentDetail(key: "anotherKeyWithoutValue")
        ]
        let serializedPaymentDetails = paymentDetails.serialized
        XCTAssertEqual(serializedPaymentDetails.count, 2)
        XCTAssertEqual(serializedPaymentDetails["sepa.ownerName"] as! String, "A. Klaassen") // swiftlint:disable:this force_cast
        XCTAssertEqual(serializedPaymentDetails["sepa.ibanNumber"] as! String, "NL13TEST0123456789") // swiftlint:disable:this force_cast
    }
    
}
