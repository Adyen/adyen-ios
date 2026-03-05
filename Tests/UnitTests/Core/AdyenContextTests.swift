//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenEncryption
@testable import AdyenNetworking
import XCTest

class AdyenContextTests: XCTestCase {
    
    func testAmountMutability() throws {

        let oneEUR = Amount(value: 1, currencyCode: "EUR")
        let twoEUR = Amount(value: 2, currencyCode: "EUR")
        
        let apiContext = try APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let context = AdyenContext(
            apiContext: apiContext,
            amount: oneEUR
        )
        
        XCTAssertEqual(context.amount, oneEUR)
        context.amount = twoEUR
        XCTAssertEqual(context.amount, twoEUR)
    }
    
    func testPublicInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount
        )
        
        XCTAssertEqual(context.amount, Dummy.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
    }
    
    func testInternalInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsProvider: AnalyticsProviderMock()
        )
        
        XCTAssertEqual(context.amount, Dummy.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithRegularEnvironmentShouldHaveAnalyticsProvider() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount
        )
        
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithDifferentEnvironmentShouldNotHaveAnalyticsProvider() throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        
        let context = AdyenContext(
            apiContext: apiContext,
            amount: Dummy.amount
        )
        XCTAssertNil(context.analyticsProvider)
    }
    
    func testBothAnalyticsProviderShouldBeCreated() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsConfiguration: AnalyticsConfiguration()
        )
        
        XCTAssertNotNil(context.analyticsProvider)
        XCTAssertNotNil((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider)
    }
    
    func testOnlyAnalyticsProviderShouldBeCreated() {
        let config = AnalyticsConfiguration(isEnabled: false)
        
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsConfiguration: config
        )
        
        XCTAssertNotNil(context.analyticsProvider)
        XCTAssertNil((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider)
    }
}

enum TestEnvironment: AnyAPIEnvironment {
    case test
    
    var baseURL: URL {
        URL(string: "test")!
    }
}
