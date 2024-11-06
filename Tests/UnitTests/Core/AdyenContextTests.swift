//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenEncryption
@testable import AdyenNetworking
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
    
    func testPublicInit() {
        let context = AdyenContext(apiContext: Dummy.apiContext, payment: Dummy.payment)
        
        XCTAssertEqual(context.payment?.amount, Dummy.payment.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
    }
    
    func testInternalInit() {
        let context = AdyenContext(apiContext: Dummy.apiContext, payment: Dummy.payment, analyticsProvider: AnalyticsProviderMock())
        
        XCTAssertEqual(context.payment?.amount, Dummy.payment.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithRegularEnvironmentShouldHaveAnalyticsProvider() {
        let context = AdyenContext(apiContext: Dummy.apiContext, payment: Dummy.payment)
        
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithDifferentEnvironmentShouldNotHaveAnalyticsProvider() {
        let apiContext = try! APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        
        let context = AdyenContext(apiContext: apiContext, payment: Dummy.payment)
        XCTAssertNil(context.analyticsProvider)
    }
    
    func testBothAnalyticsProviderShouldBeCreated() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            analyticsConfiguration: AnalyticsConfiguration()
        )
        
        XCTAssertNotNil(context.analyticsProvider)
        XCTAssertNotNil((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider)
    }
    
    func testOnlyAnalyticsProviderShouldBeCreated() {
        var config = AnalyticsConfiguration()
        config.isEnabled = false
        
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            analyticsConfiguration: config
        )
        
        XCTAssertNotNil(context.analyticsProvider)
        XCTAssertNil((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider)
    }
}

enum TestEnvironment: AnyAPIEnvironment {
    case test
    
    var baseURL: URL { URL(string: "test")! }
}
