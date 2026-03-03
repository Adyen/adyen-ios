//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenCheckout
@testable import AdyenEncryption
@testable import AdyenNetworking
import XCTest

class AdyenContextTests: XCTestCase {
    
    func testAdditionalFieldsBinding() throws {

        let oneEUR = Amount(value: 1, currencyCode: "EUR")
        let twoEUR = Amount(value: 2, currencyCode: "EUR")
        
        let apiContext = try APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let context = AdyenContext(
            apiContext: apiContext,
            payment: .init(amount: oneEUR, countryCode: "NL"),
            amount: oneEUR,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: nil,
            analyticsConfiguration: .init()
        )
        
        XCTAssertEqual(context.payment?.amount, oneEUR)
        XCTAssertEqual(context.amount, oneEUR)
        context.update(payment: Payment(amount: twoEUR, countryCode: "NL"))
        XCTAssertEqual(context.payment?.amount, twoEUR)
    }
    
    func testPublicInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: nil,
            analyticsConfiguration: .init()
        )
        
        XCTAssertEqual(context.payment?.amount, Dummy.amount)
        XCTAssertEqual(context.amount, Dummy.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
    }
    
    func testInternalInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        
        XCTAssertEqual(context.payment?.amount, Dummy.amount)
        XCTAssertEqual(context.amount, Dummy.amount)
        XCTAssertEqual(context.apiContext.clientKey, Dummy.apiContext.clientKey)
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithRegularEnvironmentShouldHaveAnalyticsProvider() {
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: .init()
        )
        
        XCTAssertNotNil(context.analyticsProvider)
    }
    
    func testInitWithDifferentEnvironmentShouldNotHaveAnalyticsProvider() throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        
        let context = AdyenContext(
            apiContext: apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: nil,
            analyticsConfiguration: .init()
        )
        XCTAssertNil(context.analyticsProvider)
    }
    
    func testBothAnalyticsProviderShouldBeCreated() {
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: "test_attempt_id",
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: AnalyticsConfiguration()
        )
        
        XCTAssertNotNil(context.analyticsProvider)
        XCTAssertNotNil((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider)
    }
    
    func testOnlyAnalyticsProviderShouldBeCreated() {
        let config = AnalyticsConfiguration(isEnabled: false)
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)
        
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Dummy.payment,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: analyticsApiContext,
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
