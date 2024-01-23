//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenEncryption
import XCTest

class AdyenContextTests: XCTestCase {
    
    func testAdditionalFieldsBinding() {

        let oneEUR = Amount(value: 1, currencyCode: "EUR")
        let twoEUR = Amount(value: 2, currencyCode: "EUR")
        
        let apiContext = try! APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let context = AdyenContext(
            apiContext: apiContext,
            payment: .init(amount: oneEUR, countryCode: "NL")
        )
        
        XCTAssertEqual(context.payment?.amount, oneEUR)
        context.update(payment: Payment(amount: twoEUR, countryCode: "NL"))
        XCTAssertEqual(context.payment?.amount, twoEUR)
    }
}
