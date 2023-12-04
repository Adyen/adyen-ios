//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenEncryption
import XCTest

class AdyenContextTests: XCTestCase {
    
    override class func tearDown() {
        AdyenAssertion.listener = nil
    }
    
    func testAdditionalFieldsBinding() {

        let oneEUR = Amount(value: 1, currencyCode: "EUR")
        let twoEUR = Amount(value: 2, currencyCode: "EUR")
        
        let apiContext = try! APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let context = AdyenContext(
            apiContext: apiContext,
            payment: .init(amount: oneEUR, countryCode: "NL")
        )
        
        XCTAssertEqual(context.analyticsProvider.additionalFields?().amount, oneEUR)
        
        context.update(payment: Payment(amount: twoEUR, countryCode: "NL"))
        
        XCTAssertEqual(context.analyticsProvider.additionalFields?().amount, twoEUR)
    }
    
    func testMissingImplementationContextAware() throws {
        
        class DummyContextAware: AdyenContextAware {}
        
        let dummy = DummyContextAware()
        
        let expectation = expectation(description: "Access expectation")
        expectation.expectedFulfillmentCount = 2
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "`@_spi(AdyenInternal) var context: AdyenContext` needs to be provided on `DummyContextAware`")
            expectation.fulfill()
        }
        
        // set
        dummy.context = .init(apiContext: Dummy.apiContext, payment: nil)
        // get
        let _ = dummy.context
        
        wait(for: [expectation], timeout: 1)
    }
}
